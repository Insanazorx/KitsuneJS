#pragma once

#include "CallFrame.h"
#include "JSObject.h"
#include "../Bytecodes/Bytecodes.h"

namespace JSBackend::Runtime {
    class JSFunction : public JSObject {
    public:
        ~JSFunction() override = default;

    private:
        CallFrame m_callFrame;
        Bytecode::FunctionID m_functionID {0xFFFFFFFF};
    };
}
