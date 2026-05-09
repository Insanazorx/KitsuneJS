#pragma once
#include <vector>



namespace JSBackend::Runtime {
    class JSValue;

    class Environment {
    public:
        virtual ~Environment() = default;
    private:
        std::vector<JSValue> m_bindings;
        Environment* m_outer {nullptr};
    };

}
