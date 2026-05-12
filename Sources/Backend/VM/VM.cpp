#include "VM.h"

#include "Bytecodes/Decoder.h"
#include "Interpreter/Interpreter.h"
#include "Runtime/GlobalObject.h"

namespace JSBackend {
    VM::VM(Bytecode::DecodeResult decodeResult)
        : m_interpreter(std::make_unique<Interpreter::Interpreter>(std::move(decodeResult)))
    {
    }

    VM::~VM() = default;

    void VM::initialize()
    {
        m_globalObject = m_heap.allocate<Runtime::GlobalObject>();
    }

    void VM::run()
    {
        m_interpreter->run();
    }
}
