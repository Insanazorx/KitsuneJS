#pragma once

#include <cassert>
#include <cstdint>
#include <cstring>
#include <string>

#include "JSString.h"
#include "../GC/JSCell.h"

namespace JSBackend::Runtime {
    using JSCell = GarbageCollector::JSCell;

    class JSObject;
    class JSString;
    class JSFunction;
    class JSArray;
    class JSSymbol;
    class JSBigInt;
    class Environment;

    class JSValue {
    public:
        enum class ImmediateTag : uint16_t {
            Undefined = 0x001,
            Null      = 0x002,
            Boolean   = 0x003,
            Int32     = 0x004,
        };

    private:
        uint64_t m_bits;

        /*
            Clean toy NaN-boxing layout:

            Normal number:
                raw IEEE-754 double

            Immediate boxed values:
                0x7ffc [16-bit tag] [32-bit payload]

            Cell pointer boxed values:
                0x7ffd [48-bit pointer payload]

            This makes isCell() cheap and unambiguous.
        */

        static constexpr uint64_t ImmediateMarker = 0x7ffc000000000000ULL;
        static constexpr uint64_t CellMarker      = 0x7ffd000000000000ULL;

        static constexpr uint64_t MarkerMask      = 0xffff000000000000ULL;

        static constexpr uint64_t TagShift        = 32;
        static constexpr uint64_t TagMask         = 0x0000ffff00000000ULL;
        static constexpr uint64_t Payload32Mask   = 0x00000000ffffffffULL;
        static constexpr uint64_t PointerMask     = 0x0000ffffffffffffULL;

        explicit JSValue(uint64_t bits)
            : m_bits(bits)
        {
        }

        static uint64_t doubleToBits(double value)
        {
            uint64_t bits;
            std::memcpy(&bits, &value, sizeof(bits));
            return bits;
        }

        static double bitsToDouble(uint64_t bits)
        {
            double value;
            std::memcpy(&value, &bits, sizeof(value));
            return value;
        }

        static uint64_t encodeImmediate(ImmediateTag tag, uint32_t payload = 0)
        {
            return ImmediateMarker
                | (static_cast<uint64_t>(tag) << TagShift)
                | static_cast<uint64_t>(payload);
        }

        static uint64_t encodeCell(JSCell* cell)
        {
            assert(cell != nullptr);

            uintptr_t raw = reinterpret_cast<uintptr_t>(cell);

            assert((raw & 0xffff000000000000ULL) == 0 &&
                   "JSCell pointer does not fit in 48 bits");

            return CellMarker | raw;
        }

        ImmediateTag immediateTag() const
        {
            assert(isImmediate());
            return static_cast<ImmediateTag>((m_bits & TagMask) >> TagShift);
        }

        uint32_t payload32() const
        {
            return static_cast<uint32_t>(m_bits & Payload32Mask);
        }

    public:
        JSValue()
            : m_bits(encodeImmediate(ImmediateTag::Undefined))
        {
        }

        static JSValue undefined()
        {
            return JSValue(encodeImmediate(ImmediateTag::Undefined));
        }

        static JSValue null()
        {
            return JSValue(encodeImmediate(ImmediateTag::Null));
        }

        static JSValue boolean(bool value)
        {
            return JSValue(encodeImmediate(
                ImmediateTag::Boolean,
                value ? 1u : 0u
            ));
        }

        static JSValue int32(int32_t value)
        {
            return JSValue(encodeImmediate(
                ImmediateTag::Int32,
                static_cast<uint32_t>(value)
            ));
        }

        static JSValue number(double value)
        {
            uint64_t bits = doubleToBits(value);

            bool exponentAllOnes =
                (bits & 0x7ff0000000000000ULL) == 0x7ff0000000000000ULL;

            bool fractionNonZero =
                (bits & 0x000fffffffffffffULL) != 0;

            bool isNaN = exponentAllOnes && fractionNonZero;

            if (isNaN) {
                /*
                    Canonical numeric NaN.

                    We intentionally use 0x7ff8...
                    while our boxed markers are 0x7ffc... and 0x7ffd...
                */
                return JSValue(0x7ff8000000000000ULL);
            }

            return JSValue(bits);
        }

