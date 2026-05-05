
#include "Decoder.h"



namespace JSBackend::Bytecode {
    #define BC_HANDLER_CASE(NAME, OPERANDS) \
    case Op::NAME: \
        auto bytes = readBytes() \
        decode_##NAME(bytes);

    void Decoder::decode() {
        while (hasMore()) {
            uint8_t opByte = readByte();
            Op op = static_cast<Op>(opByte);
            switch (op) {
                BC_ALL(BC_HANDLER_CASE)
            default:
                throw std::runtime_error("Unknown opcode: " + std::to_string(opByte));
            }
        }
    }
    #define DEFINE_HANDLER(NAME, OPERANDS) Interpreter::Instruction decode_##NAME(const uint8_t[instructionLength(Op::NAME)] bytes)


}
