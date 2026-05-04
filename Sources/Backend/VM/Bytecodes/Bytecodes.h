#pragma once
#include <cstdint>

// Common types
using Reg = uint16_t;
using LocalSlot = uint16_t;
using ArgSlot = uint16_t;
using ContextSlot = uint16_t;
using GlobalSlot = uint16_t;
using ModuleSlot = uint16_t;
using CPIndex = uint32_t;
using FunctionID = uint32_t;
using HandlerID = uint16_t;
using ProfileSlot = uint16_t;
using ICSlot = uint16_t;
using CallSlot = uint16_t;
using JumpOffset = int32_t;
using ArgCount = uint16_t;
using ContextDepth = uint8_t;
using ScopeLayoutID = uint16_t;
using StructureSetID = uint16_t;
using RuntimeID = uint16_t;
using IntrinsicID = uint16_t;
using PropertyFlags = uint8_t;
using IteratorKind = uint8_t;
using ResumeKind = uint8_t;


// Bytecode Ops
#define BC_ALL(BC)                                                         \
    BC(nop,                         OPERANDS_NONE)                         \
    BC(coverageMark,                OPERANDS_COVERAGE_MARK)                \
    BC(debugTrap,                   OPERANDS_DEBUG_TRAP)                   \
    BC(debugLog,                    OPERANDS_DEBUG_LOG)                    \
    BC(debugDumpScope,              OPERANDS_NONE)                         \
    BC(debugDumpIC,                 OPERANDS_DEBUG_DUMP_IC)                \
    BC(unreachable,                 OPERANDS_NONE)                         \
    BC(halt,                        OPERANDS_NONE)                         \
    BC(enterGlobal,                 OPERANDS_NONE)                         \
    BC(enterFunction,               OPERANDS_NONE)                         \
    BC(move,                        OPERANDS_MOVE)                         \
    BC(clearReg,                    OPERANDS_CLEAR_REG)                    \
    BC(swap,                        OPERANDS_SWAP)                         \
    BC(loadThis,                    OPERANDS_DST)                          \
    BC(loadNewTarget,               OPERANDS_DST)                          \
    BC(loadSuperConstructor,        OPERANDS_DST)                          \
    BC(loadUndefined,               OPERANDS_DST)                          \
    BC(loadNull,                    OPERANDS_DST)                          \
    BC(loadTrue,                    OPERANDS_DST)                          \
    BC(loadFalse,                   OPERANDS_DST)                          \
    BC(loadEmpty,                   OPERANDS_DST)                          \
    BC(loadInt32,                   OPERANDS_LOAD_INT32)                   \
    BC(loadDouble,                  OPERANDS_LOAD_CONST)                   \
    BC(loadString,                  OPERANDS_LOAD_CONST)                   \
    BC(loadBigInt,                  OPERANDS_LOAD_CONST)                   \
    BC(loadSymbol,                  OPERANDS_LOAD_CONST)                   \
    BC(loadConst,                   OPERANDS_LOAD_CONST)                   \
    BC(newObject,                   OPERANDS_DST)                          \
    BC(newObjectWithProto,          OPERANDS_NEW_OBJECT_WITH_PROTO)         \
    BC(newArray,                    OPERANDS_NEW_ARRAY)                    \
    BC(newArrayWithSize,            OPERANDS_NEW_ARRAY_WITH_SIZE)           \
    BC(newArrayWithSpread,          OPERANDS_NEW_ARRAY)                    \
    BC(newObjectLiteral,            OPERANDS_LOAD_CONST)                   \
    BC(newArrayLiteral,             OPERANDS_LOAD_CONST)                   \
    BC(newRegExp,                   OPERANDS_LOAD_CONST)                   \
    BC(createFunction,              OPERANDS_CREATE_FUNCTION)              \
    BC(createClosure,               OPERANDS_CREATE_CLOSURE)               \
    BC(createArrowClosure,          OPERANDS_CREATE_CLOSURE)               \
    BC(createGeneratorClosure,      OPERANDS_CREATE_CLOSURE)               \
    BC(createAsyncClosure,          OPERANDS_CREATE_CLOSURE)               \
    BC(createClass,                 OPERANDS_CREATE_CLASS)                 \
    BC(setHomeObject,               OPERANDS_SET_HOME_OBJECT)              \
    BC(getArgument,                 OPERANDS_GET_ARGUMENT)                 \
    BC(putArgument,                 OPERANDS_PUT_ARGUMENT)                 \
    BC(getLocal,                    OPERANDS_GET_LOCAL)                    \
    BC(putLocal,                    OPERANDS_PUT_LOCAL)                    \
    BC(initLocal,                   OPERANDS_PUT_LOCAL)                    \
    BC(checkTDZLocal,               OPERANDS_CHECK_TDZ_LOCAL)              \
    BC(createLexicalEnvironment,    OPERANDS_CREATE_LEXICAL_ENVIRONMENT)   \
    BC(pushLexicalEnvironment,      OPERANDS_PUSH_LEXICAL_ENVIRONMENT)     \
    BC(popLexicalEnvironment,       OPERANDS_NONE)                         \
    BC(getContext,                  OPERANDS_GET_CONTEXT)                  \
    BC(putContext,                  OPERANDS_PUT_CONTEXT)                  \
    BC(checkTDZContext,             OPERANDS_CHECK_TDZ_CONTEXT)            \
    BC(materializeScope,            OPERANDS_MATERIALIZE_SCOPE)            \
    BC(resolveName,                 OPERANDS_RESOLVE_NAME)                 \
    BC(getGlobalLexical,            OPERANDS_GET_GLOBAL_LEXICAL)           \
    BC(putGlobalLexical,            OPERANDS_PUT_GLOBAL_LEXICAL)           \
    BC(initGlobalLexical,           OPERANDS_INIT_GLOBAL_LEXICAL)          \
    BC(getGlobalVar,                OPERANDS_GET_GLOBAL_VAR)               \
    BC(putGlobalVar,                OPERANDS_PUT_GLOBAL_VAR)               \
    BC(initGlobalVar,               OPERANDS_INIT_GLOBAL_VAR)              \
    BC(getGlobalProperty,           OPERANDS_GET_GLOBAL_PROPERTY)          \
    BC(putGlobalProperty,           OPERANDS_PUT_GLOBAL_PROPERTY)          \
    BC(typeofGlobal,                OPERANDS_TYPEOF_GLOBAL)                \
    BC(deleteGlobal,                OPERANDS_DELETE_GLOBAL)                \
    BC(getById,                     OPERANDS_GET_BY_ID)                    \
    BC(putById,                     OPERANDS_PUT_BY_ID)                    \
    BC(getByVal,                    OPERANDS_GET_BY_VAL)                   \
    BC(putByVal,                    OPERANDS_PUT_BY_VAL)                   \
    BC(getByIdWithThis,             OPERANDS_GET_BY_ID_WITH_THIS)          \
    BC(getByValWithThis,            OPERANDS_GET_BY_VAL_WITH_THIS)         \
    BC(getMethodById,               OPERANDS_GET_METHOD_BY_ID)             \
    BC(getMethodByVal,              OPERANDS_GET_METHOD_BY_VAL)            \
    BC(defineOwnById,               OPERANDS_DEFINE_OWN_BY_ID)             \
    BC(defineOwnByVal,              OPERANDS_DEFINE_OWN_BY_VAL)            \
    BC(deleteById,                  OPERANDS_DELETE_BY_ID)                 \
    BC(deleteByVal,                 OPERANDS_DELETE_BY_VAL)                \
    BC(hasProperty,                 OPERANDS_HAS_PROPERTY)                 \
    BC(inById,                      OPERANDS_IN_BY_ID)                     \
    BC(inByVal,                     OPERANDS_IN_BY_VAL)                    \
    BC(getPrivateById,              OPERANDS_GET_PRIVATE_BY_ID)            \
    BC(putPrivateById,              OPERANDS_PUT_PRIVATE_BY_ID)            \
    BC(definePrivateById,           OPERANDS_PUT_PRIVATE_BY_ID)            \
    BC(hasPrivateById,              OPERANDS_GET_PRIVATE_BY_ID)            \
    BC(getSuperById,                OPERANDS_GET_SUPER_BY_ID)              \
    BC(putSuperById,                OPERANDS_PUT_SUPER_BY_ID)              \
    BC(getSuperByVal,               OPERANDS_GET_SUPER_BY_VAL)             \
    BC(putSuperByVal,               OPERANDS_PUT_SUPER_BY_VAL)             \
    BC(getLength,                   OPERANDS_GET_LENGTH)                   \
    BC(putLength,                   OPERANDS_PUT_LENGTH)                   \
    BC(getByIndex,                  OPERANDS_GET_BY_INDEX)                 \
    BC(putByIndex,                  OPERANDS_PUT_BY_INDEX)                 \
    BC(arrayPush,                   OPERANDS_ARRAY_PUSH)                   \
    BC(arrayPop,                    OPERANDS_ARRAY_POP)                    \
    BC(toNumber,                    OPERANDS_UNARY_PROFILE)                \
    BC(toNumeric,                   OPERANDS_UNARY_PROFILE)                \
    BC(toString,                    OPERANDS_UNARY_PROFILE)                \
    BC(toObject,                    OPERANDS_UNARY_PROFILE)                \
    BC(toBoolean,                   OPERANDS_UNARY_PROFILE)                \
    BC(toPropertyKey,               OPERANDS_UNARY_PROFILE)                \
    BC(isCallable,                  OPERANDS_UNARY_NO_PROFILE)             \
    BC(isConstructor,               OPERANDS_UNARY_NO_PROFILE)             \
    BC(typeofValue,                 OPERANDS_UNARY_PROFILE)                \
    BC(voidOp,                      OPERANDS_UNARY_NO_PROFILE)             \
    BC(logicalNot,                  OPERANDS_UNARY_NO_PROFILE)             \
    BC(bitNot,                      OPERANDS_UNARY_PROFILE)                \
    BC(negate,                      OPERANDS_UNARY_PROFILE)                \
    BC(increment,                   OPERANDS_UNARY_PROFILE)                \
    BC(decrement,                   OPERANDS_UNARY_PROFILE)                \
    BC(add,                         OPERANDS_BINARY_PROFILE)               \
    BC(sub,                         OPERANDS_BINARY_PROFILE)               \
    BC(mul,                         OPERANDS_BINARY_PROFILE)               \
    BC(div,                         OPERANDS_BINARY_PROFILE)               \
    BC(mod,                         OPERANDS_BINARY_PROFILE)               \
    BC(pow,                         OPERANDS_BINARY_PROFILE)               \
    BC(bitAnd,                      OPERANDS_BINARY_PROFILE)               \
    BC(bitOr,                       OPERANDS_BINARY_PROFILE)               \
    BC(bitXor,                      OPERANDS_BINARY_PROFILE)               \
    BC(leftShift,                   OPERANDS_BINARY_PROFILE)               \
    BC(rightShift,                  OPERANDS_BINARY_PROFILE)               \
    BC(unsignedRightShift,          OPERANDS_BINARY_PROFILE)               \
    BC(equal,                       OPERANDS_BINARY_PROFILE)               \
    BC(notEqual,                    OPERANDS_BINARY_PROFILE)               \
    BC(strictEqual,                 OPERANDS_BINARY_PROFILE)               \
    BC(strictNotEqual,              OPERANDS_BINARY_PROFILE)               \
    BC(lessThan,                    OPERANDS_BINARY_PROFILE)               \
    BC(lessThanOrEqual,             OPERANDS_BINARY_PROFILE)               \
    BC(greaterThan,                 OPERANDS_BINARY_PROFILE)               \
    BC(greaterThanOrEqual,          OPERANDS_BINARY_PROFILE)               \
    BC(sameValue,                   OPERANDS_BINARY_PROFILE)               \
    BC(sameValueZero,               OPERANDS_BINARY_PROFILE)               \
    BC(instanceOf,                  OPERANDS_INSTANCE_OF)                  \
    BC(inOperator,                  OPERANDS_IN_OPERATOR)                  \
    BC(call,                        OPERANDS_CALL)                         \
    BC(callDirect,                  OPERANDS_CALL_DIRECT)                  \
    BC(callEval,                    OPERANDS_CALL)                         \
    BC(callVarargs,                 OPERANDS_CALL_VARARGS)                 \
    BC(tailCall,                    OPERANDS_TAIL_CALL)                    \
    BC(construct,                   OPERANDS_CONSTRUCT)                    \
    BC(constructVarargs,            OPERANDS_CONSTRUCT_VARARGS)            \
    BC(superConstruct,              OPERANDS_SUPER_CONSTRUCT)              \
    BC(superConstructVarargs,       OPERANDS_SUPER_CONSTRUCT_VARARGS)      \
    BC(jump,                        OPERANDS_JUMP)                         \
    BC(jumpIfTrue,                  OPERANDS_JUMP_IF_REG)                  \
    BC(jumpIfFalse,                 OPERANDS_JUMP_IF_REG)                  \
    BC(jumpIfNull,                  OPERANDS_JUMP_IF_REG)                  \
    BC(jumpIfUndefined,             OPERANDS_JUMP_IF_REG)                  \
    BC(jumpIfNullish,               OPERANDS_JUMP_IF_REG)                  \
    BC(jumpIfNotNullish,            OPERANDS_JUMP_IF_REG)                  \
    BC(jumpIfEmpty,                 OPERANDS_JUMP_IF_REG)                  \
    BC(switchInt,                   OPERANDS_SWITCH)                       \
    BC(switchString,                OPERANDS_SWITCH)                       \
    BC(returnValue,                 OPERANDS_RETURN_VALUE)                 \
    BC(returnUndefined,             OPERANDS_NONE)                         \
    BC(throwValue,                  OPERANDS_THROW_VALUE)                  \
    BC(rethrow,                     OPERANDS_NONE)                         \
    BC(enterCatch,                  OPERANDS_ENTER_HANDLER)                \
    BC(enterFinally,                OPERANDS_ENTER_HANDLER)                \
    BC(getException,                OPERANDS_DST)                          \
    BC(clearException,              OPERANDS_NONE)                         \
    BC(getIterator,                 OPERANDS_GET_ITERATOR)                 \
    BC(iteratorNext,                OPERANDS_ITERATOR_PROFILE)             \
    BC(iteratorValue,               OPERANDS_ITERATOR_PROFILE)             \
    BC(iteratorDone,                OPERANDS_ITERATOR_PROFILE)             \
    BC(iteratorClose,               OPERANDS_ITERATOR_CLOSE)               \
    BC(getModuleVariable,           OPERANDS_GET_MODULE_VARIABLE)          \
    BC(putModuleVariable,           OPERANDS_PUT_MODULE_VARIABLE)          \
    BC(getImportMeta,               OPERANDS_DST)                          \
    BC(createMethod,                OPERANDS_CREATE_METHOD)                \
    BC(defineClassMethod,           OPERANDS_DEFINE_CLASS_METHOD)          \
    BC(defineInstanceField,         OPERANDS_DEFINE_INSTANCE_FIELD)        \
    BC(defineStaticField,           OPERANDS_DEFINE_STATIC_FIELD)          \
    BC(createPromise,               OPERANDS_DST)                          \
    BC(fulfillPromise,              OPERANDS_FULFILL_PROMISE)              \
    BC(rejectPromise,               OPERANDS_REJECT_PROMISE)               \
    BC(promiseResolve,              OPERANDS_PROMISE_RESOLVE)              \
    BC(promiseThen,                 OPERANDS_PROMISE_THEN)                 \
    BC(enqueueMicrotask,            OPERANDS_ENQUEUE_MICROTASK)            \
    BC(asyncEnter,                  OPERANDS_ASYNC_ENTER)                  \
    BC(awaitSuspend,                OPERANDS_AWAIT_SUSPEND)                \
    BC(asyncResumePoint,            OPERANDS_RESUME_POINT_U16)             \
    BC(createGeneratorObject,       OPERANDS_CREATE_GENERATOR_OBJECT)      \
    BC(createAsyncGeneratorObject,  OPERANDS_CREATE_GENERATOR_OBJECT)      \
    BC(generatorEnter,              OPERANDS_NONE)                         \
    BC(getResumeValue,              OPERANDS_DST)                          \
    BC(getResumeKind,               OPERANDS_DST)                          \
    BC(jumpIfResumeKind,            OPERANDS_JUMP_IF_RESUME_KIND)          \
    BC(generatorSuspend,            OPERANDS_GENERATOR_SUSPEND)            \
    BC(asyncGeneratorSuspend,       OPERANDS_GENERATOR_SUSPEND)            \
    BC(yieldStar,                   OPERANDS_YIELD_STAR)                   \
    BC(generatorReturn,             OPERANDS_GENERATOR_RETURN)             \
    BC(generatorThrow,              OPERANDS_GENERATOR_THROW)              \
    BC(asyncGeneratorReturn,        OPERANDS_GENERATOR_RETURN)             \
    BC(asyncGeneratorThrow,         OPERANDS_GENERATOR_THROW)              \
    BC(resumePoint,                 OPERANDS_RESUME_POINT_U16)             \
    BC(profileValue,                OPERANDS_PROFILE_REG)                  \
    BC(profileType,                 OPERANDS_PROFILE_REG)                  \
    BC(profileBranch,               OPERANDS_PROFILE_BRANCH)               \
    BC(profileCall,                 OPERANDS_PROFILE_CALL)                 \
    BC(checkStructure,              OPERANDS_CHECK_STRUCTURE)              \
    BC(checkCell,                   OPERANDS_CHECK_REG_FAIL)               \
    BC(checkNumber,                 OPERANDS_CHECK_REG_FAIL)               \
    BC(checkInt32,                  OPERANDS_CHECK_REG_FAIL)               \
    BC(checkString,                 OPERANDS_CHECK_REG_FAIL)               \
    BC(checkObject,                 OPERANDS_CHECK_REG_FAIL)               \
    BC(checkArray,                  OPERANDS_CHECK_REG_FAIL)               \
    BC(checkInt32Index,             OPERANDS_CHECK_REG_FAIL)               \
    BC(checkStack,                  OPERANDS_NONE)                         \
    BC(runtimeCall,                 OPERANDS_RUNTIME_CALL)                 \
    BC(intrinsicCall,               OPERANDS_INTRINSIC_CALL)

