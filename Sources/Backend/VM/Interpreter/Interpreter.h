#pragma once
#include <cstdint>
#include <unordered_map>
#include <utility>
#include <vector>

#include "../Bytecodes/CodeBlock.h"
#include "../Bytecodes/Decoder.h"
#include "../Bytecodes/Instruction.h"
#include "Register.h"

// may cause cyclic dependency:
#include "../VM.h"

namespace JSBackend::Interpreter {
    class Interpreter{
    public:
        explicit Interpreter(VM& _vm, Bytecode::DecodeResult decodeResult) : vm(_vm) {
            // Initialize 256 registers
            m_offsetToLogicalAddress = std::move(decodeResult.offsetToLogicalAddress);
            m_functionTable = std::move(decodeResult.functionTable);
            m_globalCodeBlock = std::move(decodeResult.globalCodeBlock);
            m_currentCodeBlock = &m_globalCodeBlock;
            m_functionCodeBlocks = std::move(decodeResult.functionCodeBlocks);
            m_registers = std::vector<Register>(256, Register(this, 0)); // Initialize 256 registers with index 0
            for (size_t i = 0; i < m_registers.size(); ++i) {
                m_registers[i] = Register(this, static_cast<uint16_t>(i));
            }
        }

        Bytecode::Instruction* nextInstruction() {
            if (m_currentCodeBlock == nullptr) {
                return nullptr;
            }

            if (m_instructionPointer >= m_currentCodeBlock->instructions.size()) {
                return nullptr;
            }

            return m_currentCodeBlock->instructions.at(m_instructionPointer++);
        }

        void executeCodeBlock(Bytecode::CodeBlock* codeBlock) {
            if (m_currentCodeBlock != nullptr) {
                m_executionStack.push_back({
                    m_currentCodeBlock,
                    m_instructionPointer
                });
            }
            m_currentCodeBlock = codeBlock;
            m_instructionPointer = 0;
        }

        void returnToCallerCodeBlock() {
            if (m_executionStack.empty()) {
                haltInterpreter();
                return;
            }

            auto callerState = m_executionStack.back();
            m_executionStack.pop_back();
            m_currentCodeBlock = callerState.codeBlock;
            m_instructionPointer = callerState.instructionPointer;
        }

        void haltInterpreter() {
            m_currentCodeBlock = nullptr;
            m_instructionPointer = 0;
        }

        void run();

        #define DEFINE_BYTECODE_HANDLER(Name, Operands) void execute_##Name(const Bytecode::Name##Instruction* inst);
        BC_ALL(DEFINE_BYTECODE_HANDLER)
        #undef DEFINE_BYTECODE_HANDLER


        std::vector<Register>& registers() { return m_registers; }
        std::unordered_map<uint32_t, uint32_t>& offsetToLogicalAddress() { return m_offsetToLogicalAddress; }

        void setCurrentCodeBlock(Bytecode::CodeBlock* codeBlock) {
            m_currentCodeBlock = codeBlock;

            std::cout << "[+] StartOffset: " << m_currentCodeBlock->startOffset;

            auto it = m_offsetToLogicalAddress.find(m_currentCodeBlock->startOffset);
            if (it == m_offsetToLogicalAddress.end()) {
                throw std::runtime_error("Start offset of code block not found in offsetToLogicalAddress map");
            }

            // Reset instruction pointer when entering a new code block
            m_instructionPointer = it->second;
        }

        Bytecode::CodeBlock& globalCodeBlock() {
            return m_globalCodeBlock;
        }
    private:
        Bytecode::JumpOffset instructionIndexForOffset(Bytecode::JumpOffset targetOffset) const {
            if (m_currentCodeBlock == nullptr) {
                throw std::runtime_error("Cannot resolve jump target without a current code block");
            }
            if (targetOffset < 0) {
                throw std::runtime_error("Invalid negative jump target offset: " + std::to_string(targetOffset));
            }

            const auto absoluteTargetOffset = static_cast<uint32_t>(targetOffset);
            for (size_t index = 0; index < m_currentCodeBlock->instructions.size(); ++index) {
                if (m_currentCodeBlock->instructions[index]->offset() == absoluteTargetOffset) {
                    return static_cast<Bytecode::JumpOffset>(index);
                }
            }

            throw std::runtime_error(
                "Invalid jump target offset " + std::to_string(targetOffset)
                + " for current code block starting at "
                + std::to_string(m_currentCodeBlock->startOffset)
            );
        }

        VM& vm;
        std::vector<Register> m_registers; // Initialize 256 registers

        Bytecode::CodeBlock* m_currentCodeBlock {nullptr};
        Bytecode::JumpOffset m_instructionPointer {0};
        struct ExecutionState {
            Bytecode::CodeBlock* codeBlock {nullptr};
            Bytecode::JumpOffset instructionPointer {0};
        };
        std::vector<ExecutionState> m_executionStack;

        std::unordered_map<uint32_t, uint32_t> m_offsetToLogicalAddress;
        std::unordered_map<Bytecode::FunctionID, uint32_t> m_functionTable;
        Bytecode::CodeBlock m_globalCodeBlock;
        std::unordered_map<Bytecode::FunctionID, Bytecode::CodeBlock> m_functionCodeBlocks;

    };
}
