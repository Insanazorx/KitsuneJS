#include "JSBackendCAPI.h"

#include <stdint.h>
#include <stdio.h>

int main(void) {
    const uint8_t bytes[] = {'J', 'S', 'B', 'C', 0, 1, 2, 3};

    JSBackendContext* context = JSBackendContextCreate();
    if (context == NULL) {
        puts(JSBackendStatusMessage(JS_BACKEND_STATUS_ALLOCATION_FAILED));
        return 1;
    }

    JSBackendStatus status = JSBackendContextLoadSerializedBytecode(
        context,
        bytes,
        sizeof(bytes)
    );

    if (status != JS_BACKEND_STATUS_OK) {
        printf("%s: %s\n", JSBackendStatusMessage(status), JSBackendContextLastError(context));
        JSBackendContextDestroy(context);
        return 1;
    }

    status = JSBackendContextRun(context);
    if (status != JS_BACKEND_STATUS_OK) {
        printf("%s: %s\n", JSBackendStatusMessage(status), JSBackendContextLastError(context));
        JSBackendContextDestroy(context);
        return 1;
    }

    printf("C -> C ABI -> JSContext loaded %zu bytes\n", JSBackendContextBytecodeSize(context));
    JSBackendContextDestroy(context);
    return 0;
}
