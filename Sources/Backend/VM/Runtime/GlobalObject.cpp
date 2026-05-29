#include "GlobalObject.h"

#include "ConsoleObject.h"
#include "JSFunction.h"
#include "../VM.h"
#include "Environment.h"

namespace JSBackend::Runtime {
    GlobalObject::GlobalObject(VM* vm) {
        setGlobalEnvironment(vm->heap().allocate<Environment>());

        if (!globalEnvironment()) {
            throw std::runtime_error("Failed to allocate global environment");
        }

        setConsoleObject(vm->heap().allocate<JSObject>());

        if (!consoleObject()) {
            throw std::runtime_error("Failed to allocate console object");
        }

        JSFunction::BuiltinFunction logImpl = LogBuiltin;
        auto* logJSFunction = vm->heap().allocate<JSFunction>(logImpl);
        const auto logJSValue = JSValue::cell(logJSFunction);
        consoleObject()->installBuiltinFunction("log", logJSValue);

        put(PropertyKey::identifier("console"), JSValue::cell(consoleObject()));
    }


}
