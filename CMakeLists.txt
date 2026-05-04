cmake_minimum_required(VERSION 3.25)

project(JSBackendHybrid LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

set(JSBACKEND_SOURCE_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/Sources/Backend")

set(JSBACKEND_PUBLIC_HEADERS
        ${JSBACKEND_SOURCE_ROOT}/CABI/JSBackendCAPI.h
        ${JSBACKEND_SOURCE_ROOT}/Context/Context.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Bytecodes/Bytecodes.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Interpreter/Interpreter.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Bytecodes/Instruction.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Interpreter/Register.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Runtime/JSValue.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Bytecodes/BytecodeDecoder.h
)

set(JSBACKEND_IDE_ONLY_SOURCES
        ${JSBACKEND_SOURCE_ROOT}/Tools/BackendSmoke.cpp
        ${JSBACKEND_SOURCE_ROOT}/Tools/CABISmoke.c
)

set_source_files_properties(${JSBACKEND_IDE_ONLY_SOURCES}
    PROPERTIES
        HEADER_FILE_ONLY TRUE
)

add_library(JSBackendCABI SHARED
        ${JSBACKEND_SOURCE_ROOT}/CABI/JSBackendCAPI.cpp
        ${JSBACKEND_SOURCE_ROOT}/VM/Interpreter/Interpreter.cpp
    ${JSBACKEND_PUBLIC_HEADERS}
        ${JSBACKEND_SOURCE_ROOT}/VM/Bytecodes/Instruction.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Interpreter/Register.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Runtime/JSValue.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Bytecodes/BytecodeDecoder.h
)

target_compile_definitions(JSBackendCABI PRIVATE JSBACKEND_BUILDING_DLL)
target_include_directories(JSBackendCABI
    PUBLIC
        "${JSBACKEND_SOURCE_ROOT}/CABI"
        "${JSBACKEND_SOURCE_ROOT}/Context"
        "${JSBACKEND_SOURCE_ROOT}/VM"
)

find_program(SWIFT_EXECUTABLE swift REQUIRED)

set(SWIFT_BUILD_HOME "${CMAKE_BINARY_DIR}/swift-home")
set(SWIFT_MODULE_CACHE "${CMAKE_BINARY_DIR}/swift-module-cache")

add_executable(CLionMainConf ${JSBACKEND_SOURCE_ROOT}/Tools/CLionMainConf.cpp
        ${JSBACKEND_SOURCE_ROOT}/VM/Bytecodes/Instruction.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Interpreter/Register.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Runtime/JSValue.h
        ${JSBACKEND_SOURCE_ROOT}/VM/Bytecodes/BytecodeDecoder.h)
target_sources(CLionMainConf PRIVATE ${JSBACKEND_IDE_ONLY_SOURCES})
target_link_libraries(CLionMainConf PRIVATE JSBackendCABI)
target_compile_definitions(CLionMainConf
    PRIVATE
        JSBACKEND_SOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}"
        JSBACKEND_SWIFT_EXECUTABLE="${SWIFT_EXECUTABLE}"
        JSBACKEND_SWIFT_BUILD_HOME="${SWIFT_BUILD_HOME}"
        JSBACKEND_SWIFT_MODULE_CACHE="${SWIFT_MODULE_CACHE}"
)

add_custom_command(TARGET CLionMainConf PRE_BUILD
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${SWIFT_BUILD_HOME}" "${SWIFT_MODULE_CACHE}"
    COMMAND "${CMAKE_COMMAND}" -E env
            "HOME=${SWIFT_BUILD_HOME}"
            "CLANG_MODULE_CACHE_PATH=${SWIFT_MODULE_CACHE}"
            "${SWIFT_EXECUTABLE}" build --disable-sandbox --product swift
    COMMAND "${CMAKE_COMMAND}" -E env
            "HOME=${SWIFT_BUILD_HOME}"
            "CLANG_MODULE_CACHE_PATH=${SWIFT_MODULE_CACHE}"
            "${SWIFT_EXECUTABLE}" build --disable-sandbox --product swift-backend-smoke
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    USES_TERMINAL
)

source_group(TREE "${JSBACKEND_SOURCE_ROOT}"
    PREFIX "Backend"
    FILES
        ${JSBACKEND_SOURCE_ROOT}/CABI/JSBackendCAPI.cpp
        ${JSBACKEND_SOURCE_ROOT}/VM/Interpreter/Interpreter.cpp
        ${JSBACKEND_SOURCE_ROOT}/Tools/CLionMainConf.cpp
        ${JSBACKEND_PUBLIC_HEADERS}
        ${JSBACKEND_IDE_ONLY_SOURCES}
)
