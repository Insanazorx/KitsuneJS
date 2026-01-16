import Foundation


let src = """
if (true) ({ 
    g,
    a: 1, 
    get [b + "_1"]() { return 2; }, 
    set [c + "_1"](x) { this._c = x; }, 
    [d + "_1"]() { return 3; },
    *[e+"_1"]() {return 4; },
    async [f + "_1"]() { return 5; }
    }) 
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