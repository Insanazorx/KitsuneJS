#pragma once
#include <utility>
#include <vector>

#include "Environment.h"
#include "JSValue.h"


namespace JSBackend::Runtime {
class JSValue;

class CallFrame {
public:
        CallFrame(std::vector<JSValue> args, std::vector<JSValue> locals, Environment* lexicalEnvironment, JSValue thisValue, JSValue newTarget)
            : m_args(std::move(args))
            , m_locals(std::move(locals))
            , m_capturedEnvironment(lexicalEnvironment)
            , m_thisValue(thisValue)
            , m_newTarget(newTarget)
        {
        }

        CallFrame() = default;


        const std::vector<JSValue>& args() const {
            return m_args;
        }

        void set_args(std::vector<JSValue> args) {
            this->m_args = args;
        }

        const std::vector<JSValue>& locals() const {
            return m_locals;
        }

        std::vector<JSValue>& locals() {
            return m_locals;
        }

        void set_locals(std::vector<JSValue> locals) {
            this->m_locals = locals;
        }

        Environment* capturedEnvironment() const {
            return m_capturedEnvironment;
        }

        void set_capturedEnvironment(Environment *m_lexical_environment) {
            m_capturedEnvironment = m_lexical_environment;
        }

        JSValue thisValue() const {
            return m_thisValue;
        }

        void set_thisValue(JSValue this_value) {
            m_thisValue = this_value;
        }

        JSValue newTarget() const {
            return m_newTarget;
        }

        void set_newTarget(JSValue m_new_target) {
            m_newTarget = m_new_target;
        }

private:
    std::vector<JSValue> m_args;
        // function local / var / param gibi hızlı şeyler
    std::vector<JSValue> m_locals;

    // closure'a kaçan block/function lexical bindingler
    Environment* m_capturedEnvironment {nullptr};

    JSValue m_thisValue;
    JSValue m_newTarget;
};
}