// Bytecode Operands

#define OPERANDS_NONE(V)

#define OPERANDS_DST(V) \
    V(Reg, dst)

#define OPERANDS_COVERAGE_MARK(V) \
    V(uint32_t, id)

#define OPERANDS_DEBUG_TRAP(V) \
    V(uint16_t, id)

#define OPERANDS_DEBUG_LOG(V) \
    V(Reg, reg)

#define OPERANDS_DEBUG_DUMP_IC(V) \
    V(ICSlot, slot)

#define OPERANDS_MOVE(V) \
    V(Reg, dst) \
    V(Reg, src)

#define OPERANDS_CLEAR_REG(V) \
    V(Reg, reg)

#define OPERANDS_SWAP(V) \
    V(Reg, lhs) \
    V(Reg, rhs)

#define OPERANDS_LOAD_INT32(V) \
    V(Reg, dst) \
    V(int32_t, value)

#define OPERANDS_LOAD_CONST(V) \
    V(Reg, dst) \
    V(CPIndex, constant)

#define OPERANDS_NEW_OBJECT_WITH_PROTO(V) \
    V(Reg, dst) \
    V(Reg, proto)

#define OPERANDS_NEW_ARRAY(V) \
    V(Reg, dst) \
    V(Reg, firstElement) \
    V(uint16_t, count)

