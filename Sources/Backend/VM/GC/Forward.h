#pragma once
#include <cstdint>

namespace JSBackend::GarbageCollector {
    enum class HeapType : uint8_t {
        TYPE_OBJECT = 0,
        TYPE_ARRAY = 1,
        TYPE_FUNCTION = 2,
        TYPE_STRING = 3,
        TYPE_NUMBER = 4,
        TYPE_BOOLEAN = 5,
        TYPE_NULL = 6,
        TYPE_UNDEFINED = 7,
        TYPE_SYMBOL = 8,
        TYPE_BIGINT = 9,
        TYPE_HIDDEN_CLASS = 10,
        TYPE_CONSTANT_POOL = 11,
        TYPE_ENVIRONMENT_RECORD = 12,
        TYPE_RESERVED_4,
        TYPE_RESERVED_5,
        TYPE_RESERVED_6,
    };
    inline int align_size(size_t size) {
        const int alignment = 16;
        return (size + alignment - 1) & ~(alignment - 1);
    }
};
