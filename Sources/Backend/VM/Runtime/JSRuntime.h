#pragma once

namespace JSBackend::Runtime {

    class JSRuntime {
    public:
        JSRuntime();
        ~JSRuntime();

        void initialize();
        void shutdown();

    private:
        // Internal state and resources for the runtime
    };

}