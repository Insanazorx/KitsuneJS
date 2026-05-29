#pragma once
#include "JSObject.h"


namespace JSBackend {
    class VM;
}

namespace JSBackend::Runtime {
    class JSFunction;
    class Environment;

    class GlobalObject : public JSObject {
    public:
        GlobalObject(VM* vm);
        ~GlobalObject() override = default;

        Environment* globalEnvironment() {return m_globalEnvironment;}
        void setGlobalEnvironment(Environment* env) { m_globalEnvironment = env; }
        JSObject* consoleObject () const { return m_consoleObject; }
        void setConsoleObject(JSObject* console) { m_consoleObject = console; }

    private:
        // The global environment record, which holds global context slots as JSValue
        Environment* m_globalEnvironment {nullptr};

        // Prototypes of built-in objects
        JSObject* m_arrayPrototype {nullptr};
        JSObject* m_objectPrototype {nullptr};
        JSObject* m_functionPrototype {nullptr};
        JSObject* m_stringPrototype {nullptr};
        JSObject* m_numberPrototype {nullptr};
        JSObject* m_booleanPrototype {nullptr};

        // Constructors of built-in objects
        JSFunction* m_objectConstructor {nullptr};
        JSFunction* m_functionConstructor {nullptr};
        JSFunction* m_arrayConstructor{nullptr};
        JSFunction* m_stringConstructor{nullptr};
        JSFunction* m_numberConstructor{nullptr};
        JSFunction* m_booleanConstructor{nullptr};

        JSObject* m_consoleObject {nullptr};


    };
}
