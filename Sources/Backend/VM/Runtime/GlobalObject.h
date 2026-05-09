#pragma once
#include "JSObject.h"

namespace JSBackend::Runtime {
    class GlobalObject : public JSObject {
    public:
        virtual ~GlobalObject() = default;
    };
}
