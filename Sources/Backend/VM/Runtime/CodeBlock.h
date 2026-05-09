#pragma once

#include <cstdint>
#include <limits>
#include <string>
#include <unordered_map>
#include <vector>

#include "../Bytecodes/Bytecodes.h"
#include "../Bytecodes/Instruction.h"

namespace JSBackend::Runtime {

class CodeBlock {
public:
    static constexpr uint32_t GlobalCodeBlockID = std::numeric_limits<uint32_t>::max();

    CodeBlock() = default;

    explicit CodeBlock(uint32_t id)
        : id(id)
    {
    }

    bool isGlobal() const
    {
        return id == GlobalCodeBlockID;
    }

    uint32_t id = GlobalCodeBlockID;
    uint32_t startOffset = 0;
    uint32_t endOffset = 0;
    std::vector<Interpreter::Instruction*> instructions;
    std::unordered_map<Bytecode::CPIndex, std::string> constantPool;
};

}
