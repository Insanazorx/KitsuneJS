import Foundation


//TODO: while(true)i++;
let src = """
for (i = 0; i < 10; i++) {
    if (i % 2 == 0) {
        console.log("Even:", i);
    } else {
        console.log("Odd:", i);
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