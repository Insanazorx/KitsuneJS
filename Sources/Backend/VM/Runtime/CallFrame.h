#pragma once
#include <vector>

#include "Environment.h"
#include "JSValue.h"

namespace JSBackend::Runtime {


class CallFrame {

private:
    std::vector<JSValue> args;

    // function local / var / param gibi hızlı şeyler
    std::vector<JSValue> locals;

    // closure'a kaçan block/function lexical bindingler
    Environment* lexicalEnvironment;

    JSValue thisValue;
    JSValue newTarget;
};
}
