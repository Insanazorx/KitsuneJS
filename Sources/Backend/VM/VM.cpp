#include "VM.h"

#include "Bytecodes/Decoder.h"
#include "Interpreter/Interpreter.h"
#include "Runtime/GlobalObject.h"

//may cause cyclic dependency:
#include "Runtime/CallFrame.h"
#include "Runtime/ConsoleObject.h"
#include "Runtime/Environment.h"
#include "Runtime/JSFunction.h"

namespace JSBackend {
    VM::VM(Bytecode::DecodeResult decodeResult)
        : m_interpreter(new Interpreter::Interpreter(*this, std::move(decodeResult))) {
    }

    VM::~VM() = default;

    void VM::initialize()
    {
        m_globalObject = m_heap.allocate<Runtime::GlobalObject>(this);
        auto globalObjJSValue = Runtime::JSValue::cell(m_globalObject);

        m_interpreter->globalCodeBlock().set_callFrame(new Runtime::CallFrame());

        m_interpreter->globalCodeBlock().callFrame()->set_thisValue(globalObjJSValue);

        if (!m_globalObject) {
            throw std::runtime_error("Failed to allocate GlobalObject");
        }


    }

    void VM::run()
    {
        m_interpreter->run();
    }
}