#define OPERANDS_NEW_ARRAY_WITH_SIZE(V) \
    V(Reg, dst) \
    V(uint16_t, minimumCapacity)

#define OPERANDS_CREATE_FUNCTION(V) \
    V(Reg, dst) \
    V(FunctionID, function)

#define OPERANDS_CREATE_CLOSURE(V) \
    V(Reg, dst) \
    V(FunctionID, function) \
    V(Reg, environment)

#define OPERANDS_CREATE_CLASS(V) \
    V(Reg, dst) \
    V(FunctionID, constructor) \
    V(Reg, protoParent) \
    V(CPIndex, metadata)

#define OPERANDS_SET_HOME_OBJECT(V) \
    V(Reg, function) \
    V(Reg, homeObject)

#define OPERANDS_GET_ARGUMENT(V) \
    V(Reg, dst) \
    V(ArgSlot, slot)

#define OPERANDS_PUT_ARGUMENT(V) \
    V(ArgSlot, slot) \
    V(Reg, src)

#define OPERANDS_GET_LOCAL(V) \
    V(Reg, dst) \
    V(LocalSlot, slot)

#define OPERANDS_PUT_LOCAL(V) \
    V(LocalSlot, slot) \
    V(Reg, src)

#define OPERANDS_CHECK_TDZ_LOCAL(V) \
    V(LocalSlot, slot)

