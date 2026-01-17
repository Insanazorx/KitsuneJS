import Foundation


let src = """

    class Example {

    get #private() {
        return this.#privateField;
    }

    set publicMethod(value) {
        this.#privateField = value;
    }

    constructor() {
        this.#privateField = 0;
    }

    get [a + "0"]() {
        return this.publicX;
    }

    set ["set" + (()=>{return 'r'})()](value) {
        this.publicX = value;

    async *generatorMethod(a, b) {
        await someAsyncFunction();
    }

    async ["" + "method"](x) {
        await anotherAsyncFunction();
    }
}
   
"""

let src2 = """

"""



func main() {
    let lexer = Lexer(src);
    let tokens = lexer.tokenize();
    print ("Tokens from grammar file:");
    let parser = Parser(tokens);
    print ("----------------------------------");
    do {
        let ast = try parser.parse();
        print(ast);
    } catch {
        print("Parsing error: \(error)");
    }
    
}

main();