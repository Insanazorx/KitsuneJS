#include <cerrno>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

#if defined(_WIN32)
#include <direct.h>
#include <process.h>
#else
#include <unistd.h>
#endif

#ifndef JSBACKEND_SOURCE_DIR
#define JSBACKEND_SOURCE_DIR "."
#endif

#ifndef JSBACKEND_SWIFT_FRONTEND_EXECUTABLE
#define JSBACKEND_SWIFT_FRONTEND_EXECUTABLE ".build/debug/swift"
#endif

#ifndef JSBACKEND_CABI_LIBRARY_PATH
#if defined(__APPLE__)
#define JSBACKEND_CABI_LIBRARY_PATH "cmake-build-debug/lib/libJSBackendCABI.dylib"
#elif defined(_WIN32)
#define JSBACKEND_CABI_LIBRARY_PATH "cmake-build-debug/bin/JSBackendCABI.dll"
#else
#define JSBACKEND_CABI_LIBRARY_PATH "cmake-build-debug/lib/libJSBackendCABI.so"
#endif
#endif

namespace {

void setEnvironment(const char* name, const std::string& value) {
#if defined(_WIN32)
    _putenv_s(name, value.c_str());
#else
    setenv(name, value.c_str(), 1);
#endif
}

int changeDirectory(const char* path) {
#if defined(_WIN32)
    return _chdir(path);
#else
    return chdir(path);
#endif
}

[[noreturn]] void execSwiftFrontend(const std::vector<char*>& args) {
#if defined(_WIN32)
    _execv(args[0], args.data());
#else
    execv(args[0], args.data());
#endif

    std::cerr << "[RunSwift] Could not launch Swift frontend at "
              << args[0] << ": " << std::strerror(errno) << '\n';
    std::exit(127);
}

}

int main(int argc, char** argv) {
    if (changeDirectory(JSBACKEND_SOURCE_DIR) != 0) {
        std::cerr << "[RunSwift] Could not change working directory to "
                  << JSBACKEND_SOURCE_DIR << ": " << std::strerror(errno) << '\n';
        return 126;
    }

    setEnvironment("JS_BACKEND_CABI_LIBRARY", JSBACKEND_CABI_LIBRARY_PATH);

    std::vector<char*> args;
    args.reserve(static_cast<std::size_t>(argc) + 1);
    args.push_back(const_cast<char*>(JSBACKEND_SWIFT_FRONTEND_EXECUTABLE));
    for (int index = 1; index < argc; ++index) {
        args.push_back(argv[index]);
    }
    args.push_back(nullptr);

    execSwiftFrontend(args);
}
