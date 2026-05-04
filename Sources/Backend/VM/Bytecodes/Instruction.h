#pragma once

#include "Bytecodes.h"

namespace JSBackend::Interpreter {
    class Instruction {
    public:
        virtual ~Instruction() = default;
        void setOffset(uint32_t offset) {this->offset = offset;}
        uint32_t Offset() const {return offset;}
        uint32_t offset = 0;
    };


#define OPERAND_EXPANDER(TYPE, NAME)        \
    public:                                 \
    void set_##NAME(TYPE param) {m_##NAME = 0;}  \
    TYPE NAME() {return m_##NAME;}         \
    private:                                \
    TYPE m_##NAME = 0;

#define INSTRUCTION_CLASSES(NAME, OPERANDS)         \
    class NAME##Instruction : public Instruction {  \
       OPERANDS(OPERAND_EXPANDER)                     \
       public:                                      \
       Bytecode::Op OpType() {return Bytecode::Op::NAME;}      \
    };

    BC_ALL(INSTRUCTION_CLASSES)

}





