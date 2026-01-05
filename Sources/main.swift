import Foundation


//TODO: while(true)i++;
let src = """
async function fetchData(url) {
    try {
        let response = await fetch(url).then(res => {
            setTimeout(() => {
                console.log("Fetched:", res);
            }, 1000);
            return res;
        });

        if (response.status == 200) {
            return await response.json();
        } else {
            throw new Error("Failed to fetch data");
        }
    } catch (error) {
        console.log("Error:", error);
        return null;
    }
}
"""

let src2 = """
function test() {
    throw a;
    throw new Error("This is a test error");
    new TypeError("This is a type error");    
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