#include "JSBackendCAPI.h"

#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <vector>

#ifndef JSBACKEND_SOURCE_DIR
#define JSBACKEND_SOURCE_DIR "."
#endif

#ifndef JSBACKEND_SWIFT_EXECUTABLE
#define JSBACKEND_SWIFT_EXECUTABLE "swift"
#endif

#ifndef JSBACKEND_SWIFT_BUILD_HOME
#define JSBACKEND_SWIFT_BUILD_HOME ".build/cmake/swift-home"
#endif

#ifndef JSBACKEND_SWIFT_MODULE_CACHE
#define JSBACKEND_SWIFT_MODULE_CACHE ".build/cmake/swift-module-cache"
#endif

#ifndef JSBACKEND_FRONTEND_BYTECODE_PATH
#define JSBACKEND_FRONTEND_BYTECODE_PATH ".build/cmake/frontend/frontend-bytecode.bin"
#endif

namespace {

std::vector<std::uint8_t> readBytes(const std::string& path) {
    std::ifstream input(path, std::ios::binary);
    if (!input) {
        return {};
    }

    return {
        std::istreambuf_iterator<char>(input),
        std::istreambuf_iterator<char>()
    };
}

int runSwiftFrontend(const std::string& bytecodePath) {
    const std::string command =
        "cd \"" + std::string(JSBACKEND_SOURCE_DIR) + "\" && "
        "HOME=\"" + std::string(JSBACKEND_SWIFT_BUILD_HOME) + "\" "
        "CLANG_MODULE_CACHE_PATH=\"" + std::string(JSBACKEND_SWIFT_MODULE_CACHE) + "\" "
        "JS_FRONTEND_BYTECODE_OUTPUT=\"" + bytecodePath + "\" "
        "JS_FRONTEND_SKIP_BACKEND_RUN=1 "
        "\"" + std::string(JSBACKEND_SWIFT_EXECUTABLE) + "\" run --disable-sandbox swift";

    return std::system(command.c_str());
}

}

int main(int argc, char** argv) {
    const std::string bytecodePath = argc > 1
        ? std::string(argv[1])
        : std::string(JSBACKEND_FRONTEND_BYTECODE_PATH);

    std::remove(bytecodePath.c_str());

    std::cout << "[CLionMainConf] Running Swift frontend...\n" << std::flush;
    const int frontendStatus = runSwiftFrontend(bytecodePath);
    if (frontendStatus != 0) {
        std::cerr << "[CLionMainConf] Swift frontend exited with status "
                  << frontendStatus << '\n';
        return 1;
    }

    std::vector<std::uint8_t> bytes = readBytes(bytecodePath);
    if (bytes.empty()) {
        std::cerr << "[CLionMainConf] Could not read frontend bytecode file, or file is empty: "
                  << bytecodePath << '\n';
        return 2;
    }
    std::cout << "[CLionMainConf] Using frontend bytecode output: "
              << bytecodePath << " (" << bytes.size() << " bytes)\n";

    JSBackendContext* context = JSBackendContextCreate();
    if (context == nullptr) {
        std::cerr << JSBackendStatusMessage(JS_BACKEND_STATUS_ALLOCATION_FAILED) << '\n';
        return 3;
    }

    const JSBackendStatus status = JSBackendContextLoadSerializedBytecode(
        context,
        bytes.data(),
        bytes.size()
    );

    if (status != JS_BACKEND_STATUS_OK) {
        std::cerr << JSBackendStatusMessage(status) << ": "
                  << JSBackendContextLastError(context) << '\n';
        JSBackendContextDestroy(context);
        return 4;
    }

    const JSBackendStatus runStatus = JSBackendContextRun(context);
    if (runStatus != JS_BACKEND_STATUS_OK) {
        std::cerr << JSBackendStatusMessage(runStatus) << ": "
                  << JSBackendContextLastError(context) << '\n';
        JSBackendContextDestroy(context);
        return 5;
    }

    std::cout << "[CLionMainConf] C++ backend JSContext loaded "
              << JSBackendContextBytecodeSize(context)
              << " bytes\n";
    std::cout << "[CLionMainConf] Backend pipeline stage: "
              << JSBackendContextStage(context) << '\n';

    JSBackendContextDestroy(context);
    return 0;
}
