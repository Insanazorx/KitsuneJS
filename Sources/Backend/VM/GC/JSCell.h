#pragma once
#include <cstdint>

#include "Forward.h"

namespace JSBackend::GarbageCollector {
    class Visitor;

    class JSCell {
    public:
        JSCell() = default;
        virtual ~JSCell() = default;

        virtual bool is_cell() const { return true; }

        virtual void get_visited(Visitor& visitor) = 0;

        void mark () { marked = 1; }
        void unmark () { marked = 0; }
        bool is_marked () const { return marked; }

    private:
        JSCell* next {nullptr};
        uint8_t marked : 1 {0};
        uint16_t size : 11 {0};
        uint8_t type_id : 4 {0};
    };

}
