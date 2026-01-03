import Foundation

let src = """
    function add(a, b) {
        var c = (a + b) * !c;
        return c;
    }
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