#define OPERANDS_CREATE_LEXICAL_ENVIRONMENT(V) \
    V(Reg, dst) \
    V(ScopeLayoutID, layout)

#define OPERANDS_PUSH_LEXICAL_ENVIRONMENT(V) \
    V(Reg, environment)

#define OPERANDS_GET_CONTEXT(V) \
    V(Reg, dst) \
    V(ContextDepth, depth) \
    V(ContextSlot, slot)

#define OPERANDS_PUT_CONTEXT(V) \
    V(ContextDepth, depth) \
    V(ContextSlot, slot) \
    V(Reg, src)

#define OPERANDS_CHECK_TDZ_CONTEXT(V) \
    V(ContextDepth, depth) \
    V(ContextSlot, slot)

#define OPERANDS_MATERIALIZE_SCOPE(V) \
    V(Reg, dst) \
    V(ContextDepth, depth)

#define OPERANDS_RESOLVE_NAME(V) \
    V(Reg, dst) \
    V(CPIndex, name) \
    V(ProfileSlot, profile)

#define OPERANDS_GET_GLOBAL_LEXICAL(V) \
    V(Reg, dst) \
    V(GlobalSlot, slot) \
    V(ProfileSlot, profile)

#define OPERANDS_PUT_GLOBAL_LEXICAL(V) \
    V(GlobalSlot, slot) \
    V(Reg, src) \
    V(ProfileSlot, profile)

