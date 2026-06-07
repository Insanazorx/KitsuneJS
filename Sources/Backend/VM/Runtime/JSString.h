#pragma once

#include <cstdint>
#include <string>

#include "../GC/JSCell.h"

namespace JSBackend::Runtime {
    class JSString : public GarbageCollector::JSCell {
    public:
        JSString(const std::string& value) : m_str(value) {}
        ~JSString() override = default;
        Kind kind() const override { return Kind::String; }

        uint32_t length() const {
            return static_cast<uint32_t>(m_str.size()); // JS UTF-16 code unit length
        }

        char16_t codeUnitAt(uint32_t index) const {
            return m_str[index];
        }

        std::string operator+ (const JSString& other) const {
            return m_str + other.m_str;
        }



        const std::string& value() const { return m_str; }

        static std::string sanitizeHeadAndTail(const std::string& str) {
            if (str.size() <= 2)
                return "";

            return str.substr(1, str.size() - 2);
        }
    private:
        std::string m_str;
    };
}
