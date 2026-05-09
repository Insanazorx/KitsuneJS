#include "Interpreter.h"

namespace JSBackend::Interpreter {

    void Interpreter::run() {
        for (auto& inst : m_globalCodeBlock.instructions) {
            switch (inst->OpType()) {
            #define HANDLE_BYTECODE(Name, Operands) case Bytecode::Op::Name: execute_##Name(dynamic_cast<Name##Instruction*>(inst)); break;
                BC_ALL(HANDLE_BYTECODE)
            #undef HANDLE_BYTECODE
                default:
                throw std::runtime_error("Unknown bytecode opcode: " + std::to_string(static_cast<uint32_t>(inst->OpType())));
                }
            }
    }

#define DECLARE_HANDLER(Name) void Interpreter::execute_##Name(const Name##Instruction* inst)

    DECLARE_HANDLER(nop) {}
    DECLARE_HANDLER(coverageMark) {}
    DECLARE_HANDLER(debugTrap) {}
    DECLARE_HANDLER(debugLog) {}
    DECLARE_HANDLER(debugDumpScope) {}
    DECLARE_HANDLER(debugDumpIC) {}
    DECLARE_HANDLER(unreachable) {}
    DECLARE_HANDLER(halt) {}
    DECLARE_HANDLER(enterGlobal) {

    }
    DECLARE_HANDLER(enterFunction) {}
    DECLARE_HANDLER(move) {}
    DECLARE_HANDLER(clearReg) {}
    DECLARE_HANDLER(swap) {}
    DECLARE_HANDLER(loadThis) {}
    DECLARE_HANDLER(loadNewTarget) {}
    DECLARE_HANDLER(loadSuperConstructor) {}
    DECLARE_HANDLER(loadUndefined) {}
    DECLARE_HANDLER(loadNull) {}
    DECLARE_HANDLER(loadTrue) {}
    DECLARE_HANDLER(loadFalse) {}
    DECLARE_HANDLER(loadEmpty) {}
    DECLARE_HANDLER(loadInt32) {}
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
    DECLARE_HANDLER(createFunction) {}
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

    DECLARE_HANDLER(createLexicalEnvironment) {}
    DECLARE_HANDLER(pushLexicalEnvironment) {}
    DECLARE_HANDLER(popLexicalEnvironment) {}
    DECLARE_HANDLER(getContext) {}
    DECLARE_HANDLER(putContext) {}
    DECLARE_HANDLER(checkTDZContext) {}
    DECLARE_HANDLER(materializeScope) {}
    DECLARE_HANDLER(resolveName) {}

    DECLARE_HANDLER(getGlobalLexical) {}
    DECLARE_HANDLER(putGlobalLexical) {}
    DECLARE_HANDLER(initGlobalLexical) {}
    DECLARE_HANDLER(getGlobalVar) {}
    DECLARE_HANDLER(putGlobalVar) {}
    DECLARE_HANDLER(initGlobalVar) {}
    DECLARE_HANDLER(getGlobalProperty) {}
    DECLARE_HANDLER(putGlobalProperty) {}
    DECLARE_HANDLER(typeofGlobal) {}
    DECLARE_HANDLER(deleteGlobal) {}

    DECLARE_HANDLER(getById) {}
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
    DECLARE_HANDLER(toBoolean) {}
    DECLARE_HANDLER(toPropertyKey) {}
    DECLARE_HANDLER(isCallable) {}
    DECLARE_HANDLER(isConstructor) {}
    DECLARE_HANDLER(typeofValue) {}
    DECLARE_HANDLER(voidOp) {}
    DECLARE_HANDLER(logicalNot) {}
    DECLARE_HANDLER(bitNot) {}
    DECLARE_HANDLER(negate) {}
    DECLARE_HANDLER(increment) {}
    DECLARE_HANDLER(decrement) {}

    DECLARE_HANDLER(add) {}
    DECLARE_HANDLER(sub) {}
    DECLARE_HANDLER(mul) {}
    DECLARE_HANDLER(div) {}
    DECLARE_HANDLER(mod) {}
    DECLARE_HANDLER(pow) {}
    DECLARE_HANDLER(bitAnd) {}
    DECLARE_HANDLER(bitOr) {}
    DECLARE_HANDLER(bitXor) {}
    DECLARE_HANDLER(leftShift) {}
    DECLARE_HANDLER(rightShift) {}
    DECLARE_HANDLER(unsignedRightShift) {}
    DECLARE_HANDLER(equal) {}
    DECLARE_HANDLER(notEqual) {}
    DECLARE_HANDLER(strictEqual) {}
    DECLARE_HANDLER(strictNotEqual) {}
    DECLARE_HANDLER(lessThan) {}
    DECLARE_HANDLER(lessThanOrEqual) {}
    DECLARE_HANDLER(greaterThan) {}
    DECLARE_HANDLER(greaterThanOrEqual) {}
    DECLARE_HANDLER(sameValue) {}
    DECLARE_HANDLER(sameValueZero) {}
    DECLARE_HANDLER(instanceOf) {}
    DECLARE_HANDLER(inOperator) {}

    DECLARE_HANDLER(call) {}
    DECLARE_HANDLER(callDirect) {}
    DECLARE_HANDLER(callEval) {}
    DECLARE_HANDLER(callVarargs) {}
    DECLARE_HANDLER(tailCall) {}
    DECLARE_HANDLER(construct) {}
    DECLARE_HANDLER(constructVarargs) {}
    DECLARE_HANDLER(superConstruct) {}
    DECLARE_HANDLER(superConstructVarargs) {}

    DECLARE_HANDLER(jump) {}
    DECLARE_HANDLER(jumpIfTrue) {}
    DECLARE_HANDLER(jumpIfFalse) {}
    DECLARE_HANDLER(jumpIfNull) {}
    DECLARE_HANDLER(jumpIfUndefined) {}
    DECLARE_HANDLER(jumpIfNullish) {}
    DECLARE_HANDLER(jumpIfNotNullish) {}
    DECLARE_HANDLER(jumpIfEmpty) {}
    DECLARE_HANDLER(switchInt) {}
    DECLARE_HANDLER(switchString) {}

    DECLARE_HANDLER(returnValue) {}
    DECLARE_HANDLER(returnUndefined) {}
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
}