#define OPERANDS_INIT_GLOBAL_LEXICAL(V) \
    V(GlobalSlot, slot) \
    V(Reg, src)

#define OPERANDS_GET_GLOBAL_VAR(V) \
    V(Reg, dst) \
    V(GlobalSlot, slot) \
    V(ICSlot, cache)

#define OPERANDS_PUT_GLOBAL_VAR(V) \
    V(GlobalSlot, slot) \
    V(Reg, src) \
    V(ICSlot, cache)

#define OPERANDS_INIT_GLOBAL_VAR(V) \
    V(GlobalSlot, slot) \
    V(Reg, src)

#define OPERANDS_GET_GLOBAL_PROPERTY(V) \
    V(Reg, dst) \
    V(CPIndex, name) \
    V(ICSlot, cache)

#define OPERANDS_PUT_GLOBAL_PROPERTY(V) \
    V(CPIndex, name) \
    V(Reg, src) \
    V(ICSlot, cache)

#define OPERANDS_TYPEOF_GLOBAL(V) \
    V(Reg, dst) \
    V(GlobalSlot, slot) \
    V(ProfileSlot, profile)

#define OPERANDS_DELETE_GLOBAL(V) \
    V(Reg, dst) \
    V(GlobalSlot, slot)

#define OPERANDS_GET_BY_ID(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(CPIndex, name) \
    V(ICSlot, cache)

