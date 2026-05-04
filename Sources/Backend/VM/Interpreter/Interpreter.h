#pragma once
#include <vector>
#include "Bytecodes/Instruction.h"

#include "Register.h"
#include "../Bytecodes/Bytecodes.h"

namespace JSBackend::Interpreter {
#define BYTECODE_HANDLER(Name, Operands) void Interpreter::execute##Name(const Instruction& inst);

    class Interpreter {
    public:
        void run();

        #define DEFINE_BYTECODE_HANDLER(Name, Operands) void execute##Name(const Instruction& inst);
        BC_ALL(DEFINE_BYTECODE_HANDLER)
    private:

        std::vector<Register> m_registers;


    };
}