#pragma once
#include <vector>

#include "Forward.h"
#include "JSCell.h"

namespace JSBackend::GarbageCollector {

    class Region {
    public:

        static Region* Create(void* mem_base, size_t allocated_space_size) {
            return new Region(mem_base, allocated_space_size);
        }


        ~Region() = default;

        template<typename F>
        void for_each_cell(F&& func) {

        }

        void add_to_free_list(JSCell* new_cell) {
        }

        void* allocate_appropriate_mem_for_cell(size_t size) {
            auto aligned_size = align_size(size);
            if (!has_enough_space(aligned_size)) {
                return nullptr;
            }
            void* allocated_mem = m_bump_ptr;
            m_bump_ptr = static_cast<void*>(
                static_cast<uint8_t*>(m_bump_ptr) + aligned_size
            );
            return allocated_mem;
        }

        bool has_enough_space(size_t size) const {
            auto free_space = m_allocated_space_size - ((uint64_t)m_bump_ptr - (uint64_t)m_mem_base);
            return free_space >= size;
        }

    private:
        Region (void* mem_base, const size_t allocated_space_size) :
            m_mem_base(mem_base),
            m_bump_ptr(mem_base),
            m_allocated_space_size(allocated_space_size)
        {}


        void* m_bump_ptr {nullptr};
        void* m_mem_base {nullptr};

        size_t m_allocated_space_size {0};


    };
}