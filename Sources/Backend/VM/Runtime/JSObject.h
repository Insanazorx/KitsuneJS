#pragma once
#include "../VM.h"
#include "../GC/JSCell.h"

#include "../GC/Heap.h"
#include <cstdint>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>

#include "JSValue.h"
#include "PropertyKey.h"


namespace JSBackend::Runtime {
    class JSValue;



    class JSObject : public GarbageCollector::JSCell {
    public:
        static JSObject* Create(VM& vm, JSObject* prototype = nullptr) {
            auto* obj = vm.heap().allocate<JSObject>();
            obj->m_prototype = prototype;
            return obj;
        }
        ~JSObject() override = default;

        void put(const PropertyKey& key, JSValue value) {
            m_properties[key] = value;
        }

        JSValue* getOwnProperty(const PropertyKey& key) {
            auto it = m_properties.find(key);
            if (it == m_properties.end())
                return nullptr;
            return &it->second;
        }

        JSObject* prototype() const { return m_prototype; }


    protected:
        JSObject* m_prototype{nullptr};
        std::unordered_map<PropertyKey, JSValue, PropertyKeyHash> m_properties;

    };
}
