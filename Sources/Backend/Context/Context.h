#pragma once

#include <cstddef>
#include <cstdint>
#include <exception>
#include <string>
#include <vector>

namespace JSBackend {

enum class PipelineStage {
    Empty = 0,
    BytecodeLoaded = 1,
    Ran = 2
};

class JSContext {
public:
    JSContext() = default;

    bool loadSerializedBytecode(const std::uint8_t* bytes, std::size_t length) noexcept {
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

    bool run() noexcept {
        lastError_.clear();

        if (stage_ == PipelineStage::Empty || serializedBytecode_.empty()) {
            lastError_ = "cannot run backend context before serialized bytecode is loaded";
            return false;
        }

        try {
            // Backend pipeline entry point:
            // 1. Decode serializedBytecode_ into your bytecode/module format.
            // 2. Create the VM/interpreter instance.
            // 3. Execute the module/function entry block.
            //
            // This placeholder intentionally does not interpret yet; it only marks
            // the run boundary so Swift -> C ABI -> C++ can call context.run().
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

    void reset() noexcept {
        serializedBytecode_.clear();
        lastError_.clear();
        lastRunBytecodeSize_ = 0;
        stage_ = PipelineStage::Empty;
    }

    [[nodiscard]] PipelineStage stage() const noexcept {
        return stage_;
    }

    [[nodiscard]] const std::vector<std::uint8_t>& serializedBytecode() const noexcept {
        return serializedBytecode_;
    }

    [[nodiscard]] std::size_t bytecodeSize() const noexcept {
        return serializedBytecode_.size();
    }

    [[nodiscard]] std::size_t lastRunBytecodeSize() const noexcept {
        return lastRunBytecodeSize_;
    }

    [[nodiscard]] const char* lastError() const noexcept {
        return lastError_.c_str();
    }

private:
    PipelineStage stage_ = PipelineStage::Empty;
    std::vector<std::uint8_t> serializedBytecode_;
    std::string lastError_;
    std::size_t lastRunBytecodeSize_ = 0;
};

}
