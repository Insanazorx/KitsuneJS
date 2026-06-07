
#include "ConsoleObject.h"

#include <iostream>

namespace JSBackend::Runtime {
    JSValue LogBuiltin(VM& vm, JSObject* thisObj, const std::vector<JSValue>& args) {
        std::cout << "[Console.log] ";
        for (const auto arg : args) {
            if (arg.isNumber()){
                std::cout << arg.asNumber() << " ";
            } else if (arg.isInt32()) {
                std::cout << arg.asInt32() << " ";
            } else if (arg.isBoolean()) {
                std::cout << (arg.asBoolean() ? "true" : "false") << " ";
            } else if (arg.isUndefined()) {
                std::cout << "undefined ";
            } else if (arg.isNull()) {
                std::cout << "null ";
            } else if (arg.isCell()) {
                auto cell = arg.asCell();
                switch (cell->kind()) {
                    case JSCell::Kind::String:
                        std::cout << "[string] ";
                        std::cout << arg.asString()->value();
                        break;
                    case JSCell::Kind::Object:
                        std::cout << "[object Object] ";
                        break;
                    case JSCell::Kind::Function:
                        std::cout << "[function] ";
                        break;
                    default:
                        std::cout << "[unknown cell] ";
                        break;
                }
            } else {
                std::cout << "[unknown value] ";
            }
        }
        std::cout << std::endl;
        return JSValue::undefined();
    }
}
