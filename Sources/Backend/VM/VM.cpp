#include "VM.h"

#include "Bytecodes/Decoder.h"
#include "Interpreter/Interpreter.h"
#include "Runtime/GlobalObject.h"

//may cause cyclic dependency:
#include "Runtime/Environment.h"

namespace JSBackend {
    VM::VM(Bytecode::DecodeResult decodeResult)
        : m_interpreter(new Interpreter::Interpreter(*this, std::move(decodeResult))) {
    }

    VM::~VM() = default;

    void VM::initialize()
    {
        m_globalObject = m_heap.allocate<Runtime::GlobalObject>();
        m_globalObject->setGlobalEnvironment(m_heap.allocate<Runtime::Environment>());

    }

    void VM::run()
    {
        m_interpreter->run();
    }
}
