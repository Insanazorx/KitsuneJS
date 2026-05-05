import Foundation
import BackendBridge

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

      let serializationUnit = SerializationUnit()
      let compiler = BytecodeCompiler(
        compilationUnit: scopeAnalyzer.compilationUnit,
        serializationUnit: serializationUnit
      )
      compiler.compile()
      print(compiler)

      _ = compiler.exportSerializationUnit()

      let serializer = Serializer(serializationUnit: serializationUnit)
      serializer.serialize()
      print(serializer)

      let bytecode = serializer.exportBytecode()
      try writeBytecodeIfRequested(bytecode)

      if shouldSkipBackendRun() {
        print("Backend run skipped by JS_FRONTEND_SKIP_BACKEND_RUN.")
      } else {
        let backendLibrary = try BackendLibrary()
        let context = try backendLibrary.makeContext()
        try context.loadSerializedBytecode(bytecode)
        try context.run()
      }

      dumpToFile(scopeAnalyzer: scopeAnalyzer, compilerDump: compiler.description)
      
      } catch {
        print("Parsing error: \(error)");
      }



}

func writeBytecodeIfRequested(_ bytecode: [UInt8]) throws {
    guard let outputPath = ProcessInfo.processInfo.environment["JS_FRONTEND_BYTECODE_OUTPUT"],
          !outputPath.isEmpty else {
        return
    }

    let outputURL = URL(fileURLWithPath: outputPath)
    try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
    )
    try Data(bytecode).write(to: outputURL, options: .atomic)
    print("Serialized bytecode written to \(outputPath) (\(bytecode.count) bytes).")
}

func shouldSkipBackendRun() -> Bool {
    let value = ProcessInfo.processInfo.environment["JS_FRONTEND_SKIP_BACKEND_RUN"] ?? ""
    return value == "1" || value.lowercased() == "true"
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