#define OPERANDS_PUT_BY_ID(V) \
    V(Reg, base) \
    V(CPIndex, name) \
    V(Reg, value) \
    V(ICSlot, cache)

#define OPERANDS_GET_BY_VAL(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(Reg, key) \
    V(ICSlot, cache)

#define OPERANDS_PUT_BY_VAL(V) \
    V(Reg, base) \
    V(Reg, key) \
    V(Reg, value) \
    V(ICSlot, cache)

#define OPERANDS_GET_BY_ID_WITH_THIS(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(Reg, thisValue) \
    V(CPIndex, name) \
    V(ICSlot, cache)

#define OPERANDS_GET_BY_VAL_WITH_THIS(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(Reg, key) \
    V(Reg, thisValue) \
    V(ICSlot, cache)

#define OPERANDS_GET_METHOD_BY_ID(V) \
    V(Reg, callee) \
    V(Reg, thisValue) \
    V(Reg, base) \
    V(CPIndex, name) \
    V(ICSlot, cache)

#define OPERANDS_GET_METHOD_BY_VAL(V) \
    V(Reg, callee) \
    V(Reg, thisValue) \
    V(Reg, base) \
    V(Reg, key) \
    V(ICSlot, cache)

#define OPERANDS_DEFINE_OWN_BY_ID(V) \
    V(Reg, base) \
    V(CPIndex, name) \
    V(Reg, value) \
    V(PropertyFlags, flags)

#define OPERANDS_DEFINE_OWN_BY_VAL(V) \
    V(Reg, base) \
    V(Reg, key) \
    V(Reg, value) \
    V(PropertyFlags, flags)

#define OPERANDS_DELETE_BY_ID(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(CPIndex, name) \
    V(ProfileSlot, profile)

#define OPERANDS_DELETE_BY_VAL(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(Reg, key) \
    V(ProfileSlot, profile)

#define OPERANDS_HAS_PROPERTY(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(Reg, key) \
    V(ProfileSlot, profile)

#define OPERANDS_IN_BY_ID(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(CPIndex, name) \
    V(ProfileSlot, profile)

#define OPERANDS_IN_BY_VAL(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(Reg, key) \
    V(ProfileSlot, profile)

#define OPERANDS_GET_PRIVATE_BY_ID(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(CPIndex, name)

#define OPERANDS_PUT_PRIVATE_BY_ID(V) \
    V(Reg, base) \
    V(CPIndex, name) \
    V(Reg, value)

#define OPERANDS_GET_SUPER_BY_ID(V) \
    V(Reg, dst) \
    V(Reg, thisValue) \
    V(Reg, homeObject) \
    V(CPIndex, name) \
    V(ICSlot, cache)

#define OPERANDS_PUT_SUPER_BY_ID(V) \
    V(Reg, thisValue) \
    V(Reg, homeObject) \
    V(CPIndex, name) \
    V(Reg, value) \
    V(ICSlot, cache)

#define OPERANDS_GET_SUPER_BY_VAL(V) \
    V(Reg, dst) \
    V(Reg, thisValue) \
    V(Reg, homeObject) \
    V(Reg, key) \
    V(ICSlot, cache)

#define OPERANDS_PUT_SUPER_BY_VAL(V) \
    V(Reg, thisValue) \
    V(Reg, homeObject) \
    V(Reg, key) \
    V(Reg, value) \
    V(ICSlot, cache)

#define OPERANDS_GET_LENGTH(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(ICSlot, cache)

