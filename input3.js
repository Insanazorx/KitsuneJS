// ===============================
// A) Global / top-level decls
// ===============================
var gv1 = 1;
let gl1 = 2;
const gc1 = 3;

function topFn(a, { b = 10, c: { d } }, ...rest) {
  // params: a, b, d, rest

  // var hoist target = function scope
  var fv1 = 1;

  // lexical block binding
  {
    let bl1 = 2;
    const bc1 = 3;

    // function decl inside block (spec nuance; declbinder should at least bind name somewhere)
    function innerBlockFn(p = 1, [x, y] = [2, 3]) {
      var innerVar = 0;
      let innerLet = 0;
      const innerConst = 0;
      return p + x + y + innerVar + innerLet + innerConst;
    }
  }

  // ===============================
  // B) Destructuring declarations (Pattern-heavy)
  // ===============================
  let { x, y: yy, z: { k }, ...objRest } = { x: 1, y: 2, z: { k: 3 }, q: 9 };
  // bindings: x, yy, k, objRest

  const [a0, , a2, ...arrRest] = [10, 11, 12, 13, 14];
  // bindings: a0, a2, arrRest

  // nested + defaults
  let {
    m: [n0, n1 = 7],
    p: { q = 9 },
  } = { m: [1], p: {} };
  // bindings: n0, n1, q

  // multiple declarators
  let u = 1, v, { w } = { w: 3 };
  // bindings: u, v, w

  // ===============================
  // C) For head lexical environments
  // ===============================
  for (let i = 0; i < 2; i++) {
    let j = i;
  }

  for (const [k2, v2] of [[1, 2], [3, 4]]) {
    // bindings: k2, v2 (for-of head)
  }

  // for-in with var
  for (var key in { a: 1, b: 2 }) {
    // binding: key (var -> function scope)
  }

  // for-of with var
  for (var val of [1, 2, 3]) {
    // binding: val (var -> function scope)
  }

  // ===============================
  // D) Try/catch binding
  // ===============================
  try {
    throw new Error("x");
  } catch ({ message: msg } /* (rest in catch isn't valid in JS spec, keep simple below) */) {
    // NOTE: catch param cannot be rest; keep catch param patterns valid:
  }

  try {
    throw { code: 404, info: { text: "nope" } };
  } catch ({ code, info: { text } }) {
    // bindings: code, text (catch scope)
  }

  // ===============================
  // E) Function expressions: inner name binding
  // ===============================
  const fe = function NamedFE(p, { r }) {
    // bindings: p, r
    // NamedFE is bound in its own function scope (inner name)
    var vfe = 1;
    return vfe + p + r;
  };

  // Arrow params are patterns too
  const af = ({ aa }, [bb, cc = 3], ...rr) => aa + bb + cc + rr.length;

  // ===============================
  // F) Class decl + class expression inner name
  // ===============================
  class C1 {
    constructor({ x }, y = 2) {
      // bindings: x, y
    }
    method([a, b], { c: { d } }) {
      // bindings: a, b, d
      let inside = 1;
      return inside;
    }
    set prop({ v }) {
      // bindings: v
      this._v = v;
    }
    get prop() {
      return this._v;
    }
    static {
      // static block has its own lexical env
      let s = 1;
      const t = 2;
    }
  }

  const CE = class InnerCE {
    // InnerCE is bound only inside the class body scope (inner name)
    m({ z }) {
      // bindings: z
    }
  };

  // ===============================
  // G) Object literal method/setter params
  // ===============================
  const obj = {
    method({ a }, [b]) {
      // bindings: a, b
      let mm = 1;
      return mm;
    },
    set x({ y }) {
      // bindings: y
      this._x = y;
    },
    get x() {
      return this._x;
    },
  };

  // ===============================
  // H) Shadowing checks (declbinder should allow shadowing by scope)
  // ===============================
  let shadow = 1;
  {
    let shadow = 2; // different binding (block)
    {
      const shadow = 3; // different binding (nested block)
    }
  }

  return gv1 + gl1 + gc1 + fv1;
}

// ===============================
// I) Top-level class/function decls
// ===============================
class TopClass {}
function TopFunc({ a }) { return a; }
