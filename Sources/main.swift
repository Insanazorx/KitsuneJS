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
   
"""

let src2 = """
if (true) ++i;
"""



func main() {
    let lexer = Lexer(src2);
    let tokens = lexer.tokenize();
    print ("Tokens from grammar file:");
    let parser = Parser(tokens);
    print ("----------------------------------");
    do {
        let ast = try parser.parse();
        print(ast);
        var idWrapper = IdWrapper();
        var walker = WalkerImpl(walker: idWrapper);
        walker.walk(node: ast);
        walker.printDescription();
      
    } catch {
        print("Parsing error: \(error)");
    }
    
}

main();