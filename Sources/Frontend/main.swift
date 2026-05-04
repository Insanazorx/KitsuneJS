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
      
     
      var scopeAnalyzer = ScopeAnalyzer(syntaxTree: ast)
      scopeAnalyzer.analyze()
      scopeAnalyzer.renderDescription()
      
      
      print ("-----------------------------------")

      let compiler = BytecodeCompiler(compilationUnit: scopeAnalyzer.compilationUnit)
      compiler.compile()
      print(compiler)

      dumpToFile(scopeAnalyzer: scopeAnalyzer, compilerDump: compiler.description)
      
      } catch {
        print("Parsing error: \(error)");
      }



}

func dumpToFile(scopeAnalyzer: ScopeAnalyzer, compilerDump: String) {
    let fileURL2 = URL(fileURLWithPath: "output.txt")
    
    do {
      var stringToWrite: String = ""
      stringToWrite += scopeAnalyzer.compilationUnit.renderDescription()
      var nodeIdForCounting = 0
      for scopeId in scopeAnalyzer.compilationUnit.nodeIdToScopeId {
        stringToWrite += "\nNode ID: \(nodeIdForCounting)-> \(scopeAnalyzer.astLineerizer.walker.descs[nodeIdForCounting]) -> Scope ID: \(scopeId)"
        nodeIdForCounting += 1
      }

      stringToWrite += "\n\n\n------------------\n\n\n"
      stringToWrite += compilerDump
      
      try stringToWrite.write(to: fileURL2, atomically: true, encoding: .utf8)
      print("Output written to output.txt")
    } catch {
      print("Hata:", error)
    }

}
main();
