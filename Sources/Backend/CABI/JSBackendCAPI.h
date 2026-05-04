#pragma once

#include <stddef.h>
#include <stdint.h>

#if defined(_WIN32)
#if defined(JSBACKEND_BUILDING_DLL)
#define JSBACKEND_API __declspec(dllexport)
#else
#define JSBACKEND_API __declspec(dllimport)
#endif
#else
#define JSBACKEND_API __attribute__((visibility("default")))
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef struct JSBackendContext JSBackendContext;

typedef enum JSBackendStatus {
    JS_BACKEND_STATUS_OK = 0,
    JS_BACKEND_STATUS_NULL_CONTEXT = 1,
    JS_BACKEND_STATUS_INVALID_ARGUMENT = 2,
    JS_BACKEND_STATUS_LOAD_FAILED = 3,
    JS_BACKEND_STATUS_ALLOCATION_FAILED = 4,
    JS_BACKEND_STATUS_RUN_FAILED = 5
} JSBackendStatus;

typedef enum JSBackendPipelineStage {
    JS_BACKEND_PIPELINE_EMPTY = 0,
    JS_BACKEND_PIPELINE_BYTECODE_LOADED = 1,
    JS_BACKEND_PIPELINE_RAN = 2
} JSBackendPipelineStage;

JSBACKEND_API JSBackendContext* JSBackendContextCreate(void);
JSBACKEND_API void JSBackendContextDestroy(JSBackendContext* context);

JSBACKEND_API JSBackendStatus JSBackendContextLoadSerializedBytecode(
    JSBackendContext* context,
    const uint8_t* bytes,
    size_t length
);

JSBACKEND_API JSBackendStatus JSBackendContextRun(JSBackendContext* context);

JSBACKEND_API void JSBackendContextReset(JSBackendContext* context);
JSBACKEND_API size_t JSBackendContextBytecodeSize(const JSBackendContext* context);
JSBACKEND_API JSBackendPipelineStage JSBackendContextStage(const JSBackendContext* context);

JSBACKEND_API const char* JSBackendContextLastError(const JSBackendContext* context);
JSBACKEND_API const char* JSBackendStatusMessage(JSBackendStatus status);

#ifdef __cplusplus
}
#endif
