#pragma once

#include <cstdint>
#include <limits>
#include <string>
#include <unordered_map>
#include <vector>

#include "Bytecodes.h"
#include "Instruction.h"

namespace JSBackend::Runtime {
    class CallFrame;
}

namespace JSBackend::Bytecode {
    class CodeBlock {
    public:
        static constexpr uint32_t GlobalCodeBlockID = std::numeric_limits<uint32_t>::max();

        CodeBlock() = default;

        explicit CodeBlock(uint32_t id)
            : id(id)
        {
        }

        [[nodiscard]] bool isGlobal() const
        {
            return id == GlobalCodeBlockID;
        }





        Runtime::CallFrame* callFrame() const {
            return m_callFrame;
        }

        void set_callFrame(Runtime::CallFrame *call_frame) {
            m_callFrame = call_frame;
        }

        std::string get_from_constant_pool(CPIndex index) {
            auto it = constantPool.find(index);
            if (it == constantPool.end()) {
                throw std::runtime_error("Constant pool index " + std::to_string(index) + " not found");
            }
            return it->second;

        }


        uint32_t id {GlobalCodeBlockID};
        uint32_t startOffset {0};
        uint32_t endOffset {0};
        Runtime::CallFrame* m_callFrame;
        std::vector<Instruction*> instructions;
        std::unordered_map<CPIndex, std::string> constantPool;
    };
}