#define OPERANDS_PUT_LENGTH(V) \
    V(Reg, base) \
    V(Reg, value) \
    V(ICSlot, cache)

#define OPERANDS_GET_BY_INDEX(V) \
    V(Reg, dst) \
    V(Reg, base) \
    V(uint32_t, index) \
    V(ICSlot, cache)

#define OPERANDS_PUT_BY_INDEX(V) \
    V(Reg, base) \
    V(uint32_t, index) \
    V(Reg, value) \
    V(ICSlot, cache)

#define OPERANDS_ARRAY_PUSH(V) \
    V(Reg, dst) \
    V(Reg, array) \
    V(Reg, value) \
    V(ProfileSlot, profile)

#define OPERANDS_ARRAY_POP(V) \
    V(Reg, dst) \
    V(Reg, array) \
    V(ProfileSlot, profile)

#define OPERANDS_UNARY_PROFILE(V) \
    V(Reg, dst) \
    V(Reg, src) \
    V(ProfileSlot, profile)

#define OPERANDS_UNARY_NO_PROFILE(V) \
    V(Reg, dst) \
    V(Reg, src)

#define OPERANDS_BINARY_PROFILE(V) \
    V(Reg, dst) \
    V(Reg, lhs) \
    V(Reg, rhs) \
    V(ProfileSlot, profile)

#define OPERANDS_INSTANCE_OF(V) \
    V(Reg, dst) \
    V(Reg, value) \
    V(Reg, constructor) \
    V(ProfileSlot, profile)

#define OPERANDS_IN_OPERATOR(V) \
    V(Reg, dst) \
    V(Reg, key) \
    V(Reg, base) \
    V(ProfileSlot, profile)

#define OPERANDS_CALL(V) \
    V(Reg, dst) \
    V(Reg, callee) \
    V(Reg, thisValue) \
    V(Reg, argsBase) \
    V(ArgCount, argc) \
    V(CallSlot, call)

#define OPERANDS_CALL_DIRECT(V) \
    V(Reg, dst) \
    V(FunctionID, function) \
    V(Reg, thisValue) \
    V(Reg, argsBase) \
    V(ArgCount, argc) \
    V(CallSlot, call)

#define OPERANDS_CALL_VARARGS(V) \
    V(Reg, dst) \
    V(Reg, callee) \
    V(Reg, thisValue) \
    V(Reg, argsArray) \
    V(CallSlot, call)

#define OPERANDS_TAIL_CALL(V) \
    V(Reg, callee) \
    V(Reg, thisValue) \
    V(Reg, argsBase) \
    V(ArgCount, argc) \
    V(CallSlot, call)

#define OPERANDS_CONSTRUCT(V) \
    V(Reg, dst) \
    V(Reg, callee) \
    V(Reg, argsBase) \
    V(ArgCount, argc) \
    V(CallSlot, call)

#define OPERANDS_CONSTRUCT_VARARGS(V) \
    V(Reg, dst) \
    V(Reg, callee) \
    V(Reg, argsArray) \
    V(CallSlot, call)

#define OPERANDS_SUPER_CONSTRUCT(V) \
    V(Reg, dst) \
    V(Reg, callee) \
    V(Reg, argsBase) \
    V(ArgCount, argc) \
    V(CallSlot, call)

#define OPERANDS_SUPER_CONSTRUCT_VARARGS(V) \
    V(Reg, dst) \
    V(Reg, callee) \
    V(Reg, argsArray) \
    V(CallSlot, call)

#define OPERANDS_JUMP(V) \
    V(JumpOffset, offset)

#define OPERANDS_JUMP_IF_REG(V) \
    V(Reg, value) \
    V(JumpOffset, offset)

#define OPERANDS_SWITCH(V) \
    V(Reg, value) \
    V(CPIndex, table)

#define OPERANDS_RETURN_VALUE(V) \
    V(Reg, value)

#define OPERANDS_THROW_VALUE(V) \
    V(Reg, value)

#define OPERANDS_ENTER_HANDLER(V) \
    V(HandlerID, handler)

#define OPERANDS_GET_ITERATOR(V) \
    V(Reg, dst) \
    V(Reg, value) \
    V(IteratorKind, kind) \
    V(ProfileSlot, profile)

#define OPERANDS_ITERATOR_PROFILE(V) \
    V(Reg, dst) \
    V(Reg, iterator) \
    V(ProfileSlot, profile)

#define OPERANDS_ITERATOR_CLOSE(V) \
    V(Reg, iterator) \
    V(ProfileSlot, profile)

