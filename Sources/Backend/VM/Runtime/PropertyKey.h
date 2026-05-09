#pragma once

#include <string>

namespace JSBackend::Runtime {
    class PropertyKey {
    public:
        enum class Kind : uint8_t {
            Identifier,
            ArrayIndex,
            Symbol
        };

        static PropertyKey identifier(std::string name) {
            return {Kind::Identifier, std::move(name), 0};
        }

        static PropertyKey arrayIndex(uint32_t index) {
            return {Kind::ArrayIndex, {}, index};
        }

        Kind kind() const { return m_kind; }
        const std::string& name() const { return m_name; }
        uint32_t index() const { return m_index; }

        bool operator==(const PropertyKey& other) const {
            return m_kind == other.m_kind
                && m_index == other.m_index
                && m_name == other.m_name;
        }

    private:
        PropertyKey(Kind kind, std::string name, uint32_t index)
            : m_kind(kind)
            , m_name(std::move(name))
            , m_index(index)
        {
        }

        Kind m_kind;
        std::string m_name;
        uint32_t m_index{0};
    };

    struct PropertyKeyHash {
        size_t operator()(const PropertyKey& key) const {
            auto kindHash = std::hash<uint8_t>{}(static_cast<uint8_t>(key.kind()));
            if (key.kind() == PropertyKey::Kind::ArrayIndex)
                return kindHash ^ (std::hash<uint32_t>{}(key.index()) << 1);
            return kindHash ^ (std::hash<std::string>{}(key.name()) << 1);
        }
    };
}
