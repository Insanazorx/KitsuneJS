#pragma once
#include "Environment.h"
#include "JSObject.h"
#include "../GC/Heap.h"


namespace JSBackend::Runtime {
    class JSFunction;

    class GlobalObject : public JSObject {
    public:
        static GlobalObject* Create(VM& vm) {
            auto *globalObject = vm.heap().allocate<GlobalObject>();


        }
        ~GlobalObject() override = default;

    private:

        // The global environment record, which holds global context slots as JSValue
        Environment* m_globalEnvironment {nullptr};

        // Prototypes of built-in objects
        JSObject* arrayPrototype {nullptr};
        JSObject* objectPrototype {nullptr};
        JSObject* functionPrototype {nullptr};
        JSObject* stringPrototype {nullptr};
        JSObject* numberPrototype {nullptr};
        JSObject* booleanPrototype {nullptr};

        // Constructors of built-in objects
        JSFunction* objectConstructor {nullptr};
        JSFunction* functionConstructor {nullptr};
        JSFunction* arrayConstructor{nullptr};
        JSFunction* stringConstructor{nullptr};
        JSFunction* numberConstructor{nullptr};
        JSFunction* booleanConstructor{nullptr};

        JSObject* consoleObject {nullptr};


    };
}
