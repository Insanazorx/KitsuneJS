#pragma once
#include <cstddef>
#include <cstdint>
#include <new>
#include <sys/mman.h>
#include <utility>
#include <vector>

#include "JSCell.h"
#include "Region.h"
#include "../debug.h"


namespace JSBackend::GarbageCollector {


    class Heap {
    public:
        Heap() : m_region_buckets
            {
                SizeClassBucket(16),
                SizeClassBucket(32),
                SizeClassBucket(48),
                SizeClassBucket(64),
                SizeClassBucket(80),
                SizeClassBucket(96),
            }
        {}

        ~Heap() = default;



        void* allocate_impl(size_t size) {

            int aligned_size = align_size(size);

            if (aligned_size > 256) {
                DEBUG("Allocation Limit Exceeded " << aligned_size);
            }

            for (auto& bucket : m_region_buckets) {
                if (bucket.cell_size >= aligned_size) {
                    Region* region = bucket.get_appropriate_region_for_given_size_or_create(aligned_size); //<-- bak
                    VERIFY(region != nullptr, "No appropriate region found for size" << aligned_size);

                    void* mem = region->allocate_appropriate_mem_for_cell(aligned_size); //<-- bak
                    return mem;
                }
            }

            void* large_mem = mmap(nullptr, aligned_size*1024, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
            VERIFY(large_mem != MAP_FAILED, "mmap failed for large allocation of size " << aligned_size);

            return large_mem;
        }

        template <typename T, typename... Args>
        T* allocate(Args&&... args) {

            auto* mem = allocate_impl(sizeof(T));
            if (!mem) VERIFY_NOT_REACHED();
            auto item = new (mem) T(std::forward<Args>(args)...);

            return item;

        }

        void collect_garbage() {

        }

    private:
        using SizeClass = uint32_t;
        class SizeClassBucket {
        public:

            SizeClassBucket ( SizeClass size_class ) : cell_size(size_class) {}
            SizeClass cell_size;
            std::vector<Region> regions;
            Region* current = nullptr;

            Region* get_appropriate_region_for_given_size_or_create(size_t size) {

                //find if matches

                if (current && current->has_enough_space(size)) {
                    return current;
                }
                for (auto& region : regions) {
                    if (region.has_enough_space(size)) { //<-- bak
                        current = &region;
                        return current;
                    }
                }

                //or create new one

                void* mem = mmap(nullptr, cell_size * 1024, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
                VERIFY(mem != MAP_FAILED, "mmap failed for region allocation of size " << cell_size);

                Region* new_region = Region::Create(mem, cell_size * 1024);
                regions.push_back(std::move(*new_region));

                current = &regions.back();

                return current;
            }
        };

    private:
        SizeClassBucket m_region_buckets[6];

        std::vector<JSCell*> m_roots {nullptr};
    };
}
