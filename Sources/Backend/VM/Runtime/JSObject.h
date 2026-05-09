#pragma once
#include "../GC/JSCell.h"
#include "../GC/Heap.h"


namespace JSBackend::Runtime {
    class JSObject : public GarbageCollector::JSCell {
    public:
        static JSObject* Create(GarbageCollector::Heap* allocator, JSObject* prototype = nullptr) {
            auto* obj = allocator->allocate<JSObject>();
            obj->m_prototype = prototype;
            return obj;
        }
        ~JSObject() override = default;


    protected:
        JSObject* m_prototype{nullptr};

    };
}
