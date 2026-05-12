#pragma once
#include <vector>

#include "JSValue.h"


namespace JSBackend::Runtime {
    class Environment {
    public:
        virtual ~Environment() = default;
    private:
        std::vector<JSValue> m_bindings;
        Environment* m_outer {nullptr};
    };

}
