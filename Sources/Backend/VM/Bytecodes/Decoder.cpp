
#include "Decoder.h"

#include <iostream>

namespace JSBackend::Bytecode {

    void Decoder::decode() {
        verifyHeader();
        decodeSectionTable();

        verifySectionSeparator();
        if (m_offset != m_instructionsStartOffset) {
            throw std::runtime_error("Invalid bytecode: code section offset mismatch");
        }
        decodeInstructions();

        verifySectionSeparator();
        if (m_offset != m_functionTableStartOffset) {
            throw std::runtime_error("Invalid bytecode: function table section offset mismatch");
        }
        decodeFunctionTable();

        verifySectionSeparator();
        if (m_offset != m_constantPoolStartOffset) {
            throw std::runtime_error("Invalid bytecode: constant pool section offset mismatch");
        }
        decodeConstantPools();

        if (m_offset != m_length) {
            throw std::runtime_error("Invalid bytecode: trailing bytes after constant pools");
        }

        buildCodeBlocks();
    }

    void Decoder::verifyHeader() {

        auto bytes = readBytes(12);

        if (bytes.size() < 12) {
            throw std::runtime_error("Invalid bytecode: insufficient header length");
        }

        std::vector<uint8_t> expectedHeader = {
            0xDE, 0xAD, 0xBE, 0xEF,
            0xCA, 0xFE, 0xBA, 0xBE,
            0xFE, 0xED, 0xFA, 0xCE
        };

        std::span expectedHeaderSpan(expectedHeader);

        if (!equalsAtOffset(m_bytecodes, expectedHeaderSpan,0)) {
            throw std::runtime_error("Invalid bytecode: header mismatch");
        }

        readBytes(2); // Skip version

        readBytes(2); // Skip reserved or flags

    }

    void Decoder::verifySectionSeparator() {
        const auto separator = readBytes(16);
        std::vector<uint8_t> expectedSeparator = {
            0xFF, 0xFF, 0xFF, 0xFF,
            0xCA, 0xFE, 0xBA, 0xBE,
            0xDE, 0xAD, 0xBE, 0xEF,
            0xFF, 0xFF, 0xFF, 0xFF
        };
        if (separator != expectedSeparator) {
            throw std::runtime_error("Invalid bytecode: section separator mismatch");
        }
    }

    void Decoder::decodeSectionTable() {
        m_instructionsStartOffset = readUint32();
        m_functionTableStartOffset = readUint32();
        m_constantPoolStartOffset = readUint32();

        if (m_instructionsStartOffset > m_length ||
            m_functionTableStartOffset > m_length ||
            m_constantPoolStartOffset > m_length) {
            throw std::runtime_error("Invalid bytecode: section table offset out of range");
        }
        if (m_functionTableStartOffset < m_instructionsStartOffset ||
            m_constantPoolStartOffset < m_functionTableStartOffset) {
            throw std::runtime_error("Invalid bytecode: section table offsets are not ordered");
        }
    }

    void Decoder::decodeFunctionTable() {
        if (m_constantPoolStartOffset < SectionSeparatorSize) {
            throw std::runtime_error("Invalid bytecode: constant pool section offset is too small");
        }

        const auto functionTableEnd = static_cast<size_t>(m_constantPoolStartOffset) - SectionSeparatorSize;
        if ((functionTableEnd - m_offset) % 8 != 0) {
            throw std::runtime_error("Invalid bytecode: malformed function table length");
        }

        while (m_offset < functionTableEnd) {
            auto id = readUint32();
            auto offset = readUint32();
            putFunctionTableEntry(id, offset);
        }
    }

    void Decoder::decodeConstantPools() {
        auto readSingleCPEntry = [this](uint32_t codeBlockId) {
            auto marker = readBytes(4);
            auto pattern = std::vector<uint8_t>(ConstantPoolEntryMarker.begin(), ConstantPoolEntryMarker.end());
            if (marker != pattern) {
                throw std::runtime_error("Invalid bytecode: constant pool entry marker mismatch");
            }
            auto cpIndex = readUint32();
            auto value = readString();

            putConstantPoolEntry(codeBlockId, cpIndex, value);
        };

        const auto codeBlockPoolCount = readUint32();
        for (uint32_t poolIndex = 0; poolIndex < codeBlockPoolCount; ++poolIndex) {
            auto marker = readBytes(4);
            auto pattern = std::vector<uint8_t>(
                CodeBlockConstantPoolMarker.begin(),
                CodeBlockConstantPoolMarker.end()
            );
            if (marker != pattern) {
                throw std::runtime_error("Invalid bytecode: code block constant pool marker mismatch");
            }

            const auto codeBlockId = readUint32();
            if (codeBlockId != Runtime::CodeBlock::GlobalCodeBlockID && !m_result.functionTable.contains(codeBlockId)) {
                throw std::runtime_error("Invalid bytecode: constant pool for unknown function code block id " + std::to_string(codeBlockId));
            }

            const auto constantsCount = readUint32();
            for (uint32_t entryIndex = 0; entryIndex < constantsCount; ++entryIndex) {
                readSingleCPEntry(codeBlockId);
            }
        }
    }

