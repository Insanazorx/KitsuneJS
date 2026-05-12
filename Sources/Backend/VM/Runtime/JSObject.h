#pragma once


#include <cstdint>
#include <string>
#include <string_view>
#include <unordered_map>
#include <utility>

#include "../GC/JSCell.h"
#include "JSValue.h"
#include "PropertyKey.h"


namespace JSBackend::Runtime {
    class JSObject : public GarbageCollector::JSCell {
    public:

        ~JSObject() override = default;
        Kind kind() const override { return Kind::Object; }

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
