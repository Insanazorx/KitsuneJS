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
        class Environment;
        class GlobalObject;
    }

    class VM {
    public:
        explicit VM(Bytecode::DecodeResult decodeResult);
        ~VM();

        Interpreter::Interpreter& interpreter() { return *m_interpreter; }
        Runtime::GlobalObject* globalObject() const { return m_globalObject;}
        GarbageCollector::Heap& heap() { return m_heap; }

        Runtime::CallFrame* currentCallFrame() const {
            if (m_callStack.empty()) {
                return nullptr;
            }
            return m_callStack.back();
        }

        Runtime::CallFrame* pushCallFrame(Runtime::CallFrame* callFrame) {
            m_callStack.push_back(callFrame);
            return callFrame;
        }
        void popCallFrame() {
            if (!m_callStack.empty()) {
                m_callStack.pop_back();
            }
        }

        void setCurrentEnvironment(Runtime::Environment* env) {
            m_currentEnv = env;
        }

        Runtime::Environment* currentEnvironment() const {
            return m_currentEnv;
        }

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
        std::vector<Runtime::CallFrame*> m_callStack;
        Runtime::Environment* m_currentEnv{nullptr};
    };
}
