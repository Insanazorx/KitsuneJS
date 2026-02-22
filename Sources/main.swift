import Foundation



let src = """

/* --------------------------- CLASS EDGE CASES --------------------------- */
const sym = Symbol("k");
let side = 0;

class Edge extends (class Base { static base = 1 }) {
  // 1) public field with computed key
  ["a" + "0"] = 41;

  // 2) public field named "this" (keyword token -> IdentifierName in key position)
  this = "field-named-this";

  // 3) private field + private method + private accessor
  #p = 1;
  #m() { return this.#p; }
  get #g() { return this.#p; }
  set #g(v) { this.#p = v; }

  // 4) static private field + static public field with Symbol computed key
  static #sp = 10;
  static [sym] = "symField";

  // 5) getter/setter with computed keys (side-effect inside key expression)
  get ["get" + (++side)]() { return this["a0"]; }
  set ["set" + (side += 2)](v) { this["a0"] = v; }


  // 7) async generator + computed method name
  async *["gen" + "Method"](a, b = a) {
    await Promise.resolve(a + b);
  }

  // 8) static block with `this` meaning the class constructor
  static {
    this.init = (this.init) + 1;
    this["fromStatic"] = true;
  }

  constructor() {
    super();
    // 9) private access on this
    this.#p = 42;

    // 10) computed member write
    this["a" + "0"] = 99;

    // 11) optional chaining / nullish coalescing
    this.maybe = this.maybe;

    // 12) call + new.target
    this.createdWithNew = new.target !== undefined;
  }
}

const e = new Edge();

/* -------------------------- OBJECT EDGE CASES --------------------------- */
const obj = {
  // 1) IdentifierName keys that look like keywords
  this: "propNamedThis",
  get: "not an accessor (just a data prop)",
  static: 123,

  // 2) accessor pair
  get x() { return this._x ?? 0; },
  set x(v) { this._x = v; },

  // 3) computed keys with side-effects
  ["k" + (++side)]: "computed1",
  ["k" + (++side)]: "computed2 (overwrites previous key if same string)",

  // 4) method shorthand + computed method
  m() { return this.x; },
  ["m" + "2"]() { return this["k" + side]; },

  // 5) symbol key
  [sym]: "symValue",

  // 6) async method + generator method
  async am() { return await Promise.resolve(7); },
  *gm() { yield 1; yield 2; },

  // 7) __proto__ special case vs normal key
  "__proto__": 5, // in object literal this is a *normal* data property in modern JS (not changing proto)
};

// NOTE: block vs object literal ambiguity example:
{ e.a0 = 1; }          // BLOCK with ExpressionStatement
({ ["a" + "0"]: 1 });  // OBJECT LITERAL with computed property

console.log(e["a0"], e.this, e.this(), obj.this, obj[sym], side);
}

//-------------------------------------------------------------

  let func = function() {
  function test(c,d) {
    let x = 1;
    if (true) {
      let x = ((a,b) => {
        function a(){return 1};
        return 2;
      })(x,this);
      console.log(x);
    }
    console.log((()=>{
        x = 2;
        return x;
      })(a,c)
    );
  }
}
"""

let src2 = """
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
  } catch ({ message: msg }, ...restCatch /* (rest in catch isn't valid in JS spec, keep simple below) */) {
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
"""

let src3 = """
a += 1;
"""


func main() {
    let lexer = Lexer(src3);
    let tokens = lexer.tokenize();
    print ("Tokens from grammar file:");
    let parser = Parser(tokens);
    print ("----------------------------------");
    do {
      let ast = try parser.parse();
      print(ast);
      var compilationUnit = CompilationUnit(ast: ast);
      var scopeBuilder = WalkerImpl(walker: ScopeBuilder());
      scopeBuilder.walker.compilationUnit = compilationUnit;
      print ("-----------------------------------")
      
      scopeBuilder.walk(node: ast)
      scopeBuilder.printDescription();
      
      
    } catch {
        print("Parsing error: \(error)");
    }
    
}

main();