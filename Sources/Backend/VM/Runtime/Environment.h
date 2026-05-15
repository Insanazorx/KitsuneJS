#pragma once
#include <vector>

#include "JSValue.h"


namespace JSBackend::Runtime {
    class Environment : public JSCell {
    public:
        Environment() {
            m_bindings.resize(16, JSValue::undefined());
        };
        virtual ~Environment() = default;
        void resizeBindings(uint16_t newSize) {
            auto oldBindings = m_bindings;
            m_bindings.resize(newSize, JSValue::undefined());
            for (size_t i = 0; i < oldBindings.size(); ++i) {
                m_bindings[i] = oldBindings[i];
            }
        }
        void initBinding(uint16_t slot, JSValue value) {
            if (slot >= m_bindings.size()) {
                resizeBindings(slot + 16);
            }
            m_bindings[slot] = value;
        }

        void putBinding(uint16_t slot, JSValue value) {
            assert(slot < m_bindings.size() && "putBinding slot out of bounds");
            m_bindings[slot] = value;
        }

        JSValue getBinding(uint16_t slot) {
            assert(slot < m_bindings.size() && "getBinding slot out of bounds");
            return m_bindings[slot];
        }
    private:
        std::vector<JSValue> m_bindings;
        Environment* m_outer {nullptr};
    };

}