    void Decoder::buildCodeBlocks() {
        if (m_functionTableStartOffset < SectionSeparatorSize) {
            throw std::runtime_error("Invalid bytecode: function table section offset is too small");
        }

        const auto codeEnd = static_cast<uint32_t>(m_functionTableStartOffset - SectionSeparatorSize);

        std::vector<std::pair<FunctionID, uint32_t>> functionStarts(
            m_result.functionTable.begin(),
            m_result.functionTable.end()
        );
        std::ranges::sort(functionStarts, [](const auto& lhs, const auto& rhs) {
            return lhs.second < rhs.second;
        });

        m_result.globalCodeBlock.id = Runtime::CodeBlock::GlobalCodeBlockID;
        m_result.globalCodeBlock.startOffset = m_instructionsStartOffset;
        m_result.globalCodeBlock.endOffset = functionStarts.empty() ? codeEnd : functionStarts.front().second;

        if (m_result.globalCodeBlock.endOffset < m_result.globalCodeBlock.startOffset ||
            m_result.globalCodeBlock.endOffset > codeEnd) {
            throw std::runtime_error("Invalid bytecode: malformed global code block range");
        }

        for (size_t index = 0; index < functionStarts.size(); ++index) {
            const auto [functionId, startOffset] = functionStarts[index];
            const auto endOffset = index + 1 < functionStarts.size()
                ? functionStarts[index + 1].second
                : codeEnd;

            if (startOffset < m_instructionsStartOffset || startOffset > codeEnd || endOffset < startOffset) {
                throw std::runtime_error("Invalid bytecode: malformed function code block range for id " + std::to_string(functionId));
            }

            auto& codeBlock = m_result.functionCodeBlocks[functionId];
            codeBlock.id = functionId;
            codeBlock.startOffset = startOffset;
            codeBlock.endOffset = endOffset;
        }

        auto attachInstruction = [](Runtime::CodeBlock& codeBlock, Interpreter::Instruction* instruction) {
            const auto offset = instruction->offset();
            if (offset >= codeBlock.startOffset && offset < codeBlock.endOffset) {
                codeBlock.instructions.push_back(instruction);
            }
        };

        for (auto* instruction : m_result.instructions) {
            attachInstruction(m_result.globalCodeBlock, instruction);

            for (auto& [_, codeBlock] : m_result.functionCodeBlocks) {
                attachInstruction(codeBlock, instruction);
            }
        }
    }


#define BC_HANDLER_CASE(NAME, OPERANDS) \
    case Op::NAME: \
        decode_##NAME(); \
        break;


    void Decoder::decodeInstructions() {
        if (m_functionTableStartOffset < SectionSeparatorSize) {
            throw std::runtime_error("Invalid bytecode: function table section offset is too small");
        }

        const auto codeEnd = static_cast<size_t>(m_functionTableStartOffset) - SectionSeparatorSize;
        while (hasMore(codeEnd)) {
            uint8_t opByte = m_bytecodes[m_offset];
            switch (static_cast<Op>(opByte)) {
                BC_ALL(BC_HANDLER_CASE)
            default:
                throw std::runtime_error("Invalid bytecode: unknown opcode " + std::to_string(opByte) +
                                         " at offset " + std::to_string(m_offset));
            }

            if (m_offset > codeEnd) {
                throw std::runtime_error("Invalid bytecode: instruction crosses code section boundary");
            }
        }
    }

#undef BC_HANDLER_CASE


#define READ_OPERAND(TYPE, NAME) \
    instruction->set_##NAME(readOperand<TYPE>());

#define DEFINE_HANDLER(NAME, OPERANDS) \
    void Decoder::decode_##NAME() { \
        auto instruction = new Interpreter::NAME##Instruction(); \
        instruction->setOffset(m_offset); \
        readByte();    \
        try {                                   \
            OPERANDS(READ_OPERAND)                \
        } catch(std::exception& e) {                           \
            throw std::runtime_error(std::string("Invalid bytecode: in handler of " + std::string(#NAME) + ": " + e.what()) + " offset: " + std::to_string(m_offset));                                        \
        }                                         \
        putInstruction(std::move(instruction)); \
    }

    BC_ALL(DEFINE_HANDLER)

#undef DEFINE_HANDLER
#undef READ_OPERAND

    void DecodeResult::print() const {
            const auto previousFlags = std::cout.flags();
            std::cout << "Decoded Bytecode:\n";

            std::cout << "Instructions:\n";
            for (const auto& instr : instructions) {
                std::cout << std::hex << instr->offset() << "  " << instr->toString() << "\n";
            }
            std::cout << std::dec;
            std::cout << "Function Table:\n";
            for (const auto& entry : functionTable) {
                std::cout << "  ID: " << entry.first << ", Offset: " << entry.second << "\n";
            }

            auto printCodeBlock = [](const char* label, const Runtime::CodeBlock& codeBlock) {
                std::cout << label << " CodeBlock"
                          << " [0x" << std::hex << codeBlock.startOffset
                          << ", 0x" << codeBlock.endOffset << std::dec << "):\n";

                std::cout << "  Instructions:\n";
                for (const auto* instr : codeBlock.instructions) {
                    std::cout << "    " << instr->toString() << "\n";
                }

                std::cout << "  Constant Pool:\n";
                for (const auto& entry : codeBlock.constantPool) {
                    std::cout << "    Index: " << entry.first << ", Value: " << entry.second << "\n";
                }
            };

            printCodeBlock("Global", globalCodeBlock);
            for (const auto& [functionId, codeBlock] : functionCodeBlocks) {
                const auto label = std::string("Function ") + std::to_string(functionId);
                printCodeBlock(label.c_str(), codeBlock);
            }
            std::cout.flags(previousFlags);
    }
}
