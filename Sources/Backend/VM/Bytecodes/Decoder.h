#pragma once
#include <algorithm>
#include <array>
#include <bit>
#include <cstddef>
#include <cstdint>
#include <limits>
#include <memory>
#include <optional>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <unordered_map>
#include <utility>
#include <vector>
#include <span>

#include "Bytecodes.h"
#include "CodeBlock.h"
#include "Instruction.h"

namespace JSBackend::Bytecode {



    struct DecodeResult {
        std::unordered_map<uint32_t, uint32_t> offsetToLogicalAddress;
        std::vector<Instruction*> instructions;
        std::unordered_map<FunctionID, uint32_t> functionTable;
        std::unordered_map<CPIndex, std::string> constantPool;
        CodeBlock globalCodeBlock;
        std::unordered_map<FunctionID, CodeBlock> functionCodeBlocks;

        void print() const;
    };

    class Decoder {
    public:
        Decoder(std::vector<uint8_t> bytecode, size_t length)
            : m_bytecodes(std::move(bytecode)), m_length(std::min(length, m_bytecodes.size())), m_offset(0) {}

        void decode();
        const DecodeResult& result() const { return m_result; }

    private:
#define DEFINE_DECODER(NAME, OPERANDS) void decode_##NAME();
        BC_ALL(DEFINE_DECODER)
#undef DEFINE_DECODER

        static constexpr size_t SectionSeparatorSize = 16;
        static constexpr std::array<uint8_t, 4> CodeBlockConstantPoolMarker = {0xC0, 0xDE, 0xB1, 0x0C};
        static constexpr std::array<uint8_t, 4> ConstantPoolEntryMarker = {0xFA, 0xCE, 0xFA, 0xCE};

        template <typename T>
        struct IsOptional : std::false_type {};

        template <typename T>
        struct IsOptional<std::optional<T>> : std::true_type {};

        template <typename>
        static constexpr bool AlwaysFalse = false;

        bool hasMore(size_t limit) const {
            return m_offset < limit;
        }

        bool equalsAtOffset(
            std::span<uint8_t> data,
            std::span<uint8_t> pattern,
            size_t offset)
        {

            if (offset > data.size()) return false;
            if (pattern.size() > data.size() - offset) return false;

            return std::ranges::equal(
                data.subspan(offset, pattern.size()),
                pattern
                );
        }

        uint8_t readByte() {
            if (m_offset >= m_length) {
                throw std::out_of_range("Attempt to read beyond bytecode length");
            }
            return m_bytecodes[m_offset++];
        }

        uint16_t readUint16() {
            if (m_offset + 2 > m_length) {
                throw std::out_of_range("Attempt to read beyond bytecode length");
            }
            const auto cursor = m_offset;
            m_offset += 2;
            return static_cast<uint16_t>(m_bytecodes[cursor]) |
                    (static_cast<uint16_t>(m_bytecodes[cursor + 1]) << 8);
        }

        uint32_t readUint32() {
            if (m_offset + 4 > m_length) {
                throw std::out_of_range("Attempt to read beyond bytecode length");
            }
            const auto cursor = m_offset;
            m_offset += 4;
            return static_cast<uint32_t>(m_bytecodes[cursor]) |
                    (static_cast<uint32_t>(m_bytecodes[cursor + 1]) << 8) |
                    (static_cast<uint32_t>(m_bytecodes[cursor + 2]) << 16) |
                    (static_cast<uint32_t>(m_bytecodes[cursor + 3]) << 24);
        }

        int32_t readInt32() {
            return std::bit_cast<int32_t>(readUint32());
        }

        template <typename T>
        T readOperand() {
            if constexpr (IsOptional<T>::value) {
                using ValueType = typename T::value_type;

                const auto indicator = readByte();
                if (indicator == 0) {
                    return std::nullopt;
                }
                if (indicator == 1) {
                    return readOperand<ValueType>();
                }
                throw std::runtime_error("invalid optional operand indicator: " + std::to_string(indicator));
            } else if constexpr (std::is_same_v<T, uint8_t>) {
                return readByte();
            } else if constexpr (std::is_same_v<T, uint16_t>) {
                return readUint16();
            } else if constexpr (std::is_same_v<T, uint32_t>) {
                return readUint32();
            } else if constexpr (std::is_same_v<T, int32_t>) {
                return readInt32();
            } else {
                static_assert(AlwaysFalse<T>, "Unsupported bytecode operand type");
            }
        }

        void verifySectionSeparator();

        void decodeSectionTable();

        void decodeInstructions();

        void decodeFunctionTable();

        void decodeConstantPools();

        void buildCodeBlocks();

        void verifyHeader();

        void putInstruction(Instruction* instruction) {
            const auto offset = instruction->offset();
            m_result.instructions.push_back(instruction);
            m_result.offsetToLogicalAddress.emplace(offset, m_result.instructions.size() - 1);
        }

        void putFunctionTableEntry(FunctionID id, uint32_t offset) {
            if (!m_result.functionTable.emplace(id, offset).second) {
                throw std::runtime_error("Invalid bytecode: duplicate function table entry for id " + std::to_string(id));
            }

            auto& codeBlock = m_result.functionCodeBlocks[id];
            codeBlock.id = id;

        }

        void putConstantPoolEntry(uint32_t codeBlockId, CPIndex index, std::string value) {
            if (codeBlockId == CodeBlock::GlobalCodeBlockID) {
                m_result.globalCodeBlock.constantPool.emplace(index, value);
                m_result.constantPool.emplace(index, std::move(value));
                return;
            }

            auto& codeBlock = m_result.functionCodeBlocks[codeBlockId];
            codeBlock.id = codeBlockId;
            codeBlock.constantPool.emplace(index, std::move(value));
        }

        std::vector<uint8_t> readBytes(size_t count) {
            if (count == 0) return {};
            if (m_offset + count > m_length) {
                throw std::out_of_range("Attempt to read beyond bytecode length");
            }
            std::vector<uint8_t> bytes(m_bytecodes.begin() + m_offset, m_bytecodes.begin() + m_offset + count);
            m_offset += count;
            return bytes;
        }

        std::string readString() { // Read a null-terminated string
            const auto start = m_offset;
            while (m_offset < m_length && m_bytecodes[m_offset] != 0) {
                ++m_offset;
            }

            if (m_offset >= m_length) {
                throw std::out_of_range("Attempt to read unterminated string beyond bytecode length");
            }

            std::string str(m_bytecodes.begin() + start, m_bytecodes.begin() + m_offset);
            ++m_offset;
            return str;
        }




    private:
        std::vector<std::uint8_t> m_bytecodes;
        DecodeResult m_result;

        uint32_t m_instructionsStartOffset = std::numeric_limits<uint32_t>::max();
        uint32_t m_functionTableStartOffset = std::numeric_limits<uint32_t>::max();
        uint32_t m_constantPoolStartOffset = std::numeric_limits<uint32_t>::max();

        size_t m_length;
        size_t m_offset;
    };

}
