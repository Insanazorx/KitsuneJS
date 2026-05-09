#pragma once

#include "Bytecodes/Decoder.h"
#include "Interpreter/Interpreter.h"



namespace JSBackend {
    namespace Runtime {
        class GlobalObject;
    }
    namespace GarbageCollector {
        class Heap;
    }

    class VM {
    public:
        explicit VM(Bytecode::DecodeResult decodeResult)
            : m_interpreter(*this,std::move(decodeResult))
        {}

        Runtime::GlobalObject* globalObject() const { return m_globalObject; }
        GarbageCollector::Heap& heap() { return m_heap; }


        void initialize() {
            m_globalObject = Runtime::GlobalObject::Create(*this);

        }
        void run() {

            m_interpreter.run();
        }

    private:
        Runtime::GlobalObject* m_globalObject;
        Interpreter::Interpreter m_interpreter;
        GarbageCollector::Heap m_heap;
    };
}
