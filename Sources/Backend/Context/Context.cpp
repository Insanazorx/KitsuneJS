#include "Context.h"

#include <exception>
#include <iostream>

#include "VM.h"
#include "Bytecodes/Decoder.h"

namespace JSBackend {
    bool JSContext::loadSerializedBytecode(const std::uint8_t* bytes, std::size_t length) noexcept
    {
        lastError_.clear();

        if (bytes == nullptr && length != 0) {
            lastError_ = "serialized bytecode pointer is null while length is non-zero";
            return false;
        }

        try {
            serializedBytecode_.clear();
            if (length != 0) {
                serializedBytecode_.assign(bytes, bytes + length);
            }
            stage_ = PipelineStage::BytecodeLoaded;
            return true;
        } catch (const std::exception& error) {
            lastError_ = error.what();
        } catch (...) {
            lastError_ = "unknown error while loading serialized bytecode";
        }

        stage_ = PipelineStage::Empty;
        serializedBytecode_.clear();
        return false;
    }

    bool JSContext::run() noexcept
    {
        lastError_.clear();

        if (stage_ == PipelineStage::Empty || serializedBytecode_.empty()) {
            lastError_ = "cannot run backend context before serialized bytecode is loaded";
            return false;
        }

        try {
            std::cout << "Running backend context with " << serializedBytecode_.size() << " bytes of serialized bytecode." << std::endl;

            Bytecode::Decoder decoder(serializedBytecode_, serializedBytecode_.size());
            decoder.decode();
            auto decodeResult = decoder.result();
            decodeResult.print();

            VM vm(std::move(decodeResult));
            vm.initialize();
            vm.run();

            lastRunBytecodeSize_ = serializedBytecode_.size();
            stage_ = PipelineStage::Ran;
            return true;
        } catch (const std::exception& error) {
            lastError_ = error.what();
        } catch (...) {
            lastError_ = "unknown error while running backend context";
        }

        return false;
    }

    void JSContext::reset() noexcept
    {
        serializedBytecode_.clear();
        lastError_.clear();
        lastRunBytecodeSize_ = 0;
        stage_ = PipelineStage::Empty;
    }
}
