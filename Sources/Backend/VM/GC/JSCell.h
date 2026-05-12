#pragma once
#include <cstdint>

namespace JSBackend::GarbageCollector {
    class Visitor;

    class JSCell {
    public:
        enum class Kind : uint8_t {
            Cell,
            Object,
            Array,
            Function,
            String,
            Symbol,
            BigInt,
            Environment
        };

        JSCell() = default;
        virtual ~JSCell() = default;

        virtual bool is_cell() const { return true; }
        virtual Kind kind() const { return Kind::Cell; }

        virtual void visit(Visitor& visitor) {}

        void mark () { marked = 1; }
        void unmark () { marked = 0; }
        bool is_marked () const { return marked; }

    protected:
        JSCell* next {nullptr};
        uint8_t marked : 1 {0};
        uint16_t size : 11 {0};
        uint8_t type_id : 4 {0};
    };

}
