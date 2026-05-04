import Foundation

#if os(Linux)
import Glibc
#else
import Darwin
#endif

public enum BackendBridgeError: Error, CustomStringConvertible {
    case libraryNotFound(String)
    case symbolNotFound(String)
    case contextCreationFailed
    case backendStatus(Int32, String, String)

    public var description: String {
        switch self {
        case .libraryNotFound(let path):
            return "Could not open backend C ABI library at \(path)"
        case .symbolNotFound(let name):
            return "Could not resolve backend C ABI symbol \(name)"
        case .contextCreationFailed:
            return "Backend context creation failed"
        case .backendStatus(let status, let message, let detail):
            if detail.isEmpty {
                return "Backend returned status \(status): \(message)"
            }
            return "Backend returned status \(status): \(message) - \(detail)"
        }
    }
}

public final class BackendLibrary {
    public typealias RawContext = UnsafeMutableRawPointer

    fileprivate typealias CreateFn = @convention(c) () -> RawContext?
    fileprivate typealias DestroyFn = @convention(c) (RawContext?) -> Void
    fileprivate typealias LoadFn = @convention(c) (RawContext?, UnsafePointer<UInt8>?, Int) -> Int32
    fileprivate typealias RunFn = @convention(c) (RawContext?) -> Int32
    fileprivate typealias ResetFn = @convention(c) (RawContext?) -> Void
    fileprivate typealias SizeFn = @convention(c) (RawContext?) -> Int
    fileprivate typealias StageFn = @convention(c) (RawContext?) -> Int32
    fileprivate typealias LastErrorFn = @convention(c) (RawContext?) -> UnsafePointer<CChar>?
    fileprivate typealias StatusMessageFn = @convention(c) (Int32) -> UnsafePointer<CChar>?

    private let handle: UnsafeMutableRawPointer
    private let createContext: CreateFn
    fileprivate let destroyContext: DestroyFn
    fileprivate let loadSerializedBytecode: LoadFn
    fileprivate let runContext: RunFn
    fileprivate let resetContext: ResetFn
    fileprivate let bytecodeSize: SizeFn
    fileprivate let pipelineStage: StageFn
    fileprivate let lastError: LastErrorFn
    fileprivate let statusMessage: StatusMessageFn

    public init(path explicitPath: String? = nil) throws {
        let path = explicitPath
            ?? ProcessInfo.processInfo.environment["JS_BACKEND_CABI_LIBRARY"]
            ?? BackendLibrary.defaultLibraryPath()

        guard let opened = dlopen(path, RTLD_NOW | RTLD_LOCAL) else {
            throw BackendBridgeError.libraryNotFound(path)
        }

        self.handle = opened
        self.createContext = try BackendLibrary.loadSymbol("JSBackendContextCreate", from: opened)
        self.destroyContext = try BackendLibrary.loadSymbol("JSBackendContextDestroy", from: opened)
        self.loadSerializedBytecode = try BackendLibrary.loadSymbol("JSBackendContextLoadSerializedBytecode", from: opened)
        self.runContext = try BackendLibrary.loadSymbol("JSBackendContextRun", from: opened)
        self.resetContext = try BackendLibrary.loadSymbol("JSBackendContextReset", from: opened)
        self.bytecodeSize = try BackendLibrary.loadSymbol("JSBackendContextBytecodeSize", from: opened)
        self.pipelineStage = try BackendLibrary.loadSymbol("JSBackendContextStage", from: opened)
        self.lastError = try BackendLibrary.loadSymbol("JSBackendContextLastError", from: opened)
        self.statusMessage = try BackendLibrary.loadSymbol("JSBackendStatusMessage", from: opened)
    }

    deinit {
        dlclose(handle)
    }

    public func makeContext() throws -> BackendJSContext {
        guard let raw = createContext() else {
            throw BackendBridgeError.contextCreationFailed
        }

        return BackendJSContext(rawContext: raw, library: self)
    }

    private static func loadSymbol<T>(_ name: String, from handle: UnsafeMutableRawPointer) throws -> T {
        guard let symbol = dlsym(handle, name) else {
            throw BackendBridgeError.symbolNotFound(name)
        }

        return unsafeBitCast(symbol, to: T.self)
    }

    private static func defaultLibraryPath() -> String {
        #if os(macOS)
        return ".build/cmake/lib/libJSBackendCABI.dylib"
        #elseif os(Windows)
        return ".build/cmake/bin/JSBackendCABI.dll"
        #else
        return ".build/cmake/lib/libJSBackendCABI.so"
        #endif
    }
}

public final class BackendJSContext {
    private var rawContext: BackendLibrary.RawContext?
    private let library: BackendLibrary

    fileprivate init(rawContext: BackendLibrary.RawContext, library: BackendLibrary) {
        self.rawContext = rawContext
        self.library = library
    }

    deinit {
        library.destroyContext(rawContext)
    }

    public func loadSerializedBytecode(_ bytes: [UInt8]) throws {
        guard let rawContext else {
            throw BackendBridgeError.contextCreationFailed
        }

        let status = bytes.withUnsafeBufferPointer { buffer in
            library.loadSerializedBytecode(rawContext, buffer.baseAddress, buffer.count)
        }

        guard status == 0 else {
            throw BackendBridgeError.backendStatus(
                status,
                cString(library.statusMessage(status)),
                cString(library.lastError(rawContext))
            )
        }
    }

    public func run() throws {
        guard let rawContext else {
            throw BackendBridgeError.contextCreationFailed
        }

        let status = library.runContext(rawContext)

        guard status == 0 else {
            throw BackendBridgeError.backendStatus(
                status,
                cString(library.statusMessage(status)),
                cString(library.lastError(rawContext))
            )
        }
    }

    public func reset() {
        library.resetContext(rawContext)
    }

    public var loadedBytecodeSize: Int {
        library.bytecodeSize(rawContext)
    }

    public var stage: Int32 {
        library.pipelineStage(rawContext)
    }

    private func cString(_ pointer: UnsafePointer<CChar>?) -> String {
        guard let pointer else {
            return ""
        }

        return String(cString: pointer)
    }
}
