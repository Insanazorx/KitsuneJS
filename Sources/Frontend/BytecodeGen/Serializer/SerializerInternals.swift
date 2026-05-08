enum Opcode: UInt8 {
    // MARK: - Meta / tooling
    case nop = 0x00
    case coverageMark
    case debugTrap
    case debugLog
    case debugDumpScope
    case debugDumpIC
    case unreachable
    case halt

    // MARK: - Start markers
    case enterGlobal
    case enterFunction

    // MARK: - Register movement
    case move
    case clearReg
    case swap

    // MARK: - VM implicit values
    case loadThis
    case loadNewTarget
    case loadSuperConstructor

    // MARK: - Constants / literals
    case loadUndefined
    case loadNull
    case loadTrue
    case loadFalse
    case loadEmpty
    case loadInt32
    case loadDouble
    case loadString
    case loadBigInt
    case loadSymbol
    case loadConst

    // MARK: - Object / array / function literals
    case newObject
    case newObjectWithProto
    case newArray
    case newArrayWithSize
    case newArrayWithSpread
    case newObjectLiteral
    case newArrayLiteral
    case newRegExp
    case createFunction
    case createClosure
    case createArrowClosure
    case createGeneratorClosure
    case createAsyncClosure
    case createClass
    case setHomeObject

    // MARK: - Arguments / locals
    case getArgument
    case putArgument
    case getLocal
    case putLocal
    case initLocal
    case checkTDZLocal

    // MARK: - Lexical environments / context chain
    case createLexicalEnvironment
    case pushLexicalEnvironment
    case popLexicalEnvironment
    case getContext
    case putContext
    case checkTDZContext
    case materializeScope

    // MARK: - Global / name resolution
    case resolveName
    case getGlobalLexical
    case putGlobalLexical
    case initGlobalLexical
    case getGlobalVar
    case putGlobalVar
    case initGlobalVar
    case getGlobalProperty
    case putGlobalProperty
    case typeofGlobal
    case deleteGlobal

    // MARK: - Property / method access
    case getById
    case putById
    case getByVal
    case putByVal
    case getByIdWithThis
    case getByValWithThis
    case getMethodById
    case getMethodByVal
    case defineOwnById
    case defineOwnByVal
    case deleteById
    case deleteByVal
    case hasProperty
    case inById
    case inByVal

    // MARK: - Private names
    case getPrivateById
    case putPrivateById
    case definePrivateById
    case hasPrivateById

    // MARK: - Super property access
    case getSuperById
    case putSuperById
    case getSuperByVal
    case putSuperByVal

    // MARK: - Array / indexed fast paths
    case getLength
    case putLength
    case getByIndex
    case putByIndex
    case arrayPush
    case arrayPop

    // MARK: - Conversions / unary
    case toNumber
    case toNumeric
    case toString
    case toObject
    case toBoolean
    case toPropertyKey
    case isCallable
    case isConstructor
    case typeofValue
    case voidOp
    case logicalNot
    case bitNot
    case negate
    case increment
    case decrement

    // MARK: - Binary arithmetic / bitwise
    case add
    case sub
    case mul
    case div
    case mod
    case pow
    case bitAnd
    case bitOr
    case bitXor
    case leftShift
    case rightShift
    case unsignedRightShift

    // MARK: - Comparison
    case equal
    case notEqual
    case strictEqual
    case strictNotEqual
    case lessThan
    case lessThanOrEqual
    case greaterThan
    case greaterThanOrEqual
    case sameValue
    case sameValueZero
    case instanceOf
    case inOperator

    // MARK: - Calls / construct
    case call
    case callDirect
    case callEval
    case callVarargs
    case tailCall
    case construct
    case constructVarargs
    case superConstruct
    case superConstructVarargs

    // MARK: - Control flow / branching
    case jump
    case jumpIfTrue
    case jumpIfFalse
    case jumpIfNull
    case jumpIfUndefined
    case jumpIfNullish
    case jumpIfNotNullish
    case jumpIfEmpty
    case switchInt
    case switchString
    case returnValue
    case returnUndefined

    // MARK: - Exceptions / handlers
    case throwValue
    case rethrow
    case enterCatch
    case enterFinally
    case getException
    case clearException

    // MARK: - Iteration
    case getIterator
    case iteratorNext
    case iteratorValue
    case iteratorDone
    case iteratorClose

    // MARK: - Modules
    case getModuleVariable
    case putModuleVariable
    case getImportMeta

    // MARK: - Class fields / methods
    case createMethod
    case defineClassMethod
    case defineInstanceField
    case defineStaticField

    // MARK: - Promises / microtasks
    case createPromise
    case fulfillPromise
    case rejectPromise
    case promiseResolve
    case promiseThen
    case enqueueMicrotask

    // MARK: - Async lowering
    case asyncEnter
    case awaitSuspend
    case asyncResumePoint

    // MARK: - Generators / resumable frames
    case createGeneratorObject
    case createAsyncGeneratorObject
    case generatorEnter
    case getResumeValue
    case getResumeKind
    case jumpIfResumeKind
    case generatorSuspend
    case asyncGeneratorSuspend
    case yieldStar
    case generatorReturn
    case generatorThrow
    case asyncGeneratorReturn
    case asyncGeneratorThrow
    case resumePoint

    // MARK: - Profiling / speculation hooks
    case profileValue
    case profileType
    case profileBranch
    case profileCall
    case checkStructure
    case checkCell
    case checkNumber
    case checkInt32
    case checkString
    case checkObject
    case checkArray
    case checkInt32Index

    // MARK: - Runtime bridge / rare helpers
    case checkStack
    case runtimeCall
    case intrinsicCall
}

