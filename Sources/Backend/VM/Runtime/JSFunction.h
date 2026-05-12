#pragma once

#include "JSObject.h"
#include "../Bytecodes/Bytecodes.h"

namespace JSBackend::Bytecode {
    class CodeBlock;
}

namespace JSBackend::Runtime {
    class JSFunction : public JSObject {
    public:
        ~JSFunction() override = default;
        Kind kind() const override { return Kind::Function; }

    private:
        Bytecode::CodeBlock* m_codeBlock {nullptr};
        Bytecode::FunctionID m_functionID {0xFFFFFFFF};
    };
}
