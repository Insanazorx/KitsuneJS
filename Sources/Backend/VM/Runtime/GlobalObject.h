#pragma once
#include "JSObject.h"


namespace JSBackend::Runtime {
    class JSFunction;
    class Environment;

    class GlobalObject : public JSObject {
    public:

        ~GlobalObject() override = default;

        Environment* globalEnvironment() {return m_globalEnvironment;}
        void setGlobalEnvironment(Environment* env) { m_globalEnvironment = env; }

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
