import Foundation


let src = """
if (true) ({ [ (()=>{return 3})() ] : 1, b : 2});
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