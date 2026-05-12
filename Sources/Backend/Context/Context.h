#pragma once

#include <cstddef>
#include <cstdint>
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

    bool loadSerializedBytecode(const std::uint8_t* bytes, std::size_t length) noexcept;

    bool run() noexcept;

    void reset() noexcept;

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
