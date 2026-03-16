public enum Bytecode: Equatable, Hashable {
    // MARK: - Operand building blocks 

    public struct Reg: Equatable, Hashable, RawRepresentable {
        public var rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct CPIndex: Equatable, Hashable, RawRepresentable {
        public var rawValue: UInt32
        public init(rawValue: UInt32) { self.rawValue = rawValue }
    }

    public struct Argc: Equatable, Hashable, RawRepresentable {
        public var rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct HandlerId: Equatable, Hashable, RawRepresentable {
        public var rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct JumpOffset: Equatable, Hashable, RawRepresentable {
        public var rawValue: Int32
        public init(rawValue: Int32) { self.rawValue = rawValue }
    }

    public struct FeedbackSlot: Equatable, Hashable, RawRepresentable {
        public var rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
    }

    public struct U8U16: Equatable, Hashable {
        public var u8: UInt8
        public var u16: UInt16
        public init(_ u8: UInt8, _ u16: UInt16) { self.u8 = u8; self.u16 = u16 }
    }

    public enum TypedArrayKind: UInt8, Equatable, Hashable {
        // Define your TA kinds (Int8Array, Uint8Array, Float64Array, ...)
        case kind0 = 0
    }

    public enum DataViewKind: UInt8, Equatable, Hashable {
        // Define your DV load/store kinds (Int8, Uint16LE, Float32BE, ...)
        case kind0 = 0
    }

    // MARK: - 0) Meta / prefixes

    case nop                                 // ""
    case wide                                // ""
    case extraWide                           // ""
    case debugTrap(_ code: UInt8)            // "u8"
    case coverageMark(_ id: UInt16)          // "u16"

    // MARK: - 1) Control flow

    case jmp(_ off: JumpOffset)                              // "i32"
    case jmpIfTrue(_ off: JumpOffset)                        // "i32"
    case jmpIfFalse(_ off: JumpOffset)                       // "i32"
    case jmpIfNull(_ off: JumpOffset)                        // "i32"
    case jmpIfUndef(_ off: JumpOffset)                       // "i32"
    case jmpIfEq(_ r: Reg, _ off: JumpOffset)                // "reg,i32"
    case jmpIfStrictEq(_ r: Reg, _ off: JumpOffset)          // "reg,i32"
    case jmpTableSmi(_ tableId: UInt16)                      // "u16"
    case loopHint(_ hint: UInt16)                            // "u16"
    case `return`                                            // ""
    case returnVoid                                          // ""
    case `throw`                                             // ""
    case rethrow                                             // ""
    case enterTry(_ handler: HandlerId)                      // "u16"
    case leaveTry                                            // ""
    case enterFinally(_ handler: HandlerId)                  // "u16"
    case endFinally                                          // ""

    // MARK: - 2) Accumulator/register moves

    case ldar(_ r: Reg)                      // "reg"
    case star(_ r: Reg)                      // "reg"
    case mov(_ dst: Reg, _ src: Reg)         // "dst,src"
    case swapAcc(_ r: Reg)                   // "reg"
    case clearReg(_ r: Reg)                  // "reg"

    // MARK: - 3) Constants / literals

    case ldaUndef                            // ""
    case ldaNull                             // ""
    case ldaTrue                             // ""
    case ldaFalse                            // ""
    case ldaZero                             // ""
    case ldaSmi8(_ v: Int8)                  // "i8"
    case ldaSmi32(_ v: Int32)                // "i32"
    case ldaConst(_ idx: CPIndex)            // "cp"
    case ldaNaN                              // ""
    case ldaPosInf                           // ""
    case ldaNegInf                           // ""

    // MARK: - 4) Lexical/env/global (scope)

    case ldaGlobal(_ name: CPIndex)          // "cp"
    case staGlobal(_ name: CPIndex)          // "cp"
    case ldaLexical(_ slot: UInt16)          // "u16"
    case staLexical(_ slot: UInt16)          // "u16"
    case initLexical(_ slot: UInt16)         // "u16"
    case ldaContextSlot(_ level: UInt8, _ slot: UInt16)  // "u8,u16"
    case staContextSlot(_ level: UInt8, _ slot: UInt16)  // "u8,u16"
    case deleteBinding(_ name: CPIndex)      // "cp"

    // MARK: - 5) Object/array/function creation

    case newObject(_ shapeHint: UInt8)       // "u8"
    case newArray(_ length: UInt16)          // "u16"
    case newArrayFrom(_ base: Reg, _ count: UInt16) // "reg,u16"
    case newFunction(_ cp: CPIndex)          // "cp"
    case newClosure(_ cp: CPIndex)           // "cp"
    case newClass(_ cp: CPIndex)             // "cp"
    case cloneObjectLit(_ boilerplate: CPIndex) // "cp"
    case cloneArrayLit(_ boilerplate: CPIndex)  // "cp"

    // MARK: - 5b) Class semantics / super / private

    case loadThis                                            // ""
    case getSuperPropNamed(_ thisReg: Reg, _ name: CPIndex)  // "reg,cp"
    case setSuperPropNamed(_ thisReg: Reg, _ name: CPIndex)  // "reg,cp"
    case getPrivate(_ obj: Reg, _ name: CPIndex)             // "reg,cp"
    case setPrivate(_ obj: Reg, _ name: CPIndex)             // "reg,cp"
    case hasPrivate(_ obj: Reg, _ name: CPIndex)             // "reg,cp"
    case setHomeObject(_ fn: Reg, _ home: Reg)               // "reg,reg"

    // MARK: - 6) Property access (IC-like surface)

    case getPropNamed(_ obj: Reg, _ name: CPIndex)          // "reg,cp"
    case setPropNamed(_ obj: Reg, _ name: CPIndex)          // "reg,cp"
    case getPropNamedIC(_ obj: Reg, _ name: CPIndex, _ slot: FeedbackSlot)          // "reg,cp,u16"
    case setPropNamedIC(_ obj: Reg, _ name: CPIndex, _ slot: FeedbackSlot)          // "reg,cp,u16"
    case definePropNamed(_ obj: Reg, _ name: CPIndex, _ flags: UInt8) // "reg,cp,u8"
    case getPropKeyed(_ obj: Reg, _ key: Reg)               // "reg,reg"
    case getPropKeyedIC(_ obj: Reg, _ key: Reg, _ slot: FeedbackSlot)               // "reg,reg,u16"
    case setPropKeyedIC(_ obj: Reg, _ key: Reg, _ slot: FeedbackSlot)               // "reg,reg,u16"
    case setPropKeyed(_ obj: Reg, _ key: Reg)               // "reg,reg"
    case hasProp(_ obj: Reg, _ name: CPIndex)               // "reg,cp"
    case deletePropNamed(_ obj: Reg, _ name: CPIndex)       // "reg,cp"
    case loadElem(_ arr: Reg, _ index: Reg)                 // "reg,reg"
    case storeElem(_ arr: Reg, _ index: Reg)                // "reg,reg"
    case loadLength(_ obj: Reg)                             // "reg"

    // MARK: - 7) Type tests / conversions

    case typeof_                              // ""
    case isCallable                           // ""
    case isConstructor                        // ""
    case isSmi                                // ""
    case toNumber                             // ""
    case toNumeric                            // ""
    case toInt32                              // ""
    case toUint32                             // ""
    case toString                             // ""
    case toObject                             // ""

    // MARK: - 8) Arithmetic / bitwise (register + acc style)

    case add(_ r: Reg)                        // "reg"
    case sub(_ r: Reg)                        // "reg"
    case mul(_ r: Reg)                        // "reg"
    case div(_ r: Reg)                        // "reg"
    case mod(_ r: Reg)                        // "reg"
    case addI32(_ imm: Int32)                 // "i32"
    case shl(_ r: Reg)                        // "reg"
    case shr(_ r: Reg)                        // "reg"
    case ushr(_ r: Reg)                       // "reg"
    case and(_ r: Reg)                        // "reg"
    case or(_ r: Reg)                         // "reg"
    case xor(_ r: Reg)                        // "reg"
    case bitnot                               // ""
    case neg                                  // ""
    case inc(_ r: Reg)                        // "reg"
    case dec(_ r: Reg)                        // "reg"

    // MARK: - 9) Compare / equality

    case eq(_ r: Reg)                         // "reg"
    case strictEq(_ r: Reg)                   // "reg"
    case lt(_ r: Reg)                         // "reg"
    case le(_ r: Reg)                         // "reg"
    case gt(_ r: Reg)                         // "reg"
    case ge(_ r: Reg)                         // "reg"
    case instanceof(_ r: Reg)                 // "reg"
    case inOp(_ r: Reg)                       // "reg"

    // MARK: - 10) Calls / construct / spread (ABI mismatch surface)

    case call(_ callee: Reg, _ argc: Argc)                            // "reg,argc"
    case callIC(_ callee: Reg, _ argc: Argc, _ slot: FeedbackSlot)                  // "reg,argc,u16"
    case callMethod(_ obj: Reg, _ name: CPIndex, _ argc: Argc)        // "reg,cp,argc"
    case callMethodIC(_ obj: Reg, _ name: CPIndex, _ argc: Argc, _ slot: FeedbackSlot) // "reg,cp,argc,u16"
    case callWithThis(_ callee: Reg, _ thisReg: Reg, _ argc: Argc)    // "reg,reg,argc"
    case callSpread(_ callee: Reg, _ argc: Argc, _ spread: Reg)       // "reg,argc,reg"
    case construct(_ ctor: Reg, _ argc: Argc)                         // "reg,argc"
    case constructIC(_ ctor: Reg, _ argc: Argc, _ slot: FeedbackSlot)               // "reg,argc,u16"
    case constructSpread(_ ctor: Reg, _ argc: Argc, _ spread: Reg)    // "reg,argc,reg"
    case tailCall(_ callee: Reg, _ argc: Argc)                        // "reg,argc"
    case newTarget                                                     // ""

    // MARK: - 11) Iterators / for-of / generators-ish

    case getIterator                           // ""
    case iterNext(_ iter: Reg)                 // "reg"
    case iterValue                             // ""
    case iterDone                              // ""
    case closeIterator(_ iter: Reg)            // "reg"

    // MARK: - 12) Async/microtask hooks (state ordering surface)

    case enqueueMicrotask(_ r: Reg)            // "reg"
    case runMicrotasks                         // ""
    case await(_ promiseLike: Reg)             // "reg"

    // MARK: - 13) Modules

    case ldaModuleVar(_ idx: UInt16)           // "u16"
    case staModuleVar(_ idx: UInt16)           // "u16"
    case getImportMeta                         // ""

    // MARK: - 14) Strings / concatenation

    case stringConcat(_ r: Reg)                // "reg"
    case stringCharAt(_ r: Reg)                // "reg"
    case stringCodeAt(_ r: Reg)                // "reg"

    // MARK: - 15) ArrayBuffer/TypedArray/DataView

    case newArrayBuffer(_ byteLength: UInt32)  // "u32"
    case abDetach(_ ab: Reg)                   // "reg"
    case newTypedArray(_ kind: TypedArrayKind, _ ab: Reg, _ byteOff: UInt32, _ len: UInt32) // "u8,reg,u32,u32"
    case taLoadElem(_ ta: Reg, _ index: Reg)   // "reg,reg"
    case taStoreElem(_ ta: Reg, _ index: Reg)  // "reg,reg"
    case dvLoad(_ dv: Reg, _ kind: DataViewKind, _ off: Reg)          // "reg,u8,reg"
    case dvStore(_ dv: Reg, _ kind: DataViewKind, _ off: Reg)         // "reg,u8,reg"

    // MARK: - 16) Memory / GC interaction hooks

    case gcSafepoint                           // ""
    case writeBarrier(_ obj: Reg, _ val: Reg)  // "reg,reg"
    case weakRefMake(_ obj: Reg)               // "reg"
    case weakRefDeref(_ weak: Reg)             // "reg"

    // MARK: - 17) Atomics-ish

    case atomicLoadI32(_ ta: Reg, _ index: Reg)                    // "reg,reg"
    case atomicStoreI32(_ ta: Reg, _ index: Reg)                   // "reg,reg"
    case atomicCasI32(_ ta: Reg, _ index: Reg, _ expected: Reg)    // "reg,reg,reg"

    // MARK: - 18) Misc runtime helpers

    case checkStack                            // ""
    case assertType(_ tag: UInt8)              // "u8"
    case osrHint(_ id: UInt16)                 // "u16"
    case deoptHint(_ id: UInt16)               // "u16"
    case runtimeCall(_ id: UInt16, _ argc: Argc) // "u16,argc"
    case halt                                  // ""
}