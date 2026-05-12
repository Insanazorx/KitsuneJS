#pragma once
#include <cstdint>
#include <unordered_map>
#include <utility>
#include <vector>

#include "Bytecodes/CodeBlock.h"
#include "Bytecodes/Decoder.h"
#include "Bytecodes/Instruction.h"
#include "Register.h"

namespace JSBackend::Interpreter {
    class Interpreter{
    public:
        explicit Interpreter(Bytecode::DecodeResult decodeResult) {
            // Initialize{ 256 registers
            m_offsetToLogicalAddress = std::move(decodeResult.offsetToLogicalAddress);
            m_functionTable = std::move(decodeResult.functionTable);
            m_globalCodeBlock = std::move(decodeResult.globalCodeBlock);
            m_functionCodeBlocks = std::move(decodeResult.functionCodeBlocks);
            m_registers = std::vector<Register>(256, Register(this, 0)); // Initialize 256 registers with index 0
            for (size_t i = 0; i < m_registers.size(); ++i) {
                m_registers[i] = Register(this, static_cast<uint16_t>(i));
            }
        }

        void run();

        #define DEFINE_BYTECODE_HANDLER(Name, Operands) void execute_##Name(const Bytecode::Name##Instruction* inst);
        BC_ALL(DEFINE_BYTECODE_HANDLER)
        #undef DEFINE_BYTECODE_HANDLER

    private:
        std::vector<Register> m_registers; // Initialize 256 registers

        std::unordered_map<uint32_t, uint32_t> m_offsetToLogicalAddress;
        std::unordered_map<Bytecode::FunctionID, uint32_t> m_functionTable;
        Bytecode::CodeBlock m_globalCodeBlock;
        std::unordered_map<Bytecode::FunctionID, Bytecode::CodeBlock> m_functionCodeBlocks;

    };
}
