import BackendBridge
import Foundation

func loadInputBytes() throws -> [UInt8] {
    guard CommandLine.arguments.count > 1 else {
        return Array("JSBC\0swift-smoke".utf8)
    }

    let path = CommandLine.arguments[1]
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    return Array(data)
}

do {
    let library = try BackendLibrary()
    let context = try library.makeContext()
    let bytes = try loadInputBytes()

    try context.loadSerializedBytecode(bytes)
    try context.run()

    print("Swift -> C ABI -> C++ JSContext loaded \(context.loadedBytecodeSize) bytes")
    print("Backend pipeline stage: \(context.stage)")
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
