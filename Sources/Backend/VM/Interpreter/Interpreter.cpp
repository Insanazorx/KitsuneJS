#include "Interpreter.h"

#include <cassert>
#include <filesystem>
#include <iostream>

#include "Runtime/CallFrame.h"
#include "Runtime/Environment.h"
#include "Runtime/GlobalObject.h"
#include "Runtime/JSValue.h"
#include "Runtime/JSFunction.h"





namespace JSBackend::Interpreter {
#define DEBUG_INTERPRETER


    void Interpreter::run() {
        Bytecode::Instruction* inst = nullptr;
        while (inst = nextInstruction(), inst != nullptr) {
            switch (inst->OpType()) {
            #define HANDLE_BYTECODE(Name, Operands) case Bytecode::Op::Name: execute_##Name(dynamic_cast<Bytecode::Name##Instruction*>(inst)); break;
                BC_ALL(HANDLE_BYTECODE)
            #undef HANDLE_BYTECODE
                default:
                throw std::runtime_error("Unknown bytecode opcode: " + std::to_string(static_cast<uint32_t>(inst->OpType())));
                }
            }
    }

#define DECLARE_HANDLER(Name) void Interpreter::execute_##Name(const Bytecode::Name##Instruction* inst)

    DECLARE_HANDLER(nop) {}
    DECLARE_HANDLER(coverageMark) {}
    DECLARE_HANDLER(debugTrap) {}
    DECLARE_HANDLER(debugLog) {}
    DECLARE_HANDLER(debugDumpScope) {}
    DECLARE_HANDLER(debugDumpIC) {}
    DECLARE_HANDLER(unreachable) {}
    DECLARE_HANDLER(halt) {
        std::cout << "Halting interpreter" << std::endl;
        haltInterpreter();
    }
    DECLARE_HANDLER(enterGlobal) {
        std::cout << "Entering global code block" << std::endl;
    }
    DECLARE_HANDLER(enterFunction) {}
    DECLARE_HANDLER(move) {
        auto srcReg = inst->src();
        auto dstReg = inst->dst();
        registers().at(dstReg) = registers().at(srcReg);
#ifdef DEBUG_INTERPRETER
        std::cout << "move r" << dstReg << " = r" << srcReg << std::endl;
#endif
    }
    DECLARE_HANDLER(clearReg) {}
    DECLARE_HANDLER(swap) {}
    DECLARE_HANDLER(loadThis) {
        assert(inst->OpType() == Bytecode::Op::loadThis);
        assert(m_currentCodeBlock != nullptr);

        auto thisValue = m_currentCodeBlock->callFrame()->thisValue();
        auto dst = inst->dst();

        m_registers[dst].write64(thisValue.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "loadThis: loaded this value into register "
        << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif


    }
    DECLARE_HANDLER(loadNewTarget) {}
    DECLARE_HANDLER(loadSuperConstructor) {}
    DECLARE_HANDLER(loadUndefined) {
        assert(inst->OpType() == Bytecode::Op::loadUndefined);
        const auto val = Runtime::JSValue::undefined();
        const auto dst = inst->dst();
        m_registers[dst].write64(val.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "loadUndefined: loaded undefined value into register "
        << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(loadNull) {}
    DECLARE_HANDLER(loadTrue) {}
    DECLARE_HANDLER(loadFalse) {}
    DECLARE_HANDLER(loadEmpty) {}
    DECLARE_HANDLER(loadInt32) {
        assert(inst->OpType() == Bytecode::Op::loadInt32);

        const auto value = inst->value();
        const auto jsValue = Runtime::JSValue::number(value);

        auto dst = inst->dst();
        m_registers[dst].write64(jsValue.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "loadInt32: loaded int32 value " << value
        << " into register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(loadDouble) {}
    DECLARE_HANDLER(loadString) {}
    DECLARE_HANDLER(loadBigInt) {}
    DECLARE_HANDLER(loadSymbol) {}
    DECLARE_HANDLER(loadConst) {}
    DECLARE_HANDLER(newObject) {}
    DECLARE_HANDLER(newObjectWithProto) {}
    DECLARE_HANDLER(newArray) {}
    DECLARE_HANDLER(newArrayWithSize) {}
    DECLARE_HANDLER(newArrayWithSpread) {}
    DECLARE_HANDLER(newObjectLiteral) {}
    DECLARE_HANDLER(newArrayLiteral) {}
    DECLARE_HANDLER(newRegExp) {}
    DECLARE_HANDLER(createFunction) {
        assert(inst->OpType() == Bytecode::Op::createFunction);

        const auto functionId = inst->function();

        const auto codeBlockIt = m_functionCodeBlocks.find(functionId);
        if (codeBlockIt == m_functionCodeBlocks.end()) {
            throw std::runtime_error("Code block for function ID " + std::to_string(functionId) + " not found");
        }
        auto& codeBlock = codeBlockIt->second;
        auto functionObject = vm.allocate<Runtime::JSFunction>(codeBlock, functionId);
        auto jsValue = Runtime::JSValue::cell(functionObject);

        auto dst = inst->dst();
        m_registers[dst].write64(jsValue.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "createFunction: created function object for function ID " << functionId
        << " and stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(createClosure) {}
    DECLARE_HANDLER(createArrowClosure) {}
    DECLARE_HANDLER(createGeneratorClosure) {}
    DECLARE_HANDLER(createAsyncClosure) {}
    DECLARE_HANDLER(createClass) {}
    DECLARE_HANDLER(setHomeObject) {}

    DECLARE_HANDLER(getArgument) {}
    DECLARE_HANDLER(putArgument) {}
    DECLARE_HANDLER(getLocal) {}
    DECLARE_HANDLER(putLocal) {}
    DECLARE_HANDLER(initLocal) {}
    DECLARE_HANDLER(checkTDZLocal) {}

    DECLARE_HANDLER(createLexicalEnvironment) {
        assert(inst->OpType() == Bytecode::Op::createLexicalEnvironment);

        auto newEnv = vm.allocate<Runtime::Environment>();
        auto jsValue = Runtime::JSValue::cell(newEnv);

        auto dst = inst->dst();
        m_registers[dst].write64(jsValue.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "createLexicalEnvironment: created new lexical environment and stored in register "
        << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(pushLexicalEnvironment) {}
    DECLARE_HANDLER(popLexicalEnvironment) {}
    DECLARE_HANDLER(getContext) {}
    DECLARE_HANDLER(putContext) {}
    DECLARE_HANDLER(checkTDZContext) {}
    DECLARE_HANDLER(materializeScope) {}
    DECLARE_HANDLER(resolveName) {}

    DECLARE_HANDLER(getGlobalLexical) {
        auto dstReg = inst->dst();
        auto slot = inst->slot();

        Runtime::JSValue value = vm.globalObject()->globalEnvironment()->getBinding(slot);

        m_registers[dstReg].write64(value.rawBits());
    }
    DECLARE_HANDLER(putGlobalLexical) {
        auto srcReg = inst->src();
        auto slot = inst->slot();

        Runtime::JSValue value = Runtime::JSValue::fromRawBits(m_registers[srcReg].read64());
        vm.globalObject()->globalEnvironment()->putBinding(slot, value);

#ifdef DEBUG_INTERPRETER
        std::cout << "putGlobalLexical: stored value from register " << srcReg
        << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[srcReg].read64()))
        << " into global lexical slot " << slot << "\n";
#endif
    }
    DECLARE_HANDLER(initGlobalLexical) {
        auto srcReg = inst->src();
        auto slot = inst->slot();

        auto value = Runtime::JSValue::fromRawBits(m_registers[srcReg].read64());
        vm.globalObject()->globalEnvironment()->initBinding(slot, value);

#ifdef DEBUG_INTERPRETER
        std::cout << "initGlobalLexical: initialized global lexical variable at slot " << slot
        << " with value from register " << srcReg << " = " << Runtime::JSValue::toString(value) << "\n";
#endif
    }
    DECLARE_HANDLER(getGlobalVar) {
        assert(inst->OpType() == Bytecode::Op::getGlobalVar);

        auto globalEnv = vm.globalObject()->globalEnvironment();
        auto slot = inst->slot();
        auto value = globalEnv->getBinding(slot);

        auto dst = inst->dst();
        m_registers[dst].write64(value.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "getGlobalVar: loaded global variable from slot " << slot
        << " with value " << Runtime::JSValue::toString(value) << " into register " << dst << "\n";
#endif
    }
    DECLARE_HANDLER(putGlobalVar) {
        assert(inst->OpType() == Bytecode::Op::putGlobalVar);

        auto globalEnv = vm.globalObject()->globalEnvironment();
        const auto valueReg = inst->src();
        auto jsvalue = Runtime::JSValue::fromRawBits(m_registers[valueReg].read64());
        auto slot = inst->slot();

        globalEnv->putBinding(slot,jsvalue);

#ifdef DEBUG_INTERPRETER
        std::cout<< "putGlobalVar: stored value from register " << valueReg << " = " << Runtime::JSValue::toString(jsvalue)
        << " into global variable slot " << slot << "\n";
#endif
    }
    DECLARE_HANDLER(initGlobalVar) {

        assert(inst->OpType() == Bytecode::Op::initGlobalVar);

        auto globalEnv = vm.globalObject()->globalEnvironment();
        const auto valueReg = inst->src();
        auto jsvalue = Runtime::JSValue::fromRawBits(m_registers[valueReg].read64());

        auto slot = inst->slot();

        globalEnv->initBinding(slot,jsvalue);
    }
    DECLARE_HANDLER(getGlobalProperty) {
        assert(inst->OpType() == Bytecode::Op::getGlobalProperty);
        assert(m_currentCodeBlock != nullptr);

        auto globalObject = vm.globalObject();
        auto propertyId = inst->name();
        auto it = m_currentCodeBlock->constantPool.find(propertyId);
        if (it == m_currentCodeBlock->constantPool.end()) {
            throw std::runtime_error("Property name with ID " + std::to_string(propertyId) + " not found in constant pool");
        }
        auto propertyName = it->second;

        auto propNameKey = Runtime::PropertyKey::identifier(propertyName);
        auto value = globalObject->getOwnProperty(propNameKey);

        auto dst = inst->dst();
        m_registers[dst].write64(value->rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "getGlobalProperty: loaded global property '" << propertyName << "' with value " << Runtime::JSValue::toString(*value) << " into register " << dst << "\n"
        << " into register " << dst << "\n";
#endif
    }
    DECLARE_HANDLER(putGlobalProperty) {}
    DECLARE_HANDLER(typeofGlobal) {}
    DECLARE_HANDLER(deleteGlobal) {}

    DECLARE_HANDLER(getById) {
        assert(inst->OpType() == Bytecode::Op::getById);
        assert(m_currentCodeBlock != nullptr);

        const auto dstReg = inst->dst();
        const auto objectReg = inst->base();

        auto objectValue = Runtime::JSValue::fromRawBits(m_registers[objectReg].read64());
        auto propertyCPIndex = inst->name();

        auto it = m_currentCodeBlock->constantPool.find(propertyCPIndex);
        if (it == m_currentCodeBlock->constantPool.end()) {
            throw std::runtime_error("Constant pool entry for index " + std::to_string(propertyCPIndex) + " not found");
        }
        auto propertyName = it->second;

        auto propNameKey = Runtime::PropertyKey::identifier(propertyName);

        Runtime::JSValue* value = objectValue.asObject()->getOwnProperty(propNameKey);

        m_registers[dstReg].write64(value->rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "getById: loaded property '" << propertyName << "' from object in register " << objectReg
        << " with value " << Runtime::JSValue::toString(*value) << " into register " << dstReg << "\n";
#endif

    }
    DECLARE_HANDLER(putById) {}
    DECLARE_HANDLER(getByVal) {}
    DECLARE_HANDLER(putByVal) {}
    DECLARE_HANDLER(getByIdWithThis) {}
    DECLARE_HANDLER(getByValWithThis) {}
    DECLARE_HANDLER(getMethodById) {}
    DECLARE_HANDLER(getMethodByVal) {}
    DECLARE_HANDLER(defineOwnById) {}
    DECLARE_HANDLER(defineOwnByVal) {}
    DECLARE_HANDLER(deleteById) {}
    DECLARE_HANDLER(deleteByVal) {}
    DECLARE_HANDLER(hasProperty) {}
    DECLARE_HANDLER(inById) {}
    DECLARE_HANDLER(inByVal) {}

    DECLARE_HANDLER(getPrivateById) {}
    DECLARE_HANDLER(putPrivateById) {}
    DECLARE_HANDLER(definePrivateById) {}
    DECLARE_HANDLER(hasPrivateById) {}

    DECLARE_HANDLER(getSuperById) {}
    DECLARE_HANDLER(putSuperById) {}
    DECLARE_HANDLER(getSuperByVal) {}
    DECLARE_HANDLER(putSuperByVal) {}

    DECLARE_HANDLER(getLength) {}
    DECLARE_HANDLER(putLength) {}
    DECLARE_HANDLER(getByIndex) {}
    DECLARE_HANDLER(putByIndex) {}
    DECLARE_HANDLER(arrayPush) {}
    DECLARE_HANDLER(arrayPop) {}

    DECLARE_HANDLER(toNumber) {}
    DECLARE_HANDLER(toNumeric) {}
    DECLARE_HANDLER(toString) {}
    DECLARE_HANDLER(toObject) {}
    DECLARE_HANDLER(toBoolean) {
        assert(inst->OpType() == Bytecode::Op::toBoolean);

        const auto srcReg = inst->src();

        auto value = Runtime::JSValue::fromRawBits(m_registers[srcReg].read64());
        bool boolValue = value.asBoolean();
        auto dst = inst->dst();

        m_registers[dst].write64(Runtime::JSValue::boolean(boolValue).rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "toBoolean: converted value in register " << srcReg << " = " << Runtime::JSValue::toString(value)
        << " to boolean " << boolValue << " and stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(toPropertyKey) {}
    DECLARE_HANDLER(isCallable) {}
    DECLARE_HANDLER(isConstructor) {}
    DECLARE_HANDLER(typeofValue) {}
    DECLARE_HANDLER(voidOp) {}
    DECLARE_HANDLER(logicalNot) {}
    DECLARE_HANDLER(bitNot) {}
    DECLARE_HANDLER(negate) {}
    DECLARE_HANDLER(increment) {
        assert(inst->OpType() == Bytecode::Op::increment);

        const auto srcReg = inst->src();
        const auto dstReg = inst->dst();

        auto value = Runtime::JSValue::fromRawBits(m_registers[srcReg].read64());

        double numValue = value.asNumber();
        numValue += 1;

        m_registers[dstReg].write64(Runtime::JSValue::number(numValue).rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "increment: incremented value in register " << srcReg << " = " << Runtime::JSValue::toString(value)
        << " to " << numValue << " and stored in register " << dstReg << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dstReg].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(decrement) {}

    DECLARE_HANDLER(add) {
        assert(inst->OpType() == Bytecode::Op::add);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(leftValue.asNumber() + rightValue.asNumber());
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "add: added values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
        << " stored in register " << dst << " = " << m_registers[dst].read64() << "\n";
#endif
    }
    DECLARE_HANDLER(sub) {
        assert(inst->OpType() == Bytecode::Op::sub);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(leftValue.asNumber() - rightValue.asNumber());
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "sub: subtracted values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(mul) {
        assert(inst->OpType() == Bytecode::Op::mul);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(leftValue.asNumber() * rightValue.asNumber());
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());
    }
    DECLARE_HANDLER(div) {
        assert(inst->OpType() == Bytecode::Op::div);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(leftValue.asNumber() / rightValue.asNumber());
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "div: divided values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(mod) {
        assert(inst->OpType() == Bytecode::Op::mod);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(std::fmod(leftValue.asNumber(), rightValue.asNumber()));
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "mod: modulus of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(pow) {}
    DECLARE_HANDLER(bitAnd) {
        assert(inst->OpType() == Bytecode::Op::bitAnd);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(static_cast<int32_t>(leftValue.asNumber()) & static_cast<int32_t>(rightValue.asNumber()));
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());
#ifdef DEBUG_INTERPRETER
         std::cout<< "bitAnd: bitwise AND of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
          << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
          << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(bitOr) {
        assert(inst->OpType() == Bytecode::Op::bitOr);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(static_cast<int32_t>(leftValue.asNumber()) | static_cast<int32_t>(rightValue.asNumber()));
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());
#ifdef DEBUG_INTERPRETER

            std::cout<< "bitOr: bitwise OR of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
            << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
            << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";

#endif
    }
    DECLARE_HANDLER(bitXor) {
        assert(inst->OpType() == Bytecode::Op::bitXor);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(static_cast<int32_t>(leftValue.asNumber()) ^ static_cast<int32_t>(rightValue.asNumber()));
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "bitXor: bitwise XOR of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(leftShift) {
        assert(inst->OpType() == Bytecode::Op::leftShift);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(static_cast<int32_t>(leftValue.asNumber()) << (static_cast<int32_t>(rightValue.asNumber()) & 0x1F));
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "leftShift: left shift of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(rightShift) {
        assert(inst->OpType() == Bytecode::Op::rightShift);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(static_cast<int32_t>(leftValue.asNumber()) >> (static_cast<int32_t>(rightValue.asNumber()) & 0x1F));
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "rightShift: right shift of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(unsignedRightShift) {
        assert(inst->OpType() == Bytecode::Op::unsignedRightShift);

        auto leftReg = inst->lhs();
        auto rightReg = inst->rhs();
        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        auto result = Runtime::JSValue::number(static_cast<uint32_t>(leftValue.asNumber()) >> (static_cast<int32_t>(rightValue.asNumber()) & 0x1F));
        auto dst = inst->dst();

        m_registers[dst].write64(result.rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "unsignedRightShift: unsigned right shift of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << result.asNumber()
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(equal) {
        assert(inst->OpType() == Bytecode::Op::equal);

        const auto leftReg = inst->lhs();
        const auto rightReg = inst->rhs();

        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        bool result = leftValue.asNumber() == rightValue.asNumber();
        const auto dst = inst->dst();
        m_registers[dst].write64(Runtime::JSValue::boolean(result).rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "equal: equality comparison of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << (result ? "true" : "false")
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(notEqual) {
        assert(inst->OpType() == Bytecode::Op::notEqual);

        const auto leftReg = inst->lhs();
        const auto rightReg = inst->rhs();

        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        bool result = leftValue.asNumber() != rightValue.asNumber();
        const auto dst = inst->dst();
        m_registers[dst].write64(Runtime::JSValue::boolean(result).rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "notEqual: inequality comparison of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << (result ? "true" : "false")
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(strictEqual) {}
    DECLARE_HANDLER(strictNotEqual) {}
    DECLARE_HANDLER(lessThan) {
        assert(inst->OpType() == Bytecode::Op::lessThan);

        const auto leftReg = inst->lhs();
        const auto rightReg = inst->rhs();

        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        bool result = leftValue.asNumber() < rightValue.asNumber();
        const auto dst = inst->dst();
        m_registers[dst].write64(Runtime::JSValue::boolean(result).rawBits());

#ifdef DEBUG_INTERPRETER
        std::cout<< "lessThan: less-than comparison of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << (result ? "true" : "false")
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(lessThanOrEqual) {
        assert(inst->OpType() == Bytecode::Op::lessThanOrEqual);

        const auto leftReg = inst->lhs();
        const auto rightReg = inst->rhs();

        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        bool result = leftValue.asNumber() <= rightValue.asNumber();
        const auto dst = inst->dst();
        m_registers[dst].write64(Runtime::JSValue::boolean(result).rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "lessThanOrEqual: less-than-or-equal comparison of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << (result ? "true" : "false")
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(greaterThan) {
        assert(inst->OpType() == Bytecode::Op::greaterThan);

        const auto leftReg = inst->lhs();
        const auto rightReg = inst->rhs();

        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        bool result = leftValue.asNumber() > rightValue.asNumber();
        const auto dst = inst->dst();
        m_registers[dst].write64(Runtime::JSValue::boolean(result).rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "greaterThan: greater-than comparison of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << (result ? "true" : "false")
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(greaterThanOrEqual) {
        assert(inst->OpType() == Bytecode::Op::greaterThanOrEqual);

        const auto leftReg = inst->lhs();
        const auto rightReg = inst->rhs();

        auto leftValue = Runtime::JSValue::fromRawBits(m_registers[leftReg].read64());
        auto rightValue = Runtime::JSValue::fromRawBits(m_registers[rightReg].read64());

        bool result = leftValue.asNumber() >= rightValue.asNumber();
        const auto dst = inst->dst();
        m_registers[dst].write64(Runtime::JSValue::boolean(result).rawBits());
#ifdef DEBUG_INTERPRETER
        std::cout<< "greaterThanOrEqual: greater-than-or-equal comparison of values in registers " << leftReg << " = " << Runtime::JSValue::toString(leftValue)
        << " and " << rightReg << " = " << Runtime::JSValue::toString(rightValue) << ", result is " << (result ? "true" : "false")
        << " stored in register " << dst << " = " << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[dst].read64())) << "\n";
#endif
    }
    DECLARE_HANDLER(sameValue) {}
    DECLARE_HANDLER(sameValueZero) {}
    DECLARE_HANDLER(instanceOf) {}
    DECLARE_HANDLER(inOperator) {}

    DECLARE_HANDLER(call) {
        //TODO: implement call handler:
            assert(inst->OpType() == Bytecode::Op::call);

            const auto functionReg = inst->callee();
            auto functionValue = Runtime::JSValue::fromRawBits(m_registers[functionReg].read64());

            if (!functionValue.isFunction()) {
                throw std::runtime_error("Attempting to call a non-function value");
            }

            Runtime::JSFunction* functionObject = functionValue.asFunction();

            auto thisReg = inst->thisValue();
            auto thisValue = Runtime::JSValue::fromRawBits(m_registers[thisReg].read64());

            auto argCount = inst->argc();

            std::vector<Runtime::JSValue> arguments;
            std::cout << "-----------args------------\n";
            for (size_t i = 0; i < argCount; ++i) {
                const auto argReg = inst->argsBase() + i;
                auto argValue = Runtime::JSValue::fromRawBits(m_registers[argReg].read64());
                std::cout <<"[*] Arg" << i <<" => " << Runtime::JSValue::toString(argValue) << "| rawBits => " << argValue.rawBits() << "\n";
                arguments.push_back(argValue);
            }
            std::cout << "---------------------------\n";

            std::cout << "Calling function with ID " << functionObject->functionID() << std::endl;
            functionObject->call(vm, thisValue.asObject(), arguments);



            // For now, we will just return undefined for any function call
            m_registers[inst->dst()].write64(Runtime::JSValue::undefined().rawBits());

#ifdef DEBUG_INTERPRETER
            std::cout << "call: called function in register " << functionReg << " with this value in register " << thisReg
            << " and " << argCount << " arguments, result stored in register " << inst->dst() << " = "
            << Runtime::JSValue::toString(Runtime::JSValue::fromRawBits(m_registers[inst->dst()].read64())) << "\n";
#endif

    }
    DECLARE_HANDLER(callDirect) {}
    DECLARE_HANDLER(callEval) {}
    DECLARE_HANDLER(callVarargs) {}
    DECLARE_HANDLER(tailCall) {}
    DECLARE_HANDLER(construct) {}
    DECLARE_HANDLER(constructVarargs) {}
    DECLARE_HANDLER(superConstruct) {}
    DECLARE_HANDLER(superConstructVarargs) {}

    DECLARE_HANDLER(jump) {
        assert(inst->OpType() == Bytecode::Op::jump);

        auto targetOffset = inst->offset();

        //for only debug:
        auto oldLogicalAddress = m_instructionPointer;

        auto it = m_offsetToLogicalAddress.find(targetOffset);
        if (it == m_offsetToLogicalAddress.end()) {
            throw std::runtime_error("Invalid jump target offset: " + std::to_string(targetOffset));
        }
        auto targetLogicalAddress = it->second;

        std::cout << "Jumping from logical address " << std::hex <<oldLogicalAddress << " to "<< std::hex << targetLogicalAddress << std::endl;

        m_instructionPointer = targetLogicalAddress;

        std::cout << "New instruction pointer is " << std::hex << m_instructionPointer << std::endl;
    }
    DECLARE_HANDLER(jumpIfTrue) {
        assert(inst->OpType() == Bytecode::Op::jumpIfTrue);

        const auto conditionReg = inst->value();

        auto conditionValue = Runtime::JSValue::fromRawBits(m_registers[conditionReg].read64());

        if (!conditionValue.isBoolean()) {
            throw std::runtime_error("Condition value for jumpIfTrue is not a boolean");
        }

        if (conditionValue.asBoolean()) {
            auto targetOffset = inst->offset();

            auto it = m_offsetToLogicalAddress.find(targetOffset);
            if (it == m_offsetToLogicalAddress.end()) {
                throw std::runtime_error("Invalid jump target offset: " + std::to_string(targetOffset));
            }
            auto targetLogicalAddress = it->second;

            std::cout << "Condition is true, jumping to logical address " << std::hex << targetLogicalAddress << std::endl;

            m_instructionPointer = targetLogicalAddress;
        } else {
            std::cout << "Condition is false, not jumping" << std::endl;
        }
    }
    DECLARE_HANDLER(jumpIfFalse) {}
    DECLARE_HANDLER(jumpIfNull) {}
    DECLARE_HANDLER(jumpIfUndefined) {}
    DECLARE_HANDLER(jumpIfNullish) {}
    DECLARE_HANDLER(jumpIfNotNullish) {}
    DECLARE_HANDLER(jumpIfEmpty) {}
    DECLARE_HANDLER(switchInt) {}
    DECLARE_HANDLER(switchString) {}

    DECLARE_HANDLER(returnValue) {
        assert(inst->OpType() == Bytecode::Op::returnValue);

        const auto valueReg = inst->value();
        auto value = Runtime::JSValue::fromRawBits(m_registers[valueReg].read64());

#ifdef DEBUG_INTERPRETER
        std::cout << "returnValue: returning value from register " << valueReg
                  << " = " << Runtime::JSValue::toString(value) << "\n";
#endif

        haltInterpreter();
    }
    DECLARE_HANDLER(returnUndefined) {
        assert(inst->OpType() == Bytecode::Op::returnUndefined);

#ifdef DEBUG_INTERPRETER
        std::cout << "returnUndefined: returning undefined\n";
#endif

        haltInterpreter();
    }
    DECLARE_HANDLER(throwValue) {}
    DECLARE_HANDLER(rethrow) {}
    DECLARE_HANDLER(enterCatch) {}
    DECLARE_HANDLER(enterFinally) {}
    DECLARE_HANDLER(getException) {}
    DECLARE_HANDLER(clearException) {}

    DECLARE_HANDLER(getIterator) {}
    DECLARE_HANDLER(iteratorNext) {}
    DECLARE_HANDLER(iteratorValue) {}
    DECLARE_HANDLER(iteratorDone) {}
    DECLARE_HANDLER(iteratorClose) {}

    DECLARE_HANDLER(getModuleVariable) {}
    DECLARE_HANDLER(putModuleVariable) {}
    DECLARE_HANDLER(getImportMeta) {}

    DECLARE_HANDLER(createMethod) {}
    DECLARE_HANDLER(defineClassMethod) {}
    DECLARE_HANDLER(defineInstanceField) {}
    DECLARE_HANDLER(defineStaticField) {}

    DECLARE_HANDLER(createPromise) {}
    DECLARE_HANDLER(fulfillPromise) {}
    DECLARE_HANDLER(rejectPromise) {}
    DECLARE_HANDLER(promiseResolve) {}
    DECLARE_HANDLER(promiseThen) {}
    DECLARE_HANDLER(enqueueMicrotask) {}

    DECLARE_HANDLER(asyncEnter) {}
    DECLARE_HANDLER(awaitSuspend) {}
    DECLARE_HANDLER(asyncResumePoint) {}

    DECLARE_HANDLER(createGeneratorObject) {}
    DECLARE_HANDLER(createAsyncGeneratorObject) {}
    DECLARE_HANDLER(generatorEnter) {}
    DECLARE_HANDLER(getResumeValue) {}
    DECLARE_HANDLER(getResumeKind) {}
    DECLARE_HANDLER(jumpIfResumeKind) {}
    DECLARE_HANDLER(generatorSuspend) {}
    DECLARE_HANDLER(asyncGeneratorSuspend) {}
    DECLARE_HANDLER(yieldStar) {}
    DECLARE_HANDLER(generatorReturn) {}
    DECLARE_HANDLER(generatorThrow) {}
    DECLARE_HANDLER(asyncGeneratorReturn) {}
    DECLARE_HANDLER(asyncGeneratorThrow) {}
    DECLARE_HANDLER(resumePoint) {}

    DECLARE_HANDLER(profileValue) {}
    DECLARE_HANDLER(profileType) {}
    DECLARE_HANDLER(profileBranch) {}
    DECLARE_HANDLER(profileCall) {}

    DECLARE_HANDLER(checkStructure) {}
    DECLARE_HANDLER(checkCell) {}
    DECLARE_HANDLER(checkNumber) {}
    DECLARE_HANDLER(checkInt32) {}
    DECLARE_HANDLER(checkString) {}
    DECLARE_HANDLER(checkObject) {}
    DECLARE_HANDLER(checkArray) {}
    DECLARE_HANDLER(checkInt32Index) {}
    DECLARE_HANDLER(checkStack) {}

    DECLARE_HANDLER(runtimeCall) {}
    DECLARE_HANDLER(intrinsicCall) {}

#undef DECLARE_HANDLER

#ifdef DEBUG_INTERPRETER
#undef DEBUG_INTERPRETER
#endif
}