extension Bytecode {
    var opcode: Opcode {
        switch self {
        // MARK: - Meta / tooling
        case .nop: return .nop
        case .coverageMark: return .coverageMark
        case .debugTrap: return .debugTrap
        case .debugLog: return .debugLog
        case .debugDumpScope: return .debugDumpScope
        case .debugDumpIC: return .debugDumpIC
        case .unreachable: return .unreachable
        case .halt: return .halt

        // MARK: - Start markers
        case .enterGlobal: return .enterGlobal
        case .enterFunction: return .enterFunction

        // MARK: - Register movement
        case .move: return .move
        case .clearReg: return .clearReg
        case .swap: return .swap

        // MARK: - VM implicit values
        case .loadThis: return .loadThis
        case .loadNewTarget: return .loadNewTarget
        case .loadSuperConstructor: return .loadSuperConstructor

        // MARK: - Constants / literals
        case .loadUndefined: return .loadUndefined
        case .loadNull: return .loadNull
        case .loadTrue: return .loadTrue
        case .loadFalse: return .loadFalse
        case .loadEmpty: return .loadEmpty
        case .loadInt32: return .loadInt32
        case .loadDouble: return .loadDouble
        case .loadString: return .loadString
        case .loadBigInt: return .loadBigInt
        case .loadSymbol: return .loadSymbol
        case .loadConst: return .loadConst

        // MARK: - Object / array / function literals
        case .newObject: return .newObject
        case .newObjectWithProto: return .newObjectWithProto
        case .newArray: return .newArray
        case .newArrayWithSize: return .newArrayWithSize
        case .newArrayWithSpread: return .newArrayWithSpread
        case .newObjectLiteral: return .newObjectLiteral
        case .newArrayLiteral: return .newArrayLiteral
        case .newRegExp: return .newRegExp
        case .createFunction: return .createFunction
        case .createClosure: return .createClosure
        case .createArrowClosure: return .createArrowClosure
        case .createGeneratorClosure: return .createGeneratorClosure
        case .createAsyncClosure: return .createAsyncClosure
        case .createClass: return .createClass
        case .setHomeObject: return .setHomeObject

        // MARK: - Arguments / locals
        case .getArgument: return .getArgument
        case .putArgument: return .putArgument
        case .getLocal: return .getLocal
        case .putLocal: return .putLocal
        case .initLocal: return .initLocal
        case .checkTDZLocal: return .checkTDZLocal

        // MARK: - Lexical environments / context chain
        case .createLexicalEnvironment: return .createLexicalEnvironment
        case .pushLexicalEnvironment: return .pushLexicalEnvironment
        case .popLexicalEnvironment: return .popLexicalEnvironment
        case .getContext: return .getContext
        case .putContext: return .putContext
        case .checkTDZContext: return .checkTDZContext
        case .materializeScope: return .materializeScope

        // MARK: - Global / name resolution
        case .resolveName: return .resolveName
        case .getGlobalLexical: return .getGlobalLexical
        case .putGlobalLexical: return .putGlobalLexical
        case .initGlobalLexical: return .initGlobalLexical
        case .getGlobalVar: return .getGlobalVar
        case .putGlobalVar: return .putGlobalVar
        case .initGlobalVar: return .initGlobalVar
        case .getGlobalProperty: return .getGlobalProperty
        case .putGlobalProperty: return .putGlobalProperty
        case .typeofGlobal: return .typeofGlobal
        case .deleteGlobal: return .deleteGlobal

        // MARK: - Property / method access
        case .getById: return .getById
        case .putById: return .putById
        case .getByVal: return .getByVal
        case .putByVal: return .putByVal
        case .getByIdWithThis: return .getByIdWithThis
        case .getByValWithThis: return .getByValWithThis
        case .getMethodById: return .getMethodById
        case .getMethodByVal: return .getMethodByVal
        case .defineOwnById: return .defineOwnById
        case .defineOwnByVal: return .defineOwnByVal
        case .deleteById: return .deleteById
        case .deleteByVal: return .deleteByVal
        case .hasProperty: return .hasProperty
        case .inById: return .inById
        case .inByVal: return .inByVal

        // MARK: - Private names
        case .getPrivateById: return .getPrivateById
        case .putPrivateById: return .putPrivateById
        case .definePrivateById: return .definePrivateById
        case .hasPrivateById: return .hasPrivateById

        // MARK: - Super property access
        case .getSuperById: return .getSuperById
        case .putSuperById: return .putSuperById
        case .getSuperByVal: return .getSuperByVal
        case .putSuperByVal: return .putSuperByVal

        // MARK: - Array / indexed fast paths
        case .getLength: return .getLength
        case .putLength: return .putLength
        case .getByIndex: return .getByIndex
        case .putByIndex: return .putByIndex
        case .arrayPush: return .arrayPush
        case .arrayPop: return .arrayPop

        // MARK: - Conversions / unary
        case .toNumber: return .toNumber
        case .toNumeric: return .toNumeric
        case .toString: return .toString
        case .toObject: return .toObject
        case .toBoolean: return .toBoolean
        case .toPropertyKey: return .toPropertyKey
        case .isCallable: return .isCallable
        case .isConstructor: return .isConstructor
        case .typeofValue: return .typeofValue
        case .voidOp: return .voidOp
        case .logicalNot: return .logicalNot
        case .bitNot: return .bitNot
        case .negate: return .negate
        case .increment: return .increment
        case .decrement: return .decrement

        // MARK: - Binary arithmetic / bitwise
        case .add: return .add
        case .sub: return .sub
        case .mul: return .mul
        case .div: return .div
        case .mod: return .mod
        case .pow: return .pow
        case .bitAnd: return .bitAnd
        case .bitOr: return .bitOr
        case .bitXor: return .bitXor
        case .leftShift: return .leftShift
        case .rightShift: return .rightShift
        case .unsignedRightShift: return .unsignedRightShift

        // MARK: - Comparison
        case .equal: return .equal
        case .notEqual: return .notEqual
        case .strictEqual: return .strictEqual
        case .strictNotEqual: return .strictNotEqual
        case .lessThan: return .lessThan
        case .lessThanOrEqual: return .lessThanOrEqual
        case .greaterThan: return .greaterThan
        case .greaterThanOrEqual: return .greaterThanOrEqual
        case .sameValue: return .sameValue
        case .sameValueZero: return .sameValueZero
        case .instanceOf: return .instanceOf
        case .inOperator: return .inOperator

        // MARK: - Calls / construct
        case .call: return .call
        case .callDirect: return .callDirect
        case .callEval: return .callEval
        case .callVarargs: return .callVarargs
        case .tailCall: return .tailCall
        case .construct: return .construct
        case .constructVarargs: return .constructVarargs
        case .superConstruct: return .superConstruct
        case .superConstructVarargs: return .superConstructVarargs

        // MARK: - Control flow / branching
        case .jump: return .jump
        case .jumpIfTrue: return .jumpIfTrue
        case .jumpIfFalse: return .jumpIfFalse
        case .jumpIfNull: return .jumpIfNull
        case .jumpIfUndefined: return .jumpIfUndefined
        case .jumpIfNullish: return .jumpIfNullish
        case .jumpIfNotNullish: return .jumpIfNotNullish
        case .jumpIfEmpty: return .jumpIfEmpty
        case .switchInt: return .switchInt
        case .switchString: return .switchString
        case .returnValue: return .returnValue
        case .returnUndefined: return .returnUndefined

        // MARK: - Exceptions / handlers
        case .throwValue: return .throwValue
        case .rethrow: return .rethrow
        case .enterCatch: return .enterCatch
        case .enterFinally: return .enterFinally
        case .getException: return .getException
        case .clearException: return .clearException

        // MARK: - Iteration
        case .getIterator: return .getIterator
        case .iteratorNext: return .iteratorNext
        case .iteratorValue: return .iteratorValue
        case .iteratorDone: return .iteratorDone
        case .iteratorClose: return .iteratorClose

        // MARK: - Modules
        case .getModuleVariable: return .getModuleVariable
        case .putModuleVariable: return .putModuleVariable
        case .getImportMeta: return .getImportMeta

        // MARK: - Class fields / methods
        case .createMethod: return .createMethod
        case .defineClassMethod: return .defineClassMethod
        case .defineInstanceField: return .defineInstanceField
        case .defineStaticField: return .defineStaticField

        // MARK: - Promises / microtasks
        case .createPromise: return .createPromise
        case .fulfillPromise: return .fulfillPromise
        case .rejectPromise: return .rejectPromise
        case .promiseResolve: return .promiseResolve
        case .promiseThen: return .promiseThen
        case .enqueueMicrotask: return .enqueueMicrotask

        // MARK: - Async lowering
        case .asyncEnter: return .asyncEnter
        case .awaitSuspend: return .awaitSuspend
        case .asyncResumePoint: return .asyncResumePoint

        // MARK: - Generators / resumable frames
        case .createGeneratorObject: return .createGeneratorObject
        case .createAsyncGeneratorObject: return .createAsyncGeneratorObject
        case .generatorEnter: return .generatorEnter
        case .getResumeValue: return .getResumeValue
        case .getResumeKind: return .getResumeKind
        case .jumpIfResumeKind: return .jumpIfResumeKind
        case .generatorSuspend: return .generatorSuspend
        case .asyncGeneratorSuspend: return .asyncGeneratorSuspend
        case .yieldStar: return .yieldStar
        case .generatorReturn: return .generatorReturn
        case .generatorThrow: return .generatorThrow
        case .asyncGeneratorReturn: return .asyncGeneratorReturn
        case .asyncGeneratorThrow: return .asyncGeneratorThrow
        case .resumePoint: return .resumePoint

        // MARK: - Profiling / speculation hooks
        case .profileValue: return .profileValue
        case .profileType: return .profileType
        case .profileBranch: return .profileBranch
        case .profileCall: return .profileCall
        case .checkStructure: return .checkStructure
        case .checkCell: return .checkCell
        case .checkNumber: return .checkNumber
        case .checkInt32: return .checkInt32
        case .checkString: return .checkString
        case .checkObject: return .checkObject
        case .checkArray: return .checkArray
        case .checkInt32Index: return .checkInt32Index

        // MARK: - Runtime bridge / rare helpers
        case .checkStack: return .checkStack
        case .runtimeCall: return .runtimeCall
        case .intrinsicCall: return .intrinsicCall
        }
    }
}

extension Serializer {
    func serializeSingleOpcode(_ bytecode: Bytecode) -> UInt8 {
        bytecode.opcode.rawValue
    }

    func appendSerialized(_ singleByte: UInt8) {
        SerializedBytecode.append(singleByte)
    }
}