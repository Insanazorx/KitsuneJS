// test.js
// Capture Analyzer Stress Test
//
// Amaç:
// - Hangi binding'ler gerçekten inner scope tarafından capture ediliyor?
// - Hangi identifier sadece global/reference ama capture değil?
// - Shadowing, default param, destructuring, block scope, loop closure gibi
//   durumlarda analyzer doğru çalışıyor mu?
//
// Not:
// - "globalX", "console", "Math" gibi isimler lexical outer capture sayılmamalı
//   (engine tasarımına göre global/builtin reference olabilir).

let globalX = 100;
const globalY = 200;

function simpleCapture(a) {
  let x = 1;
  const y = 2;
  var z = 3;

  function inner(b) {
    return a + b + x + y + z + globalX;
  }

  return inner;
}
// Expected:
// - inner captures: a, x, y, z
// - inner references globalX, but usually this is NOT lexical capture
// - simpleCapture itself captures nothing


function nestedMultiLevel(p) {
  let outer1 = 10;
  const outer2 = 20;

  function mid(q) {
    let midLocal = 30;

    function inner(r) {
      return p + q + r + outer1 + outer2 + midLocal;
    }

    return inner;
  }

  return mid;
}
// Expected:
// - mid captures: p, outer1, outer2
// - inner captures: p, q, outer1, outer2, midLocal
//   (depending on your model, inner may be recorded as capturing from nearest resolved binding owners)


function shadowingCase(a) {
  let x = 5;

  function inner1() {
    let x = 50;
    function inner2() {
      return x + a;
    }
    return inner2;
  }

  return inner1;
}
// Expected:
// - inner1 captures: a? NO, because inner1 body itself doesn't use a
// - inner2 captures: x(from inner1), a(from shadowingCase)
// - outer x should NOT be captured by inner2 because shadowed by inner1's x


function blockCapture(flag) {
  let outside = 1;

  if (flag) {
    let blockLet = 2;
    const blockConst = 3;
    var functionVar = 4;

    function inner() {
      return outside + blockLet + blockConst + functionVar;
    }

    return inner;
  }

  return function () {
    return outside;
  };
}
// Expected:
// branch 1 inner captures: outside, blockLet, blockConst, functionVar
// fallback anonymous function captures: outside
// functionVar is function-scoped, blockLet/blockConst are block-scoped


function parameterDefaults(a, b = a + 1, c = b + globalY) {
  let local = 10;

  function inner(d = a + b + c + local) {
    return d;
  }

  return inner;
}
// Expected:
// - default initializers are tricky:
//   b references a
//   c references b and globalY
//   inner default param references a, b, c, local
// - inner captures: a, b, c, local
// - globalY usually not lexical capture


function destructuringParams({ x, y: renamedY }, [first, second] = [10, 20]) {
  const local = 7;

  function inner() {
    return x + renamedY + first + second + local;
  }

  return inner;
}
// Expected:
// - inner captures: x, renamedY, first, second, local


function destructuringInside() {
  let base = 100;
  const obj = { a: 1, b: 2 };
  let arr = [3, 4];

  const { a, b } = obj;
  const [c, d] = arr;

  function inner() {
    return base + a + b + c + d;
  }

  return inner;
}
// Expected:
// - inner captures: base, a, b, c, d
// - inner should NOT directly capture obj/arr unless body refers to them


function forLoopLet() {
  let fns = [];

  for (let i = 0; i < 3; i++) {
    let j = i * 10;
    fns.push(function () {
      return i + j;
    });
  }

  return fns;
}
// Expected:
// - each anonymous function captures per-iteration i and j
// - if your analyzer is static only, mark capture of i and j from loop scope


function forLoopVar() {
  let fns = [];

  for (var i = 0; i < 3; i++) {
    var j = i * 10;
    fns.push(function () {
      return i + j;
    });
  }

  return fns;
}
// Expected:
// - each anonymous function captures function-scoped i and j
// - different from let-loop semantics, but capture set still i and j


function whileLoopCapture() {
  let i = 0;
  let out = [];

  while (i < 2) {
    let snap = i;
    out.push(() => i + snap);
    i++;
  }

  return out;
}
// Expected:
// - arrow captures i and snap


function mutationOfCaptured() {
  let counter = 0;

  function inc() {
    counter = counter + 1;
    return counter;
  }

  function read() {
    return counter;
  }

  return { inc, read };
}
// Expected:
// - inc captures: counter
// - read captures: counter


function namedFunctionExpressionOuter() {
  const x = 1;

  const f = function self(n) {
    if (n <= 0) return x;
    return self(n - 1) + x;
  };

  return f;
}
// Expected:
// - function expression body captures x
// - self is own local function name binding, NOT outer capture


function arrowCapture(a) {
  let x = 10;
  const y = 20;

  return (b) => a + b + x + y;
}
// Expected:
// - arrow captures: a, x, y


function arrowNested() {
  let outer = 1;

  return (a) => {
    let mid = 2;
    return (b) => outer + a + b + mid;
  };
}
// Expected:
// - outer arrow captures: outer? YES, because body of outer arrow eventually references outer directly in returned inner arrow?
//   Static AST-wise: outer arrow body contains inner arrow that uses outer; depending on your analyzer,
//   the outer arrow may or may not be marked as needing closure env.
// - inner arrow captures: outer, a, mid
//
// Important design note:
// If you compute captures by "used by nested function", then outer arrow should likely mark a and mid as captured by inner,
// and outer as maybe captured from its parent.


