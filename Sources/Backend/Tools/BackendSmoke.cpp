#include "JSBackendCAPI.h"

#include <cstdint>
#include <fstream>
#include <iostream>
#include <iterator>
#include <vector>

namespace {

std::vector<std::uint8_t> readBytes(const char* path) {
    std::ifstream input(path, std::ios::binary);
    if (!input) {
        return {};
    }

    return {
        std::istreambuf_iterator<char>(input),
        std::istreambuf_iterator<char>()
    };
}

}

int main(int argc, char** argv) {
    std::vector<std::uint8_t> bytes;

    if (argc > 1) {
        bytes = readBytes(argv[1]);
        if (bytes.empty()) {
            std::cerr << "Could not read bytecode file, or file is empty: " << argv[1] << '\n';
            return 2;
        }
    } else {
        bytes = {'J', 'S', 'B', 'C', 0, 1, 2, 3};
    }

    JSBackendContext* context = JSBackendContextCreate();
    if (context == nullptr) {
        std::cerr << JSBackendStatusMessage(JS_BACKEND_STATUS_ALLOCATION_FAILED) << '\n';
        return 1;
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
        return 1;
    }

    const JSBackendStatus runStatus = JSBackendContextRun(context);
    if (runStatus != JS_BACKEND_STATUS_OK) {
        std::cerr << JSBackendStatusMessage(runStatus) << ": "
                  << JSBackendContextLastError(context) << '\n';
        JSBackendContextDestroy(context);
        return 1;
    }

    std::cout << "C++ -> C ABI -> JSContext loaded "
              << JSBackendContextBytecodeSize(context)
              << " bytes\n";

    JSBackendContextDestroy(context);
    return 0;
}
