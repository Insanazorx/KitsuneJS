// JSC-like pure register based bytecode set

public enum Bytecode: Equatable, Hashable {
    
    // MARK: - Operand wrappers

    public struct Reg: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct LocalSlot: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct ArgSlot: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct ContextSlot: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct GlobalSlot: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct ModuleSlot: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    /// Constant pool / identifier table index.
    /// String identifiers, numeric constants, object literal metadata,
    /// regexp metadata, switch tables etc. can all live behind this.
    public struct CPIndex: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }
    }

    public struct FunctionID: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }
    }

    public struct HandlerID: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    /// Generic value / type / arithmetic profile slot.
    public struct ProfileSlot: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    /// Property inline-cache slot.
    public struct ICSlot: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    /// Call inline-cache / call-profile slot.
    public struct CallSlot: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct JumpOffset: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }
    }

    public struct ArgCount: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct ContextDepth: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt8
        public init(rawValue: UInt8) { self.rawValue = rawValue }
    }

    public struct ScopeLayoutID: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct StructureSetID: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct RuntimeID: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct IntrinsicID: Equatable, Hashable, RawRepresentable, Sendable {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct PropertyFlags: OptionSet, Equatable, Hashable, Sendable {
        public let rawValue: UInt8
        public init(rawValue: UInt8) { self.rawValue = rawValue }

        public static let enumerable   = PropertyFlags(rawValue: 1 << 0)
        public static let configurable = PropertyFlags(rawValue: 1 << 1)
        public static let writable     = PropertyFlags(rawValue: 1 << 2)
        public static let accessor     = PropertyFlags(rawValue: 1 << 3)
        public static let isStatic     = PropertyFlags(rawValue: 1 << 4)
        public static let privateName  = PropertyFlags(rawValue: 1 << 5)
    }

    public enum IteratorKind: UInt8, Equatable, Hashable, Sendable {
        case sync = 0
        case async = 1
    }

    // MARK: - Meta / tooling

    case nop
    case coverageMark(UInt32)
    case debugTrap(UInt16)
    case debugLog(Reg)
    case debugDumpScope
    case debugDumpIC(ICSlot)
    case unreachable
    case halt

    // MARK: - Register movement

    case move(dst: Reg, src: Reg)
    case clearReg(Reg)
    case swap(lhs: Reg, rhs: Reg)

    // MARK: - VM implicit values

    case loadThis(dst: Reg)
    case loadNewTarget(dst: Reg)
    case loadSuperConstructor(dst: Reg)

    // MARK: - Constants / literals

    case loadUndefined(dst: Reg)
    case loadNull(dst: Reg)
    case loadTrue(dst: Reg)
    case loadFalse(dst: Reg)
    case loadEmpty(dst: Reg)                 // internal hole / empty value

    case loadInt32(dst: Reg, value: Int32)
    case loadDouble(dst: Reg, constant: CPIndex)
    case loadString(dst: Reg, name: CPIndex)
    case loadBigInt(dst: Reg, constant: CPIndex)
    case loadSymbol(dst: Reg, name: CPIndex)
    
    case loadConst(dst: Reg, constant: CPIndex) //general purpose constant load

    // MARK: - Object / array / function literals

    case newObject(dst: Reg)
    case newObjectWithProto(dst: Reg, proto: Reg)

    case newArray(dst: Reg, firstElement: Reg, count: UInt16)
    case newArrayWithSize(dst: Reg, minimumCapacity: UInt16)
    case newArrayWithSpread(dst: Reg, firstElement: Reg, count: UInt16)

    case newObjectLiteral(dst: Reg, metadata: CPIndex)
    case newArrayLiteral(dst: Reg, metadata: CPIndex)
    case newRegExp(dst: Reg, metadata: CPIndex)

    case createFunction(dst: Reg, function: FunctionID)
    case createClosure(dst: Reg, function: FunctionID, environment: Reg)
    case createArrowClosure(dst: Reg, function: FunctionID, environment: Reg)
    case createGeneratorClosure(dst: Reg, function: FunctionID, environment: Reg)
    case createAsyncClosure(dst: Reg, function: FunctionID, environment: Reg)

    case createClass(dst: Reg, constructor: FunctionID, protoParent: Reg?, metadata: CPIndex)
    case setHomeObject(function: Reg, homeObject: Reg)

    // MARK: - Arguments / locals

    /// Arguments and uncaptured locals can be lowered directly to registers.
    /// These are still useful while your frontend has explicit slot metadata.
    case getArgument(dst: Reg, slot: ArgSlot)
    case putArgument(slot: ArgSlot, src: Reg)

    case getLocal(dst: Reg, slot: LocalSlot)
    case putLocal(slot: LocalSlot, src: Reg)
    case initLocal(slot: LocalSlot, src: Reg)
    case checkTDZLocal(slot: LocalSlot)

    // MARK: - Lexical environments / context chain

    case createLexicalEnvironment(dst: Reg, layout: ScopeLayoutID)
    case pushLexicalEnvironment(environment: Reg)
    case popLexicalEnvironment

    case getContext(dst: Reg, depth: ContextDepth, slot: ContextSlot)
    case putContext(depth: ContextDepth, slot: ContextSlot, src: Reg)
    case checkTDZContext(depth: ContextDepth, slot: ContextSlot)
    
    //for eval and with
    case materializeScope(dst: Reg, depth: ContextDepth)

    //TODO: for low level access to context slots 
    //case getDirectContextSlot(dst: Reg, depth: ContextDepth, slot: ContextSlot) 
    //case putDirectContextSlot(depth: ContextDepth, slot: ContextSlot, src: Reg)

    // MARK: - Global / name resolution

    case resolveName(dst: Reg, name: CPIndex, profile: ProfileSlot?)

    case getGlobalLexical(dst: Reg, slot: GlobalSlot, profile: ProfileSlot?)
    case putGlobalLexical(slot: GlobalSlot, src: Reg, profile: ProfileSlot?)
    case initGlobalLexical(slot: GlobalSlot, src: Reg)

    case getGlobalVar(dst: Reg, slot: GlobalSlot, cache: ICSlot?)
    case putGlobalVar(slot: GlobalSlot, src: Reg, cache: ICSlot?)
    case initGlobalVar(slot: GlobalSlot, src: Reg)

    case getGlobalProperty(dst: Reg, name: CPIndex, cache: ICSlot?)
    case putGlobalProperty(name: CPIndex, src: Reg, cache: ICSlot?)

    case typeofGlobal(dst: Reg, slot: GlobalSlot, profile: ProfileSlot?)
    case deleteGlobal(dst: Reg, slot: GlobalSlot)

    // MARK: - Property / method access

    case getById(dst: Reg, base: Reg, name: CPIndex, cache: ICSlot?)
    case putById(base: Reg, name: CPIndex, value: Reg, cache: ICSlot?)

    case getByVal(dst: Reg, base: Reg, key: Reg, cache: ICSlot?)
    case putByVal(base: Reg, key: Reg, value: Reg, cache: ICSlot?)

    case getByIdWithThis(dst: Reg, base: Reg, thisValue: Reg, name: CPIndex, cache: ICSlot?)
    case getByValWithThis(dst: Reg, base: Reg, key: Reg, thisValue: Reg, cache: ICSlot?)

    /// Produces both callee and receiver for later callWithReceiver.
    case getMethodById(callee: Reg, thisValue: Reg, base: Reg, name: CPIndex, cache: ICSlot?)
    case getMethodByVal(callee: Reg, thisValue: Reg, base: Reg, key: Reg, cache: ICSlot?)

    case defineOwnById(base: Reg, name: CPIndex, value: Reg, flags: PropertyFlags)
    case defineOwnByVal(base: Reg, key: Reg, value: Reg, flags: PropertyFlags)

    case deleteById(dst: Reg, base: Reg, name: CPIndex, profile: ProfileSlot?)
    case deleteByVal(dst: Reg, base: Reg, key: Reg, profile: ProfileSlot?)

    case hasProperty(dst: Reg, base: Reg, key: Reg, profile: ProfileSlot?)
    case inById(dst: Reg, base: Reg, name: CPIndex, profile: ProfileSlot?)
    case inByVal(dst: Reg, base: Reg, key: Reg, profile: ProfileSlot?)

    // MARK: - Private names

    case getPrivateById(dst: Reg, base: Reg, name: CPIndex)
    case putPrivateById(base: Reg, name: CPIndex, value: Reg)
    case definePrivateById(base: Reg, name: CPIndex, value: Reg)
    case hasPrivateById(dst: Reg, base: Reg, name: CPIndex)

    // MARK: - Super property access

    case getSuperById(dst: Reg, thisValue: Reg, homeObject: Reg, name: CPIndex, cache: ICSlot?)
    case putSuperById(thisValue: Reg, homeObject: Reg, name: CPIndex, value: Reg, cache: ICSlot?)

    case getSuperByVal(dst: Reg, thisValue: Reg, homeObject: Reg, key: Reg, cache: ICSlot?)
    case putSuperByVal(thisValue: Reg, homeObject: Reg, key: Reg, value: Reg, cache: ICSlot?)

    // MARK: - Array / indexed fast paths

    case getLength(dst: Reg, base: Reg, cache: ICSlot?)
    case putLength(base: Reg, value: Reg, cache: ICSlot?)

    case getByIndex(dst: Reg, base: Reg, index: UInt32, cache: ICSlot?)
    case putByIndex(base: Reg, index: UInt32, value: Reg, cache: ICSlot?)

    case arrayPush(dst: Reg, array: Reg, value: Reg, profile: ProfileSlot?)
    case arrayPop(dst: Reg, array: Reg, profile: ProfileSlot?)

    // MARK: - Conversions / unary

    case toNumber(dst: Reg, src: Reg, profile: ProfileSlot?)
    case toNumeric(dst: Reg, src: Reg, profile: ProfileSlot?)
    case toString(dst: Reg, src: Reg, profile: ProfileSlot?)
    case toObject(dst: Reg, src: Reg, profile: ProfileSlot?)
    case toBoolean(dst: Reg, src: Reg, profile: ProfileSlot?)
    case toPropertyKey(dst: Reg, src: Reg, profile: ProfileSlot?)

    case isCallable(dst: Reg, src: Reg)
    case isConstructor(dst: Reg, src: Reg)

    case typeofValue(dst: Reg, src: Reg, profile: ProfileSlot?)
    case voidOp(dst: Reg, src: Reg)
    case logicalNot(dst: Reg, src: Reg)

    case bitNot(dst: Reg, src: Reg, profile: ProfileSlot?)
    case negate(dst: Reg, src: Reg, profile: ProfileSlot?)
    case increment(dst: Reg, src: Reg, profile: ProfileSlot?)
    case decrement(dst: Reg, src: Reg, profile: ProfileSlot?)

    // MARK: - Binary arithmetic / bitwise

    case add(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case sub(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case mul(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case div(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case mod(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case pow(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)

    case bitAnd(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case bitOr(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case bitXor(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case leftShift(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case rightShift(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case unsignedRightShift(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)

    // MARK: - Comparison

    case equal(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case notEqual(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case strictEqual(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case strictNotEqual(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)

    case lessThan(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case lessThanOrEqual(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case greaterThan(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case greaterThanOrEqual(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)

    case sameValue(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)
    case sameValueZero(dst: Reg, lhs: Reg, rhs: Reg, profile: ProfileSlot?)

    case instanceOf(dst: Reg, value: Reg, constructor: Reg, profile: ProfileSlot?)
    case inOperator(dst: Reg, key: Reg, base: Reg, profile: ProfileSlot?)

    // MARK: - Calls / construct

    /// argsBase points to the first argument register.
    /// Arguments must be laid out contiguously:
    /// argsBase, argsBase + 1, argsBase + 2, ...
    case call(
        dst: Reg,
        callee: Reg,
        thisValue: Reg,
        argsBase: Reg,
        argc: ArgCount,
        call: CallSlot?
    )

    case callDirect(
        dst: Reg,
        function: FunctionID,
        thisValue: Reg,
        argsBase: Reg,
        argc: ArgCount,
        call: CallSlot?
    )

    case callEval(
        dst: Reg,
        callee: Reg,
        thisValue: Reg,
        argsBase: Reg,
        argc: ArgCount,
        call: CallSlot?
    )

    case callVarargs(
        dst: Reg,
        callee: Reg,
        thisValue: Reg,
        argsArray: Reg,
        call: CallSlot?
    )

    case tailCall(
        callee: Reg,
        thisValue: Reg,
        argsBase: Reg,
        argc: ArgCount,
        call: CallSlot?
    )

    case construct(
        dst: Reg,
        callee: Reg,
        argsBase: Reg,
        argc: ArgCount,
        call: CallSlot?
    )

    case constructVarargs(
        dst: Reg,
        callee: Reg,
        argsArray: Reg,
        call: CallSlot?
    )

    case superConstruct(
        dst: Reg,
        callee: Reg,
        argsBase: Reg,
        argc: ArgCount,
        call: CallSlot?
    )

    case superConstructVarargs(
        dst: Reg,
        callee: Reg,
        argsArray: Reg,
        call: CallSlot?
    )

    // MARK: - Control flow / branching

    case jump(JumpOffset)

    case jumpIfTrue(condition: Reg, offset: JumpOffset)
    case jumpIfFalse(condition: Reg, offset: JumpOffset)

    case jumpIfNull(value: Reg, offset: JumpOffset)
    case jumpIfUndefined(value: Reg, offset: JumpOffset)
    case jumpIfNullish(value: Reg, offset: JumpOffset)
    case jumpIfNotNullish(value: Reg, offset: JumpOffset)
    case jumpIfEmpty(value: Reg, offset: JumpOffset)

    case switchInt(value: Reg, table: CPIndex)
    case switchString(value: Reg, table: CPIndex)

    case returnValue(Reg)
    case returnUndefined

    // MARK: - Exceptions / handlers

    case throwValue(Reg)
    case rethrow

    /// Markers for debug/metadata clarity.
    /// Actual unwinding should preferably use CodeBlock exception tables.
    case enterCatch(HandlerID)
    case enterFinally(HandlerID)

    case getException(dst: Reg)
    case clearException

    // MARK: - Iteration

    case getIterator(dst: Reg, value: Reg, kind: IteratorKind, profile: ProfileSlot?)
    case iteratorNext(dst: Reg, iterator: Reg, profile: ProfileSlot?)
    case iteratorValue(dst: Reg, iteratorResult: Reg, profile: ProfileSlot?)
    case iteratorDone(dst: Reg, iteratorResult: Reg, profile: ProfileSlot?)
    case iteratorClose(iterator: Reg, profile: ProfileSlot?)

    // MARK: - Modules

    case getModuleVariable(dst: Reg, slot: ModuleSlot)
    case putModuleVariable(slot: ModuleSlot, src: Reg)
    case getImportMeta(dst: Reg)

    // MARK: - Class fields / methods

    case createMethod(dst: Reg, function: FunctionID, homeObject: Reg)

    case defineClassMethod(
        classObject: Reg,
        name: CPIndex,
        function: Reg,
        flags: PropertyFlags
    )

    case defineInstanceField(
        thisValue: Reg,
        name: CPIndex,
        value: Reg,
        flags: PropertyFlags
    )

    case defineStaticField(
        classObject: Reg,
        name: CPIndex,
        value: Reg,
        flags: PropertyFlags
    )

    // MARK: - Async / await

    case asyncEnter
    case await(dst: Reg, value: Reg, resumePoint: UInt16)
    case asyncReturn(value: Reg)
    case asyncThrow(value: Reg)

    // MARK: - Generators

    case generatorEnter
    case yield(dst: Reg, value: Reg, resumePoint: UInt16)
    case yieldStar(dst: Reg, iterator: Reg, resumePoint: UInt16)
    case generatorReturn(value: Reg)
    case generatorThrow(value: Reg)
    case resumePoint(UInt16)

    // MARK: - Profiling / speculation hooks

    case profileValue(Reg, ProfileSlot)
    case profileType(Reg, ProfileSlot)
    case profileBranch(condition: Reg, profile: ProfileSlot)
    case profileCall(callee: Reg, call: CallSlot)

    case checkStructure(reg: Reg, structures: StructureSetID, fail: JumpOffset)
    case checkCell(reg: Reg, fail: JumpOffset)
    case checkNumber(reg: Reg, fail: JumpOffset)
    case checkInt32(reg: Reg, fail: JumpOffset)
    case checkString(reg: Reg, fail: JumpOffset)
    case checkObject(reg: Reg, fail: JumpOffset)
    case checkArray(reg: Reg, fail: JumpOffset)
    case checkInt32Index(reg: Reg, fail: JumpOffset)

    // MARK: - Runtime bridge / rare helpers

    case checkStack

    case runtimeCall(
        dst: Reg,
        id: RuntimeID,
        argsBase: Reg,
        argc: ArgCount
    )

    case intrinsicCall(
        dst: Reg,
        id: IntrinsicID,
        argsBase: Reg,
        argc: ArgCount
    )
}





extension Bytecode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .nop:
            return "nop"
        case .coverageMark(let id):
            return "coverageMark \(id)"
        case .debugTrap(let id):
            return "debugTrap \(id)"
        case .debugLog(let reg):
            return "debugLog r\(reg.rawValue)"
        case .debugDumpScope:
            return "debugDumpScope"
        case .debugDumpIC(let slot):
            return "debugDumpIC ic\(slot.rawValue)"
        case .unreachable:
            return "unreachable"
        case .halt:
            return "halt"
        case .move(let dst, let src):
            return "move r\(dst.rawValue), r\(src.rawValue)"
        case .clearReg(let reg):
            return "clearReg r\(reg.rawValue)"
        case .swap(let lhs, let rhs):
            return "swap r\(lhs.rawValue), r\(rhs.rawValue)"
        case .loadThis(let dst):
            return "loadThis r\(dst.rawValue)"
        case .loadNewTarget(let dst):
            return "loadNewTarget r\(dst.rawValue)"
        case .loadSuperConstructor(let dst):
            return "loadSuperConstructor r\(dst.rawValue)"
        case .loadUndefined(let dst):
            return "loadUndefined r\(dst.rawValue)"
        case .loadNull(let dst):
            return "loadNull r\(dst.rawValue)"
        case .loadTrue(let dst):
            return "loadTrue r\(dst.rawValue)"
        case .loadFalse(let dst):
            return "loadFalse r\(dst.rawValue)"
        case .loadEmpty(let dst):
            return "loadEmpty r\(dst.rawValue)"
        case .loadInt32(let dst, let value):
            return "loadInt32 r\(dst.rawValue), \(value)"
        case .loadDouble(let dst, let constant):
            return "loadDouble r\(dst.rawValue), cp[\(constant.rawValue)]"
        case .loadString(let dst, let name):
            return "loadString r\(dst.rawValue), cp[\(name.rawValue)]"
        case .loadConst(let dst, let constant):
            return "loadConst r\(dst.rawValue), cp[\(constant.rawValue)]"
        case .loadBigInt(let dst, let constant):
            return "loadBigInt r\(dst.rawValue), cp[\(constant.rawValue)]"
        case .loadSymbol(let dst, let name):
            return "loadSymbol r\(dst.rawValue), cp[\(name.rawValue)]"
        case .newObject(let dst):
            return "newObject r\(dst.rawValue)"
        case .newObjectWithProto(let dst, let proto):
            return "newObjectWithProto r\(dst.rawValue), r\(proto.rawValue)"
        case .newArray(let dst, let firstElement, let count):
            return "newArray r\(dst.rawValue), r\(firstElement.rawValue), \(count)"
        case .newArrayWithSize(let dst, let minimumCapacity):
            return "newArrayWithSize r\(dst.rawValue), \(minimumCapacity)"
        case .newArrayWithSpread(let dst, let firstElement, let count):
            return "newArrayWithSpread r\(dst.rawValue), r\(firstElement.rawValue), \(count)"
        case .newObjectLiteral(let dst, let metadata):
            return "newObjectLiteral r\(dst.rawValue), cp[\(metadata.rawValue)]"
        case .newArrayLiteral(let dst, let metadata):
            return "newArrayLiteral r\(dst.rawValue), cp[\(metadata.rawValue)]"
        case .newRegExp(let dst, let metadata):
            return "newRegExp r\(dst.rawValue), cp[\(metadata.rawValue)]"
        case .createFunction(let dst, let function):
            return "createFunction r\(dst.rawValue), f[\(function.rawValue)]"
        case .createClosure(let dst, let function, let environment):
            return "createClosure r\(dst.rawValue), f[\(function.rawValue)], r\(environment.rawValue)"
        case .createArrowClosure(let dst, let function, let environment):
            return "createArrowClosure r\(dst.rawValue), f[\(function.rawValue)], r\(environment.rawValue)"
        case .createGeneratorClosure(let dst, let function, let environment):
            return "createGeneratorClosure r\(dst.rawValue), f[\(function.rawValue)], r\(environment.rawValue)"
        case .createAsyncClosure(let dst, let function, let environment):
            return "createAsyncClosure r\(dst.rawValue), f[\(function.rawValue)], r\(environment.rawValue)"
        case .createClass(let dst, let constructor, let protoParent, let metadata):
            if let protoParent = protoParent {
                return "createClass r\(dst.rawValue), f[\(constructor.rawValue)], r\(protoParent.rawValue), cp[\(metadata.rawValue)]"
            } else {
                return "createClass r\(dst.rawValue), f[\(constructor.rawValue)], null, cp[\(metadata.rawValue)]"
            }
        case .setHomeObject(let function, let homeObject):
            return "setHomeObject r\(function.rawValue), r\(homeObject.rawValue)"
        case .getArgument(let dst, let slot):
            return "getArgument r\(dst.rawValue), arg\(slot.rawValue)"
        case .putArgument(let slot, let src):
            return "putArgument arg\(slot.rawValue), r\(src.rawValue)"
        case .getLocal(let dst, let slot):
            return "getLocal r\(dst.rawValue), local\(slot.rawValue)"
        case .putLocal(let slot, let src):
            return "putLocal local\(slot.rawValue), r\(src.rawValue)"
        case .initLocal(let slot, let src):
            return "initLocal local\(slot.rawValue), r\(src.rawValue)"
        case .checkTDZLocal(let slot):
            return "checkTDZLocal local\(slot.rawValue)"
        case .createLexicalEnvironment(let dst, let layout):
            return "createLexicalEnvironment r\(dst.rawValue), layout\(layout.rawValue)"
        case .pushLexicalEnvironment(let environment):
            return "pushLexicalEnvironment r\(environment.rawValue)"
        case .popLexicalEnvironment:
            return "popLexicalEnvironment"
        case .getContext(let dst, let depth, let slot):
            return "getContext r\(dst.rawValue), depth \(depth.rawValue), slot\(slot.rawValue)"
        case .putContext(let depth, let slot, let src):
            return "putContext depth \(depth.rawValue), slot\(slot.rawValue), r\(src.rawValue)"
        case .checkTDZContext(let depth, let slot):
            return "checkTDZContext depth \(depth.rawValue), slot\(slot.rawValue)"
        case .materializeScope(let dst, let depth):
            return "materializeScope r\(dst.rawValue), depth \(depth.rawValue)"
        case .resolveName(let dst, let name, let profile):
            if let profile = profile {
                return "resolveName r\(dst.rawValue), cp[\(name.rawValue)], profile\(profile.rawValue)"
            } else {
                return "resolveName r\(dst.rawValue), cp[\(name.rawValue)]"
            }
        case .getGlobalLexical(let dst, let slot, let profile):
            if let profile = profile {
                return "getGlobalLexical r\(dst.rawValue), global\(slot.rawValue), profile\(profile.rawValue)"
            } else {
                return "getGlobalLexical r\(dst.rawValue), global\(slot.rawValue)"
            }
        case .putGlobalLexical(let slot, let src, let profile):
            if let profile = profile {
                return "putGlobalLexical global\(slot.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "putGlobalLexical global\(slot.rawValue), r\(src.rawValue)"
            }
        case .initGlobalLexical(let slot, let src):
            return "initGlobalLexical global\(slot.rawValue), r\(src.rawValue)"
        case .getGlobalVar(let dst, let slot, let cache):
            if let cache = cache {
                return "getGlobalVar r\(dst.rawValue), global\(slot.rawValue), ic\(cache.rawValue)"
            } else {
                return "getGlobalVar r\(dst.rawValue), global\(slot.rawValue)"
            }
        case .putGlobalVar(let slot, let src, let cache):
            if let cache = cache {
                return "putGlobalVar global\(slot.rawValue), r\(src.rawValue), ic\(cache.rawValue)"
            } else {
                return "putGlobalVar global\(slot.rawValue), r\(src.rawValue)"
            }
        case .initGlobalVar(let slot, let src):
            return "initGlobalVar global\(slot.rawValue), r\(src.rawValue)"
        case .getGlobalProperty(let dst, let name, let cache):
            if let cache = cache {
                return "getGlobalProperty r\(dst.rawValue), cp[\(name.rawValue)], ic\(cache.rawValue)"
            } else {
                return "getGlobalProperty r\(dst.rawValue), cp[\(name.rawValue)]"
            }
        case .putGlobalProperty(let name, let src, let cache):
            if let cache = cache {
                return "putGlobalProperty cp[\(name.rawValue)], r\(src.rawValue), ic\(cache.rawValue)"
            } else {
                return "putGlobalProperty cp[\(name.rawValue)], r\(src.rawValue)"
            } 
        case .typeofGlobal(let dst, let slot, let profile):
            if let profile = profile {
                return "typeofGlobal r\(dst.rawValue), global\(slot.rawValue), profile\(profile.rawValue)"
            } else {
                return "typeofGlobal r\(dst.rawValue), global\(slot.rawValue)"
            }
        case .deleteGlobal(let dst, let slot):
            return "deleteGlobal r\(dst.rawValue), global\(slot.rawValue)"
        case .getById(let dst, let base, let name, let cache):
            if let cache = cache {
                return "getById r\(dst.rawValue), r\(base.rawValue), cp[\(name.rawValue)], ic\(cache.rawValue)"
            } else {
                return "getById r\(dst.rawValue), r\(base.rawValue), cp[\(name.rawValue)]"
            }
        case .putById(let base, let name, let value, let cache):
            if let cache = cache {
                return "putById r\(base.rawValue), cp[\(name.rawValue)], r\(value.rawValue), ic\(cache.rawValue)"
            } else {
                return "putById r\(base.rawValue), cp[\(name.rawValue)], r\(value.rawValue)"
            }
        case .getByVal(let dst, let base, let key, let cache):
            if let cache = cache {
                return "getByVal r\(dst.rawValue), r\(base.rawValue), r\(key.rawValue), ic\(cache.rawValue)"
            } else {
                return "getByVal r\(dst.rawValue), r\(base.rawValue), r\(key.rawValue)"
            }
        case .putByVal(let base, let key, let value, let cache):
            if let cache = cache {
                return "putByVal r\(base.rawValue), r\(key.rawValue), r\(value.rawValue), ic\(cache.rawValue)"
            } else {
                return "putByVal r\(base.rawValue), r\(key.rawValue), r\(value.rawValue)"
            }
        case .getByIdWithThis(let dst, let base, let thisValue, let name, let cache):
            if let cache = cache {
                return "getByIdWithThis r\(dst.rawValue), r\(base.rawValue), r\(thisValue.rawValue), cp[\(name.rawValue)], ic\(cache.rawValue)"
            } else {
                return "getByIdWithThis r\(dst.rawValue), r\(base.rawValue), r\(thisValue.rawValue), cp[\(name.rawValue)]"
            }
        case .getByValWithThis(let dst, let base, let key, let thisValue, let cache):
            if let cache = cache {
                return "getByValWithThis r\(dst.rawValue), r\(base.rawValue), r\(thisValue.rawValue), r\(key.rawValue), ic\(cache.rawValue)"
            } else {
                return "getByValWithThis r\(dst.rawValue), r\(base.rawValue), r\(thisValue.rawValue), r\(key.rawValue)"
            }
        case .getMethodById(let callee, let thisValue, let base, let name, let cache):
            if let cache = cache {
                return "getMethodById r\(callee.rawValue), r\(thisValue.rawValue), r\(base.rawValue), cp[\(name.rawValue)], ic\(cache.rawValue)"
            } else {
                return "getMethodById r\(callee.rawValue), r\(thisValue.rawValue), r\(base.rawValue), cp[\(name.rawValue)]"
            }
        case .getMethodByVal(let callee, let thisValue, let base, let key, let cache):
            if let cache = cache {
                return "getMethodByVal r\(callee.rawValue), r\(thisValue.rawValue), r\(base.rawValue), r\(key.rawValue), ic\(cache.rawValue)"
            } else {
                return "getMethodByVal r\(callee.rawValue), r\(thisValue.rawValue), r\(base.rawValue), r\(key.rawValue)"
            }
        case .defineOwnById(let base, let name, let value, let flags):
            return "defineOwnById r\(base.rawValue), cp[\(name.rawValue)], r\(value.rawValue), flags \(flags)"
        case .defineOwnByVal(let base, let key, let value, let flags):
            return "defineOwnByVal r\(base.rawValue), r\(key.rawValue), r\(value.rawValue), flags \(flags)"
        case .deleteById(let dst, let base, let name, let profile):
            if let profile = profile {
                return "deleteById r\(dst.rawValue), r\(base.rawValue), cp[\(name.rawValue)], profile\(profile.rawValue)"
            } else {
                return "deleteById r\(dst.rawValue), r\(base.rawValue), cp[\(name.rawValue)]"
            }
        case .deleteByVal(let dst, let base, let key, let profile):
            if let profile = profile {
                return "deleteByVal r\(dst.rawValue), r\(base.rawValue), r\(key.rawValue), profile\(profile.rawValue)"
            } else {
                return "deleteByVal r\(dst.rawValue), r\(base.rawValue), r\(key.rawValue)"
            }
        case .hasProperty(let dst, let base, let key, let profile):
            if let profile = profile {
                return "hasProperty r\(dst.rawValue), r\(base.rawValue), r\(key.rawValue), profile\(profile.rawValue)"
            } else {    
                return "hasProperty r\(dst.rawValue), r\(base.rawValue), r\(key.rawValue)"
            }
        case .inById(let dst, let base, let name, let profile):
            if let profile = profile {
                return "inById r\(dst.rawValue), r\(base.rawValue), cp[\(name.rawValue)], profile\(profile.rawValue)"
            } else {
                return "inById r\(dst.rawValue), r\(base.rawValue), cp[\(name.rawValue)]"
            }
        case .inByVal(let dst, let base, let key, let profile):
            if let profile = profile {
                return "inByVal r\(dst.rawValue), r\(base.rawValue), r\(key.rawValue), profile\(profile.rawValue)"
            } else {
                return "inByVal r\(dst.rawValue), r\(base.rawValue), r\(key.rawValue)"
            }
        case .getPrivateById(let dst, let base, let name):
            return "getPrivateById r\(dst.rawValue), r\(base.rawValue), cp[\(name.rawValue)]"
        case .putPrivateById(let base, let name, let value):
            return "putPrivateById r\(base.rawValue), cp[\(name.rawValue)], r\(value.rawValue)"
        case .definePrivateById(let base, let name, let value):
            return "definePrivateById r\(base.rawValue), cp[\(name.rawValue)], r\(value.rawValue)"
        case .hasPrivateById(let dst, let base, let name):
            return "hasPrivateById r\(dst.rawValue), r\(base.rawValue), cp[\(name.rawValue)]"
        case .getSuperById(let dst, let thisValue, let homeObject, let name, let cache):
            if let cache = cache {
                return "getSuperById r\(dst.rawValue), r\(thisValue.rawValue), r\(homeObject.rawValue), cp[\(name.rawValue)], ic\(cache.rawValue)"
            } else {
                return "getSuperById r\(dst.rawValue), r\(thisValue.rawValue), r\(homeObject.rawValue), cp[\(name.rawValue)]"
            }
        case .putSuperById(let thisValue, let homeObject, let name, let value, let cache):
            if let cache = cache {
                return "putSuperById r\(thisValue.rawValue), r\(homeObject.rawValue), cp[\(name.rawValue)], r\(value.rawValue), ic\(cache.rawValue)"
            } else {
                return "putSuperById r\(thisValue.rawValue), r\(homeObject.rawValue), cp[\(name.rawValue)], r\(value.rawValue)" 
            }
        case .getSuperByVal(let dst, let thisValue, let homeObject, let key, let cache):    
            if let cache = cache {
                return "getSuperByVal r\(dst.rawValue), r\(thisValue.rawValue), r\(homeObject.rawValue), r\(key.rawValue), ic\(cache.rawValue)"
            } else {
                return "getSuperByVal r\(dst.rawValue), r\(thisValue.rawValue), r\(homeObject.rawValue), r\(key.rawValue)"
            }
        case .putSuperByVal(let thisValue, let homeObject, let key, let value, let cache):
            if let cache = cache {
                return "putSuperByVal r\(thisValue.rawValue), r\(homeObject.rawValue), r\(key.rawValue), r\(value.rawValue), ic\(cache.rawValue)"  
            } else {
                return "putSuperByVal r\(thisValue.rawValue), r\(homeObject.rawValue), r\(key.rawValue), r\(value.rawValue)"
            }
        case .getLength(let dst, let base, let cache):
            if let cache = cache {
                return "getLength r\(dst.rawValue), r\(base.rawValue), ic\(cache.rawValue)"
            } else {
                return "getLength r\(dst.rawValue), r\(base.rawValue)"
            }
        case .putLength(let base, let value, let cache):
            if let cache = cache {
                return "putLength r\(base.rawValue), r\(value.rawValue), ic\(cache.rawValue)"
            } else {
                return "putLength r\(base.rawValue), r\(value.rawValue)"
            }
        case .getByIndex(let dst, let base, let index, let cache):
            if let cache = cache {
                return "getByIndex r\(dst.rawValue), r\(base.rawValue), \(index), ic\(cache.rawValue)"
            } else {
                return "getByIndex r\(dst.rawValue), r\(base.rawValue), \(index)"
            }
        case .putByIndex(let base, let index, let value, let cache):
            if let cache = cache {
                return "putByIndex r\(base.rawValue), \(index), r\(value.rawValue), ic\(cache.rawValue)"
            } else {
                return "putByIndex r\(base.rawValue), \(index), r\(value.rawValue)"
            }
        case .arrayPush(let dst, let array, let value, let profile):
            if let profile = profile {
                return "arrayPush r\(dst.rawValue), r\(array.rawValue), r\(value.rawValue), profile\(profile.rawValue)"
            } else {
                return "arrayPush r\(dst.rawValue), r\(array.rawValue), r\(value.rawValue)"
            }
        case .arrayPop(let dst, let array, let profile):
            if let profile = profile {
                return "arrayPop r\(dst.rawValue), r\(array.rawValue), profile\(profile.rawValue)"
            } else {
                return "arrayPop r\(dst.rawValue), r\(array.rawValue)"
            }
        case .toNumber(let dst, let src, let profile):
            if let profile = profile {
                return "toNumber r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "toNumber r\(dst.rawValue), r\(src.rawValue)"
            }
        case .toNumeric(let dst, let src, let profile):
            if let profile = profile {
                return "toNumeric r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "toNumeric r\(dst.rawValue), r\(src.rawValue)"
            }
        case .toString(let dst, let src, let profile):
            if let profile = profile {
                return "toString r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "toString r\(dst.rawValue), r\(src.rawValue)"
            }
        case .toObject(let dst, let src, let profile):
            if let profile = profile {
                return "toObject r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "toObject r\(dst.rawValue), r\(src.rawValue)"
            }
        case .toBoolean(let dst, let src, let profile):
            if let profile = profile {
                return "toBoolean r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "toBoolean r\(dst.rawValue), r\(src.rawValue)"
            }
        case .toPropertyKey(let dst, let src, let profile):
            if let profile = profile {
                return "toPropertyKey r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "toPropertyKey r\(dst.rawValue), r\(src.rawValue)"
            }
        case .isCallable(let dst, let src):
            return "isCallable r\(dst.rawValue), r\(src.rawValue)"
        case .isConstructor(let dst, let src):
            return "isConstructor r\(dst.rawValue), r\(src.rawValue)"
        case .typeofValue(let dst, let src, let profile):
            if let profile = profile {
                return "typeofValue r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "typeofValue r\(dst.rawValue), r\(src.rawValue)"
            }
        case .voidOp(let dst, let src):
            return "voidOp r\(dst.rawValue), r\(src.rawValue)"
        case .logicalNot(let dst, let src):
            return "logicalNot r\(dst.rawValue), r\(src.rawValue)"
        case .bitNot(let dst, let src, let profile):
            if let profile = profile {
                return "bitNot r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "bitNot r\(dst.rawValue), r\(src.rawValue)"
            }
        case .negate(let dst, let src, let profile):
            if let profile = profile {
                return "negate r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "negate r\(dst.rawValue), r\(src.rawValue)"
            }
        case .increment(let dst, let src, let profile):
            if let profile = profile {
                return "increment r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "increment r\(dst.rawValue), r\(src.rawValue)"
            }
        case .decrement(let dst, let src, let profile):
            if let profile = profile {
                return "decrement r\(dst.rawValue), r\(src.rawValue), profile\(profile.rawValue)"
            } else {
                return "decrement r\(dst.rawValue), r\(src.rawValue)"
            }
        case .add(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "add r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "add r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .sub(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "sub r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "sub r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .mul(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "mul r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "mul r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .div(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "div r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "div r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .mod(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "mod r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "mod r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .pow(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "pow r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "pow r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .bitAnd(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "bitAnd r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "bitAnd r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .bitOr(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "bitOr r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "bitOr r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .bitXor(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "bitXor r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "bitXor r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .leftShift(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "leftShift r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "leftShift r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .rightShift(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "rightShift r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "rightShift r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .unsignedRightShift(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "unsignedRightShift r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "unsignedRightShift r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .equal(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "equal r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "equal r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .notEqual(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "notEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "notEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .strictEqual(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "strictEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "strictEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .strictNotEqual(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "strictNotEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "strictNotEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .lessThan(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "lessThan r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "lessThan r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .lessThanOrEqual(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "lessThanOrEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "lessThanOrEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .greaterThan(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "greaterThan r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "greaterThan r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .greaterThanOrEqual(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "greaterThanOrEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "greaterThanOrEqual r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .sameValue(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "sameValue r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "sameValue r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .sameValueZero(let dst, let lhs, let rhs, let profile):
            if let profile = profile {
                return "sameValueZero r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue), profile\(profile.rawValue)"
            } else {
                return "sameValueZero r\(dst.rawValue), r\(lhs.rawValue), r\(rhs.rawValue)"
            }
        case .instanceOf(let dst, let value, let constructor, let profile):
            if let profile = profile {
                return "instanceOf r\(dst.rawValue), r\(value.rawValue), r\(constructor.rawValue), profile\(profile.rawValue)"
            } else {
                return "instanceOf r\(dst.rawValue), r\(value.rawValue), r\(constructor.rawValue)"
            }
        case .inOperator(let dst, let key, let base, let profile):
            if let profile = profile {
                return "inOperator r\(dst.rawValue), r\(key.rawValue), r\(base.rawValue), profile\(profile.rawValue)"
            } else {
                return "inOperator r\(dst.rawValue), r\(key.rawValue), r\(base.rawValue)"
            }
        case .call(let dst, let callee, let thisValue, let argsBase, let argc, let call):
            if let call = call {
                return "call r\(dst.rawValue), r\(callee.rawValue), this r\(thisValue.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue), call\(call.rawValue)"
            } else {
                return "call r\(dst.rawValue), r\(callee.rawValue), this r\(thisValue.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue)"
            }
        case .callDirect(let dst, let function, let thisValue, let argsBase, let argc, let call):
            if let call = call {
                return "callDirect r\(dst.rawValue), f[\(function.rawValue)], this r\(thisValue.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue), call\(call.rawValue)"
            } else {
                return "callDirect r\(dst.rawValue), f[\(function.rawValue)], this r\(thisValue.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue)"
            }
        case .callEval(let dst, let callee, let thisValue, let argsBase, let argc, let call):
            if let call = call {
                return "callEval r\(dst.rawValue), r\(callee.rawValue), this r\(thisValue.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue), call\(call.rawValue)"
            } else {
                return "callEval r\(dst.rawValue), r\(callee.rawValue), this r\(thisValue.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue)"
            }
        case .callVarargs(let dst, let callee, let thisValue, let argsArray, let call):
            if let call = call {
                return "callVarargs r\(dst.rawValue), r\(callee.rawValue), this r\(thisValue.rawValue), argsArray r\(argsArray.rawValue), call\(call.rawValue)"
            } else {
                return "callVarargs r\(dst.rawValue), r\(callee.rawValue), this r\(thisValue.rawValue), argsArray r\(argsArray.rawValue)"
            }
        case .tailCall(let callee, let thisValue, let argsBase, let argc, let call):
            if let call = call {
                return "tailCall r\(callee.rawValue), this r\(thisValue.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue), call\(call.rawValue)"
            } else {
                return "tailCall r\(callee.rawValue), this r\(thisValue.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue)"
            }
        case .construct(let dst, let callee, let argsBase, let argc, let call):
            if let call = call {
                return "construct r\(dst.rawValue), r\(callee.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue), call\(call.rawValue)"
            } else {
                return "construct r\(dst.rawValue), r\(callee.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue)"
            }
        case .constructVarargs(let dst, let callee, let argsArray, let call):
            if let call = call {
                return "constructVarargs r\(dst.rawValue), r\(callee.rawValue), argsArray r\(argsArray.rawValue), call\(call.rawValue)"
            } else {
                return "constructVarargs r\(dst.rawValue), r\(callee.rawValue), argsArray r\(argsArray.rawValue)"
            }
        case .superConstruct(let dst, let callee, let argsBase, let argc, let call):
            if let call = call {
                return "superConstruct r\(dst.rawValue), r\(callee.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue), call\(call.rawValue)"
            } else {
                return "superConstruct r\(dst.rawValue), r\(callee.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue)"
            }
        case .superConstructVarargs(let dst, let callee, let argsArray, let call):
            if let call = call {
                return "superConstructVarargs r\(dst.rawValue), r\(callee.rawValue), argsArray r\(argsArray.rawValue), call\(call.rawValue)"
            } else {
                return "superConstructVarargs r\(dst.rawValue), r\(callee.rawValue), argsArray r\(argsArray.rawValue)"
            }
        case .jump(let offset):
            return "jump \(offset.rawValue)"
        case .jumpIfTrue(let condition, let offset):
            return "jumpIfTrue r\(condition.rawValue), \(offset.rawValue)"
        case .jumpIfFalse(let condition, let offset):
            return "jumpIfFalse r\(condition.rawValue), \(offset.rawValue)"
        case .jumpIfNull(let value, let offset):
            return "jumpIfNull r\(value.rawValue), \(offset.rawValue)"
        case .jumpIfUndefined(let value, let offset):
            return "jumpIfUndefined r\(value.rawValue), \(offset.rawValue)"
        case .jumpIfNullish(let value, let offset):
            return "jumpIfNullish r\(value.rawValue), \(offset.rawValue)"
        case .jumpIfNotNullish(let value, let offset):
            return "jumpIfNotNullish r\(value.rawValue), \(offset.rawValue)"
        case .jumpIfEmpty(let value, let offset):
            return "jumpIfEmpty r\(value.rawValue), \(offset.rawValue)"
        case .switchInt(let value, let table):
            return "switchInt r\(value.rawValue), cp[\(table.rawValue)]"
        case .switchString(let value, let table):
            return "switchString r\(value.rawValue), cp[\(table.rawValue)]"
        case .returnValue(let reg):
            return "returnValue r\(reg.rawValue)"
        case .returnUndefined:
            return "returnUndefined"
        case .throwValue(let reg):
            return "throwValue r\(reg.rawValue)"
        case .rethrow:
            return "rethrow"
        case .enterCatch(let handler):
            return "enterCatch handler\(handler.rawValue)"
        case .enterFinally(let handler):
            return "enterFinally handler\(handler.rawValue)"
        case .getException(let dst):
            return "getException r\(dst.rawValue)"
        case .clearException:
            return "clearException"
        case .getIterator(let dst, let value, let kind, let profile):
            if let profile = profile {
                return "getIterator r\(dst.rawValue), r\(value.rawValue), \(kind), profile\(profile.rawValue)"
            } else {
                return "getIterator r\(dst.rawValue), r\(value.rawValue), \(kind)"
            }
        case .iteratorNext(let dst, let iterator, let profile):
            if let profile = profile {
                return "iteratorNext r\(dst.rawValue), r\(iterator.rawValue), profile\(profile.rawValue)"
            } else {
                return "iteratorNext r\(dst.rawValue), r\(iterator.rawValue)"
            }
        case .iteratorValue(let dst, let iteratorResult, let profile):
            if let profile = profile {
                return "iteratorValue r\(dst.rawValue), r\(iteratorResult.rawValue), profile\(profile.rawValue)"
            } else {
                return "iteratorValue r\(dst.rawValue), r\(iteratorResult.rawValue)"
            }
        case .iteratorDone(let dst, let iteratorResult, let profile):
            if let profile = profile {
                return "iteratorDone r\(dst.rawValue), r\(iteratorResult.rawValue), profile\(profile.rawValue)"
            } else {
                return "iteratorDone r\(dst.rawValue), r\(iteratorResult.rawValue)"
            }
        case .iteratorClose(let iterator, let profile):
            if let profile = profile {
                return "iteratorClose r\(iterator.rawValue), profile\(profile.rawValue)"
            } else {
                return "iteratorClose r\(iterator.rawValue)"
            }
        case .getModuleVariable(let dst, let slot):
            return "getModuleVariable r\(dst.rawValue), module\(slot.rawValue)"
        case .putModuleVariable(let slot, let src):
            return "putModuleVariable module\(slot.rawValue), r\(src.rawValue)"
        case .getImportMeta(let dst):
            return "getImportMeta r\(dst.rawValue)"
        case .createMethod(let dst, let function, let homeObject):
            return "createMethod r\(dst.rawValue), f[\(function.rawValue)], r\(homeObject.rawValue)"
        case .defineClassMethod(let classObject, let name, let function, let flags):
            return "defineClassMethod r\(classObject.rawValue), cp[\(name.rawValue)], r\(function.rawValue), flags \(flags)"
        case .defineInstanceField(let thisValue, let name, let value, let flags):
            return "defineInstanceField r\(thisValue.rawValue), cp[\(name.rawValue)], r\(value.rawValue), flags \(flags)"
        case .defineStaticField(let classObject, let name, let value, let flags):
            return "defineStaticField r\(classObject.rawValue), cp[\(name.rawValue)], r\(value.rawValue), flags \(flags)"
        case .asyncEnter:
            return "asyncEnter"
        case .await(let dst, let value, let resumePoint):
            return "await r\(dst.rawValue), r\(value.rawValue), resumePoint \(resumePoint)"
        case .asyncReturn(let value):
            return "asyncReturn r\(value.rawValue)"
        case .asyncThrow(let value):
            return "asyncThrow r\(value.rawValue)"
        case .generatorEnter:
            return "generatorEnter"
        case .yield(let dst, let value, let resumePoint):
            return "yield r\(dst.rawValue), r\(value.rawValue), resumePoint \(resumePoint)"
        case .yieldStar(let dst, let iterator, let resumePoint):
            return "yieldStar r\(dst.rawValue), r\(iterator.rawValue), resumePoint \(resumePoint)"
        case .generatorReturn(let value):
            return "generatorReturn r\(value.rawValue)"
        case .generatorThrow(let value):
            return "generatorThrow r\(value.rawValue)"
        case .resumePoint(let id):
            return "resumePoint \(id)"
        case .profileValue(let reg, let slot):
            return "profileValue r\(reg.rawValue), profile\(slot.rawValue)"
        case .profileType(let reg, let slot):
            return "profileType r\(reg.rawValue), profile\(slot.rawValue)"
        case .profileBranch(let condition, let profile):
            return "profileBranch r\(condition.rawValue), profile\(profile.rawValue)"
        case .profileCall(let callee, let call):
            return "profileCall r\(callee.rawValue), call\(call.rawValue)"
        case .checkStructure(let reg, let structures, let fail):
            return "checkStructure r\(reg.rawValue), structures\(structures.rawValue), fail \(fail.rawValue)"
        case .checkCell(let reg, let fail):
            return "checkCell r\(reg.rawValue), fail \(fail.rawValue)"
        case .checkNumber(let reg, let fail):
            return "checkNumber r\(reg.rawValue), fail \(fail.rawValue)"
        case .checkInt32(let reg, let fail):
            return "checkInt32 r\(reg.rawValue), fail \(fail.rawValue)"
        case .checkString(let reg, let fail):
            return "checkString r\(reg.rawValue), fail \(fail.rawValue)"
        case .checkObject(let reg, let fail):
            return "checkObject r\(reg.rawValue), fail \(fail.rawValue)"
        case .checkArray(let reg, let fail):
            return "checkArray r\(reg.rawValue), fail \(fail.rawValue)"
        case .checkInt32Index(let reg, let fail):
            return "checkInt32Index r\(reg.rawValue), fail \(fail.rawValue)"
        case .checkStack:
            return "checkStack"
        case .runtimeCall(let dst, let id, let argsBase, let argc):
            return "runtimeCall r\(dst.rawValue), runtime\(id.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue)"
        case .intrinsicCall(let dst, let id, let argsBase, let argc):
            return "intrinsicCall r\(dst.rawValue), intrinsic\(id.rawValue), args r\(argsBase.rawValue), argc \(argc.rawValue)"
        }
    }
}