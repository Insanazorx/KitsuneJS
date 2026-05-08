#pragma once

#include "Bytecodes.h"
#include <optional>
#include <string>
#include <sstream>
#include <type_traits>
#include <utility>

namespace JSBackend::Interpreter {
    using namespace Bytecode;

    template <typename T>
    std::string operandToString(const T& value) {
        if constexpr (std::is_same_v<T, uint8_t>) {
            return std::to_string(static_cast<unsigned>(value));
        } else if constexpr (std::is_same_v<T, int8_t>) {
            return std::to_string(static_cast<int>(value));
        } else {
            return std::to_string(value);
        }
    }

    template <typename T>
    std::string operandToString(const std::optional<T>& value) {
        if (!value.has_value()) {
            return "nil";
        }
        return operandToString(*value);
    }

    class Instruction {
    public:
        virtual ~Instruction() = default;
        void setOffset(uint32_t _offset) {this->m_offset = _offset;}
        uint32_t offset() const {return m_offset;}
        virtual Bytecode::Op OpType() const {return Bytecode::Op::unreachable;}
        virtual std::string toString() const {return "Unresolved instruction!";;}
    protected:
        uint32_t m_offset = 0;
    };


#define OPERAND_MEMBER_EXPANDER(TYPE, NAME)        \
    public:                                 \
    void set_##NAME(TYPE param) {m_##NAME = std::move(param);}  \
    const TYPE& NAME() const {return m_##NAME;}         \
    TYPE& NAME() {return m_##NAME;}         \
    private:                                \
    TYPE m_##NAME{};

#define OPERAND_TOSTRING_EXPANDER(TYPE, NAME) \
    + " " + #NAME + ": " + operandToString(m_##NAME)

#define INSTRUCTION_CLASSES(NAME, OPERANDS)         \
    class NAME##Instruction : public Instruction {  \
       OPERANDS(OPERAND_MEMBER_EXPANDER)                     \
       public:                                      \
       Bytecode::Op OpType() const override {return Bytecode::Op::NAME;}      \
       std::string toString() const override {      \
         std::ostringstream oss;                    \
         oss << "[0x" << std::hex << Instruction::offset() << "]"; \
        return oss.str()                           \
        + " " + #NAME                            \
        OPERANDS(OPERAND_TOSTRING_EXPANDER);    \
       }                                        \
    };

    BC_ALL(INSTRUCTION_CLASSES)

#undef INSTRUCTION_CLASSES
#undef OPERAND_MEMBER_EXPANDER
#undef OPERAND_TOSTRING_EXPANDER
}