#define OPERANDS_GET_MODULE_VARIABLE(V) \
    V(Reg, dst) \
    V(ModuleSlot, slot)

#define OPERANDS_PUT_MODULE_VARIABLE(V) \
    V(ModuleSlot, slot) \
    V(Reg, src)

#define OPERANDS_CREATE_METHOD(V) \
    V(Reg, dst) \
    V(FunctionID, function) \
    V(Reg, homeObject)

#define OPERANDS_DEFINE_CLASS_METHOD(V) \
    V(Reg, classObject) \
    V(CPIndex, name) \
    V(Reg, function) \
    V(PropertyFlags, flags)

#define OPERANDS_DEFINE_INSTANCE_FIELD(V) \
    V(Reg, thisValue) \
    V(CPIndex, name) \
    V(Reg, value) \
    V(PropertyFlags, flags)

#define OPERANDS_DEFINE_STATIC_FIELD(V) \
    V(Reg, classObject) \
    V(CPIndex, name) \
    V(Reg, value) \
    V(PropertyFlags, flags)

#define OPERANDS_FULFILL_PROMISE(V) \
    V(Reg, promise) \
    V(Reg, value)

#define OPERANDS_REJECT_PROMISE(V) \
    V(Reg, promise) \
    V(Reg, reason)

#define OPERANDS_PROMISE_RESOLVE(V) \
    V(Reg, dst) \
    V(Reg, value)

#define OPERANDS_PROMISE_THEN(V) \
    V(Reg, dst) \
    V(Reg, promise) \
    V(Reg, onFulfilled) \
    V(Reg, onRejected)

#define OPERANDS_ENQUEUE_MICROTASK(V) \
    V(Reg, job)

#define OPERANDS_ASYNC_ENTER(V) \
    V(Reg, promise)

#define OPERANDS_AWAIT_SUSPEND(V) \
    V(Reg, value) \
    V(Reg, promise) \
    V(uint16_t, resumePoint)

#define OPERANDS_RESUME_POINT_U16(V) \
    V(uint16_t, id)

#define OPERANDS_CREATE_GENERATOR_OBJECT(V) \
    V(Reg, dst) \
    V(FunctionID, function)

#define OPERANDS_JUMP_IF_RESUME_KIND(V) \
    V(ResumeKind, kind) \
    V(JumpOffset, offset)

#define OPERANDS_GENERATOR_SUSPEND(V) \
    V(Reg, dst) \
    V(Reg, value) \
    V(uint16_t, resumePoint)

#define OPERANDS_YIELD_STAR(V) \
    V(Reg, dst) \
    V(Reg, iterator) \
    V(uint16_t, resumePoint)

#define OPERANDS_GENERATOR_RETURN(V) \
    V(Reg, value)

#define OPERANDS_GENERATOR_THROW(V) \
    V(Reg, value)

#define OPERANDS_PROFILE_REG(V) \
    V(Reg, reg) \
    V(ProfileSlot, profile)

#define OPERANDS_PROFILE_BRANCH(V) \
    V(Reg, condition) \
    V(ProfileSlot, profile)

#define OPERANDS_PROFILE_CALL(V) \
    V(Reg, callee) \
    V(CallSlot, call)

#define OPERANDS_CHECK_STRUCTURE(V) \
    V(Reg, reg) \
    V(StructureSetID, structures) \
    V(JumpOffset, fail)

#define OPERANDS_CHECK_REG_FAIL(V) \
    V(Reg, reg) \
    V(JumpOffset, fail)

#define OPERANDS_RUNTIME_CALL(V) \
    V(Reg, dst) \
    V(RuntimeID, id) \
    V(Reg, argsBase) \
    V(ArgCount, argc)

#define OPERANDS_INTRINSIC_CALL(V) \
    V(Reg, dst) \
    V(IntrinsicID, id) \
    V(Reg, argsBase) \
    V(ArgCount, argc)

//-------------------------------------------------------------------------------------

namespace JSBackend::Bytecode {

    enum class Op : uint16_t {
    #define DECL_OP(name, operands) name,
        BC_ALL(DECL_OP)
    #undef DECL_OP
    };

    #define BC_OPERAND_SIZE(type, name) + sizeof(type)
    #define BC_WHOLE_INST_SIZE_CASE(name, operands) \
        case Op::name: return sizeof(Op) operands(BC_OPERAND_SIZE);

    inline uint32_t instructionLength(Op op) {
        switch (op) {
            BC_ALL(BC_WHOLE_INST_SIZE_CASE)

        default:
            return sizeof(Op);
        }
    }

    #undef BC_OPERAND_SIZE
    #undef BC_WHOLE_INST_SIZE_CASE



}