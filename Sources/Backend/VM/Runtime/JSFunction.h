#pragma once

#include "JSObject.h"
#include "../Bytecodes/Bytecodes.h"

namespace JSBackend::Bytecode {
    class CodeBlock;
}

namespace JSBackend::Runtime {
    class JSFunction : public JSObject {
    public:
        using BuiltinFunction = JSValue(*)(VM& vm, JSObject* thisObj, const std::vector<JSValue>& args);
        JSFunction (Bytecode::CodeBlock& codeBlock, Bytecode::FunctionID functionID, BuiltinFunction builtinImpl = nullptr)
            : m_codeBlock(codeBlock), m_functionID(functionID), m_builtinImpl(builtinImpl)
        {
            m_functionID = m_codeBlock.id;
        }
        ~JSFunction() override = default;
        Kind kind() const override { return Kind::Function; }


        JSValue call(VM& vm, JSObject* thisObj, const std::vector<JSValue>& args) {
            if (m_builtinImpl) {
                return m_builtinImpl(vm, thisObj, args);
            }

            return JSValue::undefined();
        }



        Bytecode::FunctionID functionID() const { return m_functionID; }


        void putNativeImpl(BuiltinFunction impl) {
            m_builtinImpl = impl;
        }

    private:
        Bytecode::CodeBlock& m_codeBlock;
        Bytecode::FunctionID m_functionID {0xFFFFFFFF};
        BuiltinFunction m_builtinImpl {nullptr};
    };
}