        static JSValue cell(JSCell* cell)
        {
            return JSValue(encodeCell(cell));
        }

        bool isImmediate() const
        {
            return (m_bits & MarkerMask) == ImmediateMarker;
        }

        bool isCell() const
        {
            return (m_bits & MarkerMask) == CellMarker;
        }

        bool isNumber() const
        {
            return !isImmediate() && !isCell();
        }

        bool isUndefined() const
        {
            return isImmediate()
                && immediateTag() == ImmediateTag::Undefined;
        }

        bool isNull() const
        {
            return isImmediate()
                && immediateTag() == ImmediateTag::Null;
        }

        bool isBoolean() const
        {
            return isImmediate()
                && immediateTag() == ImmediateTag::Boolean;
        }

        bool isInt32() const
        {
            return isImmediate()
                && immediateTag() == ImmediateTag::Int32;
        }

        bool isObject() const
        {
            return isCell() && asCell()->kind() == JSCell::Kind::Object;
        }

        bool isString() const
        {
            return isCell() && asCell()->kind() == JSCell::Kind::String;
        }

        bool isFunction() const
        {
            return isCell() && asCell()->kind() == JSCell::Kind::Function;
        }

        bool isArray() const
        {
            return isCell() && asCell()->kind() == JSCell::Kind::Array;
        }

        bool isSymbol() const
        {
            return isCell() && asCell()->kind() == JSCell::Kind::Symbol;
        }

        bool isBigInt() const
        {
            return isCell() && asCell()->kind() == JSCell::Kind::BigInt;
        }

        bool isEnvironment() const
        {
            return isCell() && asCell()->kind() == JSCell::Kind::Environment;
        }

        double asNumber() const
        {
            assert(isNumber());
            return bitsToDouble(m_bits);
        }

        bool asBoolean() const
        {
            assert(isBoolean());
            return payload32() != 0;
        }

        int32_t asInt32() const
        {
            assert(isInt32());
            return static_cast<int32_t>(payload32());
        }

        JSCell* asCell() const
        {
            assert(isCell());
            uintptr_t raw = static_cast<uintptr_t>(m_bits & PointerMask);
            return reinterpret_cast<JSCell*>(raw);
        }

        JSObject* asObject() const
        {
            assert(isObject());
            return reinterpret_cast<JSObject*>(asCell());
        }

        JSString* asString() const
        {
            assert(isString());
            return reinterpret_cast<JSString*>(asCell());
        }

        JSFunction* asFunction() const
        {
            assert(isFunction());
            return reinterpret_cast<JSFunction*>(asCell());
        }

        JSArray* asArray() const
        {
            assert(isArray());
            return reinterpret_cast<JSArray*>(asCell());
        }

        JSSymbol* asSymbol() const
        {
            assert(isSymbol());
            return reinterpret_cast<JSSymbol*>(asCell());
        }

        JSBigInt* asBigInt() const
        {
            assert(isBigInt());
            return reinterpret_cast<JSBigInt*>(asCell());
        }

        Environment* asEnvironment() const
        {
            assert(isEnvironment());
            return reinterpret_cast<Environment*>(asCell());
        }

        uint64_t rawBits() const
        {
            return m_bits;
        }

        static JSValue fromRawBits(uint64_t bits)
        {
            return JSValue(bits);
        }
        static std::string toString(const JSValue& value)
        {
            if (value.isUndefined()) {
                return "undefined";
            } else if (value.isNull()) {
                return "null";
            } else if (value.isBoolean()) {
                return value.asBoolean() ? "true" : "false";
            } else if (value.isInt32()) {
                return std::to_string(value.asInt32());
            } else if (value.isNumber()) {
                return std::to_string(value.asNumber());
            } else if (value.isString()) {
                return "\"" + value.asString()->value() + "\"";
            } else if (value.isObject()) {
                return "[object Object]";
            } else if (value.isFunction()) {
                return "[function]";
            } else if (value.isArray()) {
                return "[array]";
            } else if (value.isSymbol()) {
                return "[symbol]";
            } else if (value.isBigInt()) {
                return "[bigint]";
            } else if (value.isEnvironment()) {
                return "[environment]";
            } else {
                return "[unknown]";
            }
        };
    };
}
