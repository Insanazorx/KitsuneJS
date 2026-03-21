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
      
      let compilationUnit = CompilationUnit(ast: ast);
      var astLineerizer = WalkerImpl(ASTLineerizer(ast: ast, compilationUnit: compilationUnit));
      var scopeBuilder = WalkerImpl(ScopeBuilder(compilationUnit));
      var declBinder = WalkerImpl(DeclBinder(compilationUnit));
      var refBinder = WalkerImpl(RefBinder(compilationUnit));
      var captureAnalyzer = CaptureAnalyzer(compilationUnit);

      
      scopeBuilder.walk(node: ast)
      astLineerizer.walk(node: ast)
      

      var nodeIdForCounting = 0
      compilationUnit.nodeIdToScopeId.forEach {scopeId in
        print("Node ID: \(nodeIdForCounting)-> \(astLineerizer.walker.descs[nodeIdForCounting]) -> Scope ID: \(scopeId)")
        nodeIdForCounting += 1
      }

      declBinder.walk(node: ast)
      refBinder.walk(node: ast)
      
      //captureAnalyzer.analyze()

      print(compilationUnit.renderDescription())

      
      
    let fileURL2 = URL(fileURLWithPath: "output.txt")

    do {
      var stringToWrite: String = ""
      stringToWrite += compilationUnit.renderDescription()
      var nodeIdForCounting = 0
      for scopeId in compilationUnit.nodeIdToScopeId {
        stringToWrite += "\nNode ID: \(nodeIdForCounting)-> \(astLineerizer.walker.descs[nodeIdForCounting]) -> Scope ID: \(scopeId)"
        nodeIdForCounting += 1
      }
      try stringToWrite.write(to: fileURL2, atomically: true, encoding: .utf8)
      print("Output written to output.txt")
    } catch {
      print("Hata:", error)
    }
      
      
    } catch {
        print("Parsing error: \(error)");
    }


    
}

main();