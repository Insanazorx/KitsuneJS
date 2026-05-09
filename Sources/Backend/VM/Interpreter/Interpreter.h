#pragma once
#include <vector>
#include "Bytecodes/Instruction.h"

#include "Register.h"
#include "../Bytecodes/Bytecodes.h"
#include "Bytecodes/Decoder.h"

namespace JSBackend {
    class VM;
}

namespace JSBackend::Interpreter {
#define BYTECODE_HANDLER(Name, Operands) void Interpreter::execute##Name(const Instruction& inst);

    class Interpreter{
    public:
        explicit Interpreter(VM& vm, DecodeResult decodeResult) : vm(vm) {
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

        #define DEFINE_BYTECODE_HANDLER(Name, Operands) void execute_##Name(const Name##Instruction* inst);
        BC_ALL(DEFINE_BYTECODE_HANDLER)
        #undef DEFINE_BYTECODE_HANDLER

    private:
        VM& vm;
        std::vector<Register> m_registers; // Initialize 256 registers

        std::unordered_map<uint32_t, uint32_t> m_offsetToLogicalAddress;
        std::unordered_map<FunctionID, uint32_t> m_functionTable;
        Runtime::CodeBlock m_globalCodeBlock;
        std::unordered_map<FunctionID, Runtime::CodeBlock> m_functionCodeBlocks;

    };
}
