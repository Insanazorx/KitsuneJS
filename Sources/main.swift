import Foundation

func main() {
    let fileURL = URL(fileURLWithPath: "input.js")

    var content: String = "";
    do {
      content = try String(contentsOf: fileURL, encoding: .utf8)
      print("File content read successfully.")
    } catch {
      fatalError ("Error reading file: \(error)")
    }

    print("-----------------------------------------------")
    
    let lexer = Lexer(content);
    let tokens = lexer.tokenize();
    print ("Tokens from grammar file:");
    let parser = Parser(tokens);
    print ("----------------------------------");
    do {
      let ast = try parser.parse();
      
      print(ast);
      
      print ("-----------------------------------")
      
      var astLineerizer = WalkerImpl(ASTLineerizer(ast: ast));
      let compilationUnit = CompilationUnit(ast: ast);
      var scopeBuilder = WalkerImpl(ScopeBuilder(compilationUnit));
      var declBinder = WalkerImpl(DeclBinder(compilationUnit));
      var refBinder = WalkerImpl(RefBinder(compilationUnit));


      
      scopeBuilder.walk(node: ast)
      astLineerizer.walk(node: ast)
      

      var nodeIdForCounting = 0
      compilationUnit.nodeIdToScopeId.forEach {scopeId in
        print("Node ID: \(nodeIdForCounting)-> \(astLineerizer.walker.descs[nodeIdForCounting]) -> Scope ID: \(scopeId)")
        nodeIdForCounting += 1
      }

      declBinder.walk(node: ast)
      refBinder.walk(node: ast)

      

      print(compilationUnit.renderDescription())

      let fileURL2 = URL(fileURLWithPath: "output.txt")

    do {
      try compilationUnit.renderDescription().write(to: fileURL2, atomically: true, encoding: .utf8)
      print("Output written to output.txt")
    } catch {
      print("Hata:", error)
    }
      
      
    } catch {
        print("Parsing error: \(error)");
    }


    
}

main();