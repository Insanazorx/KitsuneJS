import Foundation


//TODO: while(true)i++;
let src = """
for await (let item of [1,a = 0,2]) {
    console.log(item);
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