#pragma once

#include <memory>
#include <utility>

#include "Bytecodes/Decoder.h"
#include "GC/Heap.h"


namespace JSBackend {
    namespace Bytecode {
        struct DecodeResult;
    }
    namespace Interpreter {
        class Interpreter;
    }
    namespace Runtime {
        class GlobalObject;
    }

    class VM {
    public:
        explicit VM(Bytecode::DecodeResult decodeResult);
        ~VM();

        Runtime::GlobalObject* globalObject() const { return m_globalObject;}
        GarbageCollector::Heap& heap() { return m_heap; }

        template <typename T, typename... Args>
        T* allocate(Args&&... args) {
            return m_heap.allocate<T>(std::forward<Args>(args)...);
        }

        void initialize();
        void run();

    private:
        Runtime::GlobalObject* m_globalObject {nullptr};
        Interpreter::Interpreter* m_interpreter;
        GarbageCollector::Heap m_heap;
    };
}
