#pragma once

#include "Bytecodes.h"

namespace JSBackend::Interpreter {
    class Instruction {
    public:
        virtual ~Instruction() = default;
        uint32_t offset()
    };


#define OPERAND_EXPANDER(TYPE, NAME)        \
    public:                                 \
    void set_##NAME(TYPE param) {NAME = 0}  \
    TYPE get_##NAME() {return NAME}         \
    private:                                \
    TYPE NAME = 0

#define INSTRUCTION_CLASSES(NAME, OPERANDS)         \
    class NAME##Instruction : public Instruction {  \
       BC_ALL(OPERAND_EXPANDER)                     \
       public:                                      \
       Op OpType() {return Op::NAME}                \
    }

}





