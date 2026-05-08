#pragma once
#include <vector>
#include "Bytecodes/Instruction.h"

#include "Register.h"
#include "../Bytecodes/Bytecodes.h"
#include "Bytecodes/Decoder.h"

namespace JSBackend::Interpreter {
#define BYTECODE_HANDLER(Name, Operands) void Interpreter::execute##Name(const Instruction& inst);

    class Interpreter {
    public:
        Interpreter(DecodeResult decodeResult) { // Initialize{ 256 registers
            m_offsetToLogicalAddress = std::move(decodeResult.offsetToLogicalAddress),
            m_instructions = std::move(decodeResult.instructions),
            m_functionTable = std::move(decodeResult.functionTable),
            m_constantPool = std::move(decodeResult.constantPool);
        }


        void run();

        #define DEFINE_BYTECODE_HANDLER(Name, Operands) void execute_##Name(const Instruction& inst);
        BC_ALL(DEFINE_BYTECODE_HANDLER)

    private:
        std::vector<Register> m_registers;

        std::unordered_map<uint32_t, uint32_t> m_offsetToLogicalAddress;
        std::vector<Instruction> m_instructions;
        std::unordered_map<FunctionID, uint32_t> m_functionTable;
        std::unordered_map<CPIndex, std::string> m_constantPool;

    };
}
