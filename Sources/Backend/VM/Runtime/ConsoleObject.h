#pragma once
#include "JSObject.h"

namespace JSBackend {
     class VM;
}

namespace JSBackend::Runtime {
     JSValue LogBuiltin(VM& vm, JSObject* thisObj, const std::vector<JSValue>& args);

}