function catchBindingTest() {
  let outside = 9;

  try {
    throw { message: "err" };
  } catch (e) {
    let local = 3;
    return function inner() {
      return e.message.length + local + outside;
    };
  }
}
// Expected:
// - inner captures: e, local, outside


function classMethodTest(seed) {
  class Counter {
    constructor(start) {
      this.start = start;
    }

    makeAdder(step) {
      let local = seed + this.start;

      function add(n) {
        return n + step + local;
      }

      return add;
    }
  }

  return new Counter(5);
}
// Expected:
// - makeAdder's inner function add captures: step, local
// - seed is used in makeAdder body, not directly by add
// - add should NOT capture this unless explicitly referenced


function classFieldLikePattern() {
  let hidden = 42;

  class Box {
    value() {
      return (() => hidden)();
    }
  }

  return Box;
}
// Expected:
// - arrow captures hidden


function objectMethodNested(a) {
  let x = 1;

  const obj = {
    method(b) {
      let y = 2;
      function inner(c) {
        return a + b + c + x + y;
      }
      return inner;
    }
  };

  return obj;
}
// Expected:
// - inner captures: a, b, x, y


function defaultParamReferencingFunctionBodyScope(a, b = () => a) {
  let x = 10;
  return function inner() {
    return b() + x;
  };
}
// Expected:
// - arrow in default param captures: a
// - inner captures: b, x
//
// Important:
// default parameter scope and function body scope distinction may matter in your frontend model.


function restParamCapture(...items) {
  let factor = 2;
  return function inner() {
    return items.map(x => x * factor);
  };
}
// Expected:
// - inner captures: items, factor
// - nested arrow inside map captures: factor? maybe x is local param, factor comes from inner's outer
// - depending on analysis granularity, map callback captures factor


function computedPropertyNameCapture() {
  let key = "value";
  let base = 10;

  const obj = {
    [key]: function () {
      return base;
    }
  };

  return obj;
}
// Expected:
// - computed property expression uses key in outer scope, but not as nested closure
// - anonymous function captures base


function immediateNestedUse() {
  let x = 3;

  return (function () {
    return function () {
      return x;
    };
  })();
}
// Expected:
// - inner-most function captures x
// - middle IIFE may or may not need closure env depending on representation strategy


function deepShadowChain(a) {
  let x = 1;

  function l1() {
    let x = 2;

    function l2() {
      let x = 3;

      function l3() {
        return x + a;
      }

      return l3;
    }

    return l2;
  }

  return l1;
}
// Expected:
// - l3 captures: x(from l2), a(from deepShadowChain)
// - outer x bindings should not leak through shadow chain


function globalVsLexical() {
  let local = 1;

  function inner() {
    return local + globalThis.Array.from([1, 2]).length + Math.max(1, 2);
  }

  return inner;
}
// Expected:
// - inner captures: local
// - globalThis, Array, Math are global/builtin refs, usually not lexical captures


function nestedBlockScopes() {
  let a = 1;

  {
    let b = 2;
    {
      const c = 3;
      function inner() {
        return a + b + c;
      }
      return inner;
    }
  }
}
// Expected:
// - inner captures: a, b, c


function recursiveDeclarationCapture(n) {
  let acc = 0;

  function fact(k) {
    if (k <= 1) return acc + 1;
    return k * fact(k - 1);
  }

  return fact(n);
}
// Expected:
// - fact captures: acc
// - recursive self-reference fact is own binding, not outer capture


function parameterShadowing(a) {
  let x = 1;

  function inner(x) {
    return x + a;
  }

  return inner;
}
// Expected:
// - inner captures: a
// - outer x is NOT captured because param x shadows it


function closureThroughReturnedObject() {
  let state = 0;

  function inc() {
    state++;
    return state;
  }

  function dec() {
    state--;
    return state;
  }

  function value() {
    return state;
  }

  return { inc, dec, value };
}
// Expected:
// - inc captures state
// - dec captures state
// - value captures state


function nestedDestructuringAndDefault(
  { a, b: { c } } = { a: 1, b: { c: 2 } }
) {
  let local = 5;

  return function inner([x, y] = [a, c]) {
    return x + y + local;
  };
}
// Expected:
// - inner default param references a and c
// - inner captures: a, c, local


function sequence() {
  let x = 1, y = 2, z = 3;

  return function inner() {
    return (x++, y++, z++, x + y + z);
  };
}
// Expected:
// - inner captures: x, y, z


// -------------------------
// Optional runtime smoke usage
// -------------------------

const samples = [
  simpleCapture(1),
  nestedMultiLevel(1)(2),
  shadowingCase(1)(),
  blockCapture(true),
  parameterDefaults(1),
  destructuringParams({ x: 1, y: 2 }),
  destructuringInside(),
  ...forLoopLet(),
  ...forLoopVar(),
  ...whileLoopCapture(),
  mutationOfCaptured().inc,
  mutationOfCaptured().read,
  namedFunctionExpressionOuter(),
  arrowCapture(5),
  arrowNested()(10),
  catchBindingTest(),
  classMethodTest(7).makeAdder(3),
  objectMethodNested(1).method(2),
  defaultParamReferencingFunctionBodyScope(3),
  restParamCapture(1, 2, 3),
  computedPropertyNameCapture().value,
  immediateNestedUse(),
  deepShadowChain(9)()(),
  globalVsLexical(),
  nestedBlockScopes(),
  parameterShadowing(5),
  closureThroughReturnedObject().inc,
  nestedDestructuringAndDefault(),
  sequence(),
];

for (const fn of samples) {
  if (typeof fn === "function") {
    try {
      console.log(fn(1));
    } catch (e) {
      console.log("runtime call error:", e && e.message);
    }
  }
}