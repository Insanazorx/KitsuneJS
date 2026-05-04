#include "JSBackendCAPI.h"

#include "Context.h"

#include <new>

struct JSBackendContext {
    JSBackend::JSContext impl;
};

JSBackendContext* JSBackendContextCreate(void) {
    return new (std::nothrow) JSBackendContext();
}

void JSBackendContextDestroy(JSBackendContext* context) {
    delete context;
}

JSBackendStatus JSBackendContextLoadSerializedBytecode(
    JSBackendContext* context,
    const uint8_t* bytes,
    size_t length
) {
    if (context == nullptr) {
        return JS_BACKEND_STATUS_NULL_CONTEXT;
    }

    if (bytes == nullptr && length != 0) {
        return JS_BACKEND_STATUS_INVALID_ARGUMENT;
    }

    if (!context->impl.loadSerializedBytecode(bytes, length)) {
        return JS_BACKEND_STATUS_LOAD_FAILED;
    }

    return JS_BACKEND_STATUS_OK;
}

JSBackendStatus JSBackendContextRun(JSBackendContext* context) {
    if (context == nullptr) {
        return JS_BACKEND_STATUS_NULL_CONTEXT;
    }

    if (!context->impl.run()) {
        return JS_BACKEND_STATUS_RUN_FAILED;
    }

    return JS_BACKEND_STATUS_OK;
}

void JSBackendContextReset(JSBackendContext* context) {
    if (context != nullptr) {
        context->impl.reset();
    }
}

size_t JSBackendContextBytecodeSize(const JSBackendContext* context) {
    if (context == nullptr) {
        return 0;
    }

    return context->impl.bytecodeSize();
}

JSBackendPipelineStage JSBackendContextStage(const JSBackendContext* context) {
    if (context == nullptr) {
        return JS_BACKEND_PIPELINE_EMPTY;
    }

    switch (context->impl.stage()) {
    case JSBackend::PipelineStage::Ran:
        return JS_BACKEND_PIPELINE_RAN;
    case JSBackend::PipelineStage::BytecodeLoaded:
        return JS_BACKEND_PIPELINE_BYTECODE_LOADED;
    case JSBackend::PipelineStage::Empty:
    default:
        return JS_BACKEND_PIPELINE_EMPTY;
    }
}

const char* JSBackendContextLastError(const JSBackendContext* context) {
    if (context == nullptr) {
        return "context is null";
    }

    return context->impl.lastError();
}

const char* JSBackendStatusMessage(JSBackendStatus status) {
    switch (status) {
    case JS_BACKEND_STATUS_OK:
        return "ok";
    case JS_BACKEND_STATUS_NULL_CONTEXT:
        return "context is null";
    case JS_BACKEND_STATUS_INVALID_ARGUMENT:
        return "invalid argument";
    case JS_BACKEND_STATUS_LOAD_FAILED:
        return "failed to load serialized bytecode";
    case JS_BACKEND_STATUS_ALLOCATION_FAILED:
        return "allocation failed";
    case JS_BACKEND_STATUS_RUN_FAILED:
        return "failed to run backend context";
    default:
        return "unknown status";
    }
}
