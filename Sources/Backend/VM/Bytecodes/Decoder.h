#pragma once
#include <stdexcept>
#include <utility>
#include <vector>
#include "Instruction.h"

namespace JSBackend::Bytecode {
    class Decoder {
    public:
        Decoder(std::vector<uint8_t> bytecode, size_t length)
            : m_bytecode(std::move(bytecode)), m_length(length), m_offset(0) {}

        void decode();

    private:
#define DEFINE_DECODER(NAME, OPERANDS) Interpreter::Instruction decode_##NAME(std::vector<uint8_t> bytes);
        BC_ALL(DEFINE_DECODER)
#undef DEFINE_DECODER

        bool hasMore() const {
            return m_offset < m_length;
        }

        uint8_t readByte() {
            if (m_offset >= m_length) {
                throw std::out_of_range("Attempt to read beyond bytecode length");
            }
            return m_bytecode[m_offset++];
        }

        template <int N>
        std::vector<uint8_t> readBytes() {
            if (m_offset + N > m_length) {
                throw std::out_of_range("Attempt to read beyond bytecode length");
            }
            std::vector<uint8_t> bytes(m_bytecode.begin() + m_offset, m_bytecode.begin() + m_offset + N);
            m_offset += N;
            return bytes;
        }



    private:
        std::vector<std::uint8_t> m_bytecode;
        size_t m_length;
        size_t m_offset;
    };

}
