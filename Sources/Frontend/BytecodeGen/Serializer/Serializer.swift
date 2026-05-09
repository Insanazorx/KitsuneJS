class SerializationUnit {
    var globalBasicBlocks: [BasicBlock] = []
    var globalConstantsPool: ConstantsPool = ConstantsPool()
    var functionTable: [Bytecode.FunctionID: CodeBlock] = [:]
    
}


class Serializer {
    static let globalCodeBlockID: UInt32 = UInt32.max
    static let codeBlockConstantPoolMarker: [UInt8] = [0xC0, 0xDE, 0xB1, 0x0C]

    public var SerializedBytecode: [UInt8] = []
    
    var serializationUnit: SerializationUnit
    var offsetCounter: UInt32 = 0

    var basicBlockOffsets: [UInt32] = [] // basic block starting offsets 
    var basicBlockIdToOffset: [Int: UInt32] = [:]
    var OffsetsToBackpatchInSerialization: [(offsetToBackpatch: UInt32, ref: Int)] = []
    var functionIdToOffset: [Bytecode.FunctionID: UInt32] = [:]

    init(serializationUnit: SerializationUnit) {
        self.serializationUnit = serializationUnit
    }
}

extension Serializer {

    func exportBytecode() -> [UInt8] {
        return SerializedBytecode
    }
    
    func incrementOffset(by amount: UInt32) {
        offsetCounter += amount
    }

    func putBasicBlockOffset(offset: UInt32) {
        basicBlockOffsets.append(offset)
    }

    func putBasicBlockOffset(block: BasicBlock) {
        basicBlockOffsets.append(offsetCounter)
        basicBlockIdToOffset[block.id] = offsetCounter
    }

    func putRecordOnBackpatchList(ref: Int) {
        OffsetsToBackpatchInSerialization.append((offsetCounter, ref))
    }

    func putFunctionIDRecord(functionId: Bytecode.FunctionID, entryOffset: UInt32) {
        functionIdToOffset[functionId] = entryOffset
    }

    func emitByte(_ byte: UInt8) {
        SerializedBytecode.append(byte)
        incrementOffset(by: 1)
    }

    func emitBytes(_ bytes: [UInt8]) {
        SerializedBytecode.append(contentsOf: bytes)
        incrementOffset(by: UInt32(bytes.count))
    }

    func emitUInt32(_ value: UInt32) {
        var val = value.littleEndian
        let bytes = withUnsafeBytes(of: &val) { Array($0) }
        emitBytes(bytes)
        
    }

    func emitUInt16(_ value: UInt16) {
        var val = value.littleEndian
        let bytes = withUnsafeBytes(of: &val) { Array($0) }
        emitBytes(bytes)
        
    }

    func emitUInt8(_ value: UInt8) {
        emitByte(value)
    }

    func emitInt32(_ value: Int32) {
        var val = value.littleEndian
        let bytes = withUnsafeBytes(of: &val) { Array($0) }
        emitBytes(bytes)
    }

    func emitString(_ str: String) {
        if let data = str.data(using: .utf8) {
            let bytes = [UInt8](data)
            emitBytes(bytes)
            emitByte(0) // Null terminator for strings
        } else {
            fatalError("Failed to encode string: \(str)")
        }
    }
}

extension Serializer {

    func emitHeader() {
        emitBytes([0xDE, 0xAD, 0xBE, 0xEF,
                   0xCA, 0xFE, 0xBA, 0xBE,
                   0xFE, 0xED, 0xFA, 0xCE,
                   0x00, 0x01, 0x00, 0x00])
        
        for _ in 0..<3 { // section table placeholder for 3 sections: basic blocks, function table, constants pool
            emitUInt32(0xFFFFFFFF)
        } 
    }

    func patchUInt32(_ value: UInt32, at offset: Int) {
        guard offset >= 0, offset + 4 <= SerializedBytecode.count else {
            fatalError("Invalid UInt32 patch offset: \(offset)")
        }

        var val = value.littleEndian
        let bytes = withUnsafeBytes(of: &val) { Array($0) }
        for i in 0..<4 {
            SerializedBytecode[offset + i] = bytes[i]
        }
    }

    func emitSectionTable(sectionOffsets: (section1: UInt32, section2: UInt32, section3: UInt32)) {
        // For simplicity, we assume a fixed number of sections (3 sections in order: basic blocks, function table, constants pool), and emit their offsets in a fixed order. 
        let basicBlocksStartingOffset = sectionOffsets.section1
        let functionTableStartingOffset = sectionOffsets.section2
        let constantsPoolStartingOffset = sectionOffsets.section3

        // hardcoded offset for section table in header as 16 meaning it comes right after the 16-byte file header
        patchUInt32(basicBlocksStartingOffset, at: 16)
        patchUInt32(functionTableStartingOffset, at: 20)
        patchUInt32(constantsPoolStartingOffset, at: 24)
    }
    

    func emitConstantPoolRecord(codeBlockId: UInt32, constantsPool: ConstantsPool) {
        emitBytes(Self.codeBlockConstantPoolMarker)
        emitUInt32(codeBlockId)
        
        let constantsCount = UInt32(constantsPool.pool.count)
        emitUInt32(constantsCount)
        
        let sortedConstants = constantsPool.pool.sorted {
            if $0.value == $1.value {
                return $0.key < $1.key
            }
            return $0.value < $1.value
        }

        for (constant, index) in sortedConstants {
            emitBytes([0xFA, 0xCE, 0xFA, 0xCE]) // A sequence of bytes that indicates the start of a constant pool entry
            serializeCPIndex(Bytecode.CPIndex(rawValue: index))
            emitString(constant)
        }
    }

    func emitConstantsPool() -> UInt32 {
        let constantsPoolStartingOffset = offsetCounter

        let sortedFunctions = serializationUnit.functionTable.sorted {
            $0.key.rawValue < $1.key.rawValue
        }
        emitUInt32(UInt32(sortedFunctions.count + 1))

        emitConstantPoolRecord(
            codeBlockId: Self.globalCodeBlockID,
            constantsPool: serializationUnit.globalConstantsPool
        )

        for (functionId, codeBlock) in sortedFunctions {
            emitConstantPoolRecord(
                codeBlockId: functionId.rawValue,
                constantsPool: codeBlock.constantPool
            )
        }

        return constantsPoolStartingOffset
    }

    func emitFunctionTable() -> UInt32 {
        let functionTableStartingOffset = offsetCounter

        let sortedFunctionOffsets = functionIdToOffset.sorted {
            $0.key.rawValue < $1.key.rawValue
        }

        for (functionId, entryOffset) in sortedFunctionOffsets {
            emitUInt32(functionId.rawValue)
            emitUInt32(entryOffset)
        }

        return functionTableStartingOffset
    }

    func emitGlobalBasicBlocks() -> UInt32 {
        let BBStartingOffset = offsetCounter
        
        for block in serializationUnit.globalBasicBlocks {
            putBasicBlockOffset(block: block)
            serializeBasicBlock(block)
        }

        return BBStartingOffset
    }

    func emitFunctionBasicBlocks() { 

        let sortedFunctions = serializationUnit.functionTable.sorted {
            $0.key.rawValue < $1.key.rawValue
        }

        for (functionId, codeBlock) in sortedFunctions {
            putFunctionIDRecord(functionId: functionId, entryOffset: offsetCounter)
            for block in codeBlock.basicBlocks {
                putBasicBlockOffset(block: block)
                serializeBasicBlock(block)
            }
        }

    }

    func emitSectionSeparator() {
        emitBytes([0xFF, 0xFF, 0xFF, 0xFF,
                   0xCA, 0xFE, 0xBA, 0xBE,
                   0xDE, 0xAD, 0xBE, 0xEF,
                   0xFF, 0xFF, 0xFF, 0xFF]) // A sequence of bytes that indicates the end of a section (e.g., end of basic blocks, end of function table, etc.)
    }

    
    func backpatchJumpOffsets() {
        for (offsetToBackpatch, ref) in OffsetsToBackpatchInSerialization {
            let targetOffset: UInt32
            if let blockOffset = basicBlockIdToOffset[ref] {
                targetOffset = blockOffset
            } else if ref >= 0, ref < basicBlockOffsets.count {
                targetOffset = basicBlockOffsets[ref]
            } else {
                fatalError("Invalid backpatch reference: \(ref)")
            }
            patchUInt32(targetOffset, at: Int(offsetToBackpatch))
        }
    }


}

extension Serializer {
    func serialize() {

        emitHeader()

        emitSectionSeparator()
        let codeSegmentOffset = offsetCounter
        _ = emitGlobalBasicBlocks()
        emitFunctionBasicBlocks()

        emitSectionSeparator()
        let functionTableOffset = emitFunctionTable()
        
        emitSectionSeparator()
        let constantsPoolOffset = emitConstantsPool()

        emitSectionTable(sectionOffsets: (codeSegmentOffset, functionTableOffset, constantsPoolOffset)) // goes after Header
        backpatchJumpOffsets()

    }

    func serializeBasicBlock(_ block: BasicBlock) {
        for bytecode in block.instructions {
            serializeBytecode(bytecode)
        }

        if let terminator = block.terminator {
            serializeTerminator(terminator)
        }
    }

    func serializeBytecode(_ bytecode: Bytecode) {
        emitByte(bytecode.opcode.rawValue)

        switch bytecode {
            case .nop, .debugDumpScope, .unreachable, .halt,
                 .enterGlobal, .enterFunction,
                 .popLexicalEnvironment,
                 .returnUndefined,
                 .rethrow,
                 .clearException,
                 .generatorEnter,
                 .checkStack:
                break

            case .coverageMark(let id):
                emitUInt32(id)

            case .debugTrap(let id):
                emitUInt16(id)

            case .debugLog(let reg):
                serializeReg(reg)

            case .debugDumpIC(let slot):
                serializeICSlot(slot)

            case .move(let dst, let src):
                serializeReg(dst)
                serializeReg(src)

            case .clearReg(let reg):
                serializeReg(reg)

            case .swap(let lhs, let rhs):
                serializeReg(lhs)
                serializeReg(rhs)

            case .loadThis(let dst),
                 .loadNewTarget(let dst),
                 .loadSuperConstructor(let dst),
                 .loadUndefined(let dst),
                 .loadNull(let dst),
                 .loadTrue(let dst),
                 .loadFalse(let dst),
                 .loadEmpty(let dst),
                 .newObject(let dst),
                 .getImportMeta(let dst),
                 .createPromise(let dst),
                 .getResumeValue(let dst),
                 .getResumeKind(let dst),
                 .returnValue(let dst),
                 .throwValue(let dst),
                 .getException(let dst):
                serializeReg(dst)

            case .loadInt32(let dst, let value):
                serializeReg(dst)
                emitInt32(value)

            case .loadDouble(let dst, let constant),
                 .loadString(let dst, let constant),
                 .loadBigInt(let dst, let constant),
                 .loadSymbol(let dst, let constant),
                 .loadConst(let dst, let constant),
                 .newObjectLiteral(let dst, let constant),
                 .newArrayLiteral(let dst, let constant),
                 .newRegExp(let dst, let constant),
                 .switchInt(let dst, let constant),
                 .switchString(let dst, let constant):
                serializeReg(dst)
                serializeCPIndex(constant)

            case .newObjectWithProto(let dst, let proto):
                serializeReg(dst)
                serializeReg(proto)

            case .newArray(let dst, let firstElement, let count),
                 .newArrayWithSpread(let dst, let firstElement, let count):
                serializeReg(dst)
                serializeReg(firstElement)
                emitUInt16(count)

            case .newArrayWithSize(let dst, let minimumCapacity):
                serializeReg(dst)
                emitUInt16(minimumCapacity)

            case .createFunction(let dst, let function),
                 .createGeneratorObject(let dst, let function),
                 .createAsyncGeneratorObject(let dst, let function):
                serializeReg(dst)
                serializeFunctionID(function)

            case .createClosure(let dst, let function, let environment),
                 .createArrowClosure(let dst, let function, let environment),
                 .createGeneratorClosure(let dst, let function, let environment),
                 .createAsyncClosure(let dst, let function, let environment):
                serializeReg(dst)
                serializeFunctionID(function)
                serializeReg(environment)

            case .createClass(let dst, let constructor, let protoParent, let metadata):
                serializeReg(dst)
                serializeFunctionID(constructor)
                serializeOptionalReg(protoParent)
                serializeCPIndex(metadata)

            case .setHomeObject(let function, let homeObject):
                serializeReg(function)
                serializeReg(homeObject)

            case .getArgument(let dst, let slot):
                serializeReg(dst)
                serializeArgSlot(slot)

            case .putArgument(let slot, let src):
                serializeArgSlot(slot)
                serializeReg(src)

            case .getLocal(let dst, let slot):
                serializeReg(dst)
                serializeLocalSlot(slot)

            case .putLocal(let slot, let src),
                 .initLocal(let slot, let src):
                serializeLocalSlot(slot)
                serializeReg(src)

            case .checkTDZLocal(let slot):
                serializeLocalSlot(slot)

            case .createLexicalEnvironment(let dst, let layout):
                serializeReg(dst)
                serializeScopeLayoutID(layout)

            case .pushLexicalEnvironment(let environment):
                serializeReg(environment)

            case .getContext(let dst, let depth, let slot):
                serializeReg(dst)
                serializeContextDepth(depth)
                serializeContextSlot(slot)

            case .putContext(let depth, let slot, let src):
                serializeContextDepth(depth)
                serializeContextSlot(slot)
                serializeReg(src)

            case .checkTDZContext(let depth, let slot):
                serializeContextDepth(depth)
                serializeContextSlot(slot)

            case .materializeScope(let dst, let depth):
                serializeReg(dst)
                serializeContextDepth(depth)

            case .resolveName(let dst, let name, let profile):
                serializeReg(dst)
                serializeCPIndex(name)
                serializeOptionalProfileSlot(profile)

            case .getGlobalLexical(let dst, let slot, let profile),
                 .typeofGlobal(let dst, let slot, let profile):
                serializeReg(dst)
                serializeGlobalSlot(slot)
                serializeOptionalProfileSlot(profile)

            case .putGlobalLexical(let slot, let src, let profile):
                serializeGlobalSlot(slot)
                serializeReg(src)
                serializeOptionalProfileSlot(profile)

            case .initGlobalLexical(let slot, let src),
                 .initGlobalVar(let slot, let src):
                serializeGlobalSlot(slot)
                serializeReg(src)

            case .getGlobalVar(let dst, let slot, let cache):
                serializeReg(dst)
                serializeGlobalSlot(slot)
                serializeOptionalICSlot(cache)

            case .putGlobalVar(let slot, let src, let cache):
                serializeGlobalSlot(slot)
                serializeReg(src)
                serializeOptionalICSlot(cache)

            case .getGlobalProperty(let dst, let name, let cache):
                serializeReg(dst)
                serializeCPIndex(name)
                serializeOptionalICSlot(cache)

            case .putGlobalProperty(let name, let src, let cache):
                serializeCPIndex(name)
                serializeReg(src)
                serializeOptionalICSlot(cache)

            case .deleteGlobal(let dst, let slot):
                serializeReg(dst)
                serializeGlobalSlot(slot)

            case .getById(let dst, let base, let name, let cache):
                serializeReg(dst)
                serializeReg(base)
                serializeCPIndex(name)
                serializeOptionalICSlot(cache)

            case .putById(let base, let name, let value, let cache):
                serializeReg(base)
                serializeCPIndex(name)
                serializeReg(value)
                serializeOptionalICSlot(cache)

            case .getByVal(let dst, let base, let key, let cache):
                serializeReg(dst)
                serializeReg(base)
                serializeReg(key)
                serializeOptionalICSlot(cache)

            case .putByVal(let base, let key, let value, let cache):
                serializeReg(base)
                serializeReg(key)
                serializeReg(value)
                serializeOptionalICSlot(cache)

            case .getByIdWithThis(let dst, let base, let thisValue, let name, let cache):
                serializeReg(dst)
                serializeReg(base)
                serializeReg(thisValue)
                serializeCPIndex(name)
                serializeOptionalICSlot(cache)

            case .getByValWithThis(let dst, let base, let key, let thisValue, let cache):
                serializeReg(dst)
                serializeReg(base)
                serializeReg(key)
                serializeReg(thisValue)
                serializeOptionalICSlot(cache)

            case .getMethodById(let callee, let thisValue, let base, let name, let cache):
                serializeReg(callee)
                serializeReg(thisValue)
                serializeReg(base)
                serializeCPIndex(name)
                serializeOptionalICSlot(cache)

            case .getMethodByVal(let callee, let thisValue, let base, let key, let cache):
                serializeReg(callee)
                serializeReg(thisValue)
                serializeReg(base)
                serializeReg(key)
                serializeOptionalICSlot(cache)

            case .defineOwnById(let base, let name, let value, let flags):
                serializeReg(base)
                serializeCPIndex(name)
                serializeReg(value)
                serializePropertyFlags(flags)

            case .defineOwnByVal(let base, let key, let value, let flags):
                serializeReg(base)
                serializeReg(key)
                serializeReg(value)
                serializePropertyFlags(flags)

            case .deleteById(let dst, let base, let name, let profile),
                 .inById(let dst, let base, let name, let profile):
                serializeReg(dst)
                serializeReg(base)
                serializeCPIndex(name)
                serializeOptionalProfileSlot(profile)

            case .deleteByVal(let dst, let base, let key, let profile),
                 .hasProperty(let dst, let base, let key, let profile),
                 .inByVal(let dst, let base, let key, let profile):
                serializeReg(dst)
                serializeReg(base)
                serializeReg(key)
                serializeOptionalProfileSlot(profile)

            case .getPrivateById(let dst, let base, let name),
                 .hasPrivateById(let dst, let base, let name):
                serializeReg(dst)
                serializeReg(base)
                serializeCPIndex(name)

            case .putPrivateById(let base, let name, let value),
                 .definePrivateById(let base, let name, let value):
                serializeReg(base)
                serializeCPIndex(name)
                serializeReg(value)

            case .getSuperById(let dst, let thisValue, let homeObject, let name, let cache):
                serializeReg(dst)
                serializeReg(thisValue)
                serializeReg(homeObject)
                serializeCPIndex(name)
                serializeOptionalICSlot(cache)

            case .putSuperById(let thisValue, let homeObject, let name, let value, let cache):
                serializeReg(thisValue)
                serializeReg(homeObject)
                serializeCPIndex(name)
                serializeReg(value)
                serializeOptionalICSlot(cache)

            case .getSuperByVal(let dst, let thisValue, let homeObject, let key, let cache):
                serializeReg(dst)
                serializeReg(thisValue)
                serializeReg(homeObject)
                serializeReg(key)
                serializeOptionalICSlot(cache)

            case .putSuperByVal(let thisValue, let homeObject, let key, let value, let cache):
                serializeReg(thisValue)
                serializeReg(homeObject)
                serializeReg(key)
                serializeReg(value)
                serializeOptionalICSlot(cache)

            case .getLength(let dst, let base, let cache):
                serializeReg(dst)
                serializeReg(base)
                serializeOptionalICSlot(cache)

            case .putLength(let base, let value, let cache):
                serializeReg(base)
                serializeReg(value)
                serializeOptionalICSlot(cache)

            case .getByIndex(let dst, let base, let index, let cache):
                serializeReg(dst)
                serializeReg(base)
                emitUInt32(index)
                serializeOptionalICSlot(cache)

            case .putByIndex(let base, let index, let value, let cache):
                serializeReg(base)
                emitUInt32(index)
                serializeReg(value)
                serializeOptionalICSlot(cache)

            case .arrayPush(let dst, let array, let value, let profile):
                serializeReg(dst)
                serializeReg(array)
                serializeReg(value)
                serializeOptionalProfileSlot(profile)

            case .arrayPop(let dst, let array, let profile):
                serializeReg(dst)
                serializeReg(array)
                serializeOptionalProfileSlot(profile)

            case .toNumber(let dst, let src, let profile),
                 .toNumeric(let dst, let src, let profile),
                 .toString(let dst, let src, let profile),
                 .toObject(let dst, let src, let profile),
                 .toBoolean(let dst, let src, let profile),
                 .toPropertyKey(let dst, let src, let profile),
                 .typeofValue(let dst, let src, let profile),
                 .bitNot(let dst, let src, let profile),
                 .negate(let dst, let src, let profile),
                 .increment(let dst, let src, let profile),
                 .decrement(let dst, let src, let profile):
                serializeReg(dst)
                serializeReg(src)
                serializeOptionalProfileSlot(profile)

            case .isCallable(let dst, let src),
                 .isConstructor(let dst, let src),
                 .voidOp(let dst, let src),
                 .logicalNot(let dst, let src):
                serializeReg(dst)
                serializeReg(src)

            case .add(let dst, let lhs, let rhs, let profile),
                 .sub(let dst, let lhs, let rhs, let profile),
                 .mul(let dst, let lhs, let rhs, let profile),
                 .div(let dst, let lhs, let rhs, let profile),
                 .mod(let dst, let lhs, let rhs, let profile),
                 .pow(let dst, let lhs, let rhs, let profile),
                 .bitAnd(let dst, let lhs, let rhs, let profile),
                 .bitOr(let dst, let lhs, let rhs, let profile),
                 .bitXor(let dst, let lhs, let rhs, let profile),
                 .leftShift(let dst, let lhs, let rhs, let profile),
                 .rightShift(let dst, let lhs, let rhs, let profile),
                 .unsignedRightShift(let dst, let lhs, let rhs, let profile),
                 .equal(let dst, let lhs, let rhs, let profile),
                 .notEqual(let dst, let lhs, let rhs, let profile),
                 .strictEqual(let dst, let lhs, let rhs, let profile),
                 .strictNotEqual(let dst, let lhs, let rhs, let profile),
                 .lessThan(let dst, let lhs, let rhs, let profile),
                 .lessThanOrEqual(let dst, let lhs, let rhs, let profile),
                 .greaterThan(let dst, let lhs, let rhs, let profile),
                 .greaterThanOrEqual(let dst, let lhs, let rhs, let profile),
                 .sameValue(let dst, let lhs, let rhs, let profile),
                 .sameValueZero(let dst, let lhs, let rhs, let profile):
                serializeReg(dst)
                serializeReg(lhs)
                serializeReg(rhs)
                serializeOptionalProfileSlot(profile)

            case .instanceOf(let dst, let value, let constructor, let profile):
                serializeReg(dst)
                serializeReg(value)
                serializeReg(constructor)
                serializeOptionalProfileSlot(profile)

            case .inOperator(let dst, let key, let base, let profile):
                serializeReg(dst)
                serializeReg(key)
                serializeReg(base)
                serializeOptionalProfileSlot(profile)

            case .call(let dst, let callee, let thisValue, let argsBase, let argc, let call),
                 .callEval(let dst, let callee, let thisValue, let argsBase, let argc, let call):
                serializeReg(dst)
                serializeReg(callee)
                serializeReg(thisValue)
                serializeReg(argsBase)
                serializeArgCount(argc)
                serializeOptionalCallSlot(call)

            case .callDirect(let dst, let function, let thisValue, let argsBase, let argc, let call):
                serializeReg(dst)
                serializeFunctionID(function)
                serializeReg(thisValue)
                serializeReg(argsBase)
                serializeArgCount(argc)
                serializeOptionalCallSlot(call)

            case .callVarargs(let dst, let callee, let thisValue, let argsArray, let call):
                serializeReg(dst)
                serializeReg(callee)
                serializeReg(thisValue)
                serializeReg(argsArray)
                serializeOptionalCallSlot(call)

            case .tailCall(let callee, let thisValue, let argsBase, let argc, let call):
                serializeReg(callee)
                serializeReg(thisValue)
                serializeReg(argsBase)
                serializeArgCount(argc)
                serializeOptionalCallSlot(call)

            case .construct(let dst, let callee, let argsBase, let argc, let call),
                 .superConstruct(let dst, let callee, let argsBase, let argc, let call):
                serializeReg(dst)
                serializeReg(callee)
                serializeReg(argsBase)
                serializeArgCount(argc)
                serializeOptionalCallSlot(call)

            case .constructVarargs(let dst, let callee, let argsArray, let call),
                 .superConstructVarargs(let dst, let callee, let argsArray, let call):
                serializeReg(dst)
                serializeReg(callee)
                serializeReg(argsArray)
                serializeOptionalCallSlot(call)

            case .jump(let offset):
                serializeJumpOffset(offset)

            case .jumpIfTrue(let condition, let offset),
                 .jumpIfFalse(let condition, let offset),
                 .jumpIfNull(let condition, let offset),
                 .jumpIfUndefined(let condition, let offset),
                 .jumpIfNullish(let condition, let offset),
                 .jumpIfNotNullish(let condition, let offset),
                 .jumpIfEmpty(let condition, let offset):
                serializeReg(condition)
                serializeJumpOffset(offset)

            case .enterCatch(let handler),
                 .enterFinally(let handler):
                serializeHandlerID(handler)

            case .getIterator(let dst, let value, let kind, let profile):
                serializeReg(dst)
                serializeReg(value)
                serializeIteratorKind(kind)
                serializeOptionalProfileSlot(profile)

            case .iteratorNext(let dst, let iterator, let profile),
                 .iteratorValue(let dst, let iterator, let profile),
                 .iteratorDone(let dst, let iterator, let profile):
                serializeReg(dst)
                serializeReg(iterator)
                serializeOptionalProfileSlot(profile)

            case .iteratorClose(let iterator, let profile):
                serializeReg(iterator)
                serializeOptionalProfileSlot(profile)

            case .getModuleVariable(let dst, let slot):
                serializeReg(dst)
                serializeModuleSlot(slot)

            case .putModuleVariable(let slot, let src):
                serializeModuleSlot(slot)
                serializeReg(src)

            case .createMethod(let dst, let function, let homeObject):
                serializeReg(dst)
                serializeFunctionID(function)
                serializeReg(homeObject)

            case .defineClassMethod(let classObject, let name, let function, let flags):
                serializeReg(classObject)
                serializeCPIndex(name)
                serializeReg(function)
                serializePropertyFlags(flags)

            case .defineInstanceField(let thisValue, let name, let value, let flags),
                 .defineStaticField(let thisValue, let name, let value, let flags):
                serializeReg(thisValue)
                serializeCPIndex(name)
                serializeReg(value)
                serializePropertyFlags(flags)

            case .asyncEnter(let promise):
                serializeReg(promise)
            case .generatorReturn(let value),
                 .generatorThrow(let value),
                 .asyncGeneratorReturn(let value),
                 .asyncGeneratorThrow(let value):
                serializeReg(value)
            case .fulfillPromise(let promise, let value),
                 .rejectPromise(let promise, let value),
                 .promiseResolve(let promise, let value):
                serializeReg(promise)
                serializeReg(value)
                
            case .promiseThen(let dst, let promise, let onFulfilled, let onRejected):
                serializeReg(dst)
                serializeReg(promise)
                serializeReg(onFulfilled)
                serializeOptionalReg(onRejected)

            case .enqueueMicrotask(let job):
                serializeReg(job)

            case .awaitSuspend(let value, let promise, let resumePoint):
                serializeReg(value)
                serializeReg(promise)
                emitUInt16(resumePoint)

            case .asyncResumePoint(let id),
                 .resumePoint(let id):
                emitUInt16(id)

            case .jumpIfResumeKind(let kind, let offset):
                serializeResumeKind(kind)
                serializeJumpOffset(offset)

            case .generatorSuspend(let dst, let value, let resumePoint),
                 .asyncGeneratorSuspend(let dst, let value, let resumePoint),
                 .yieldStar(let dst, let value, let resumePoint):
                serializeReg(dst)
                serializeReg(value)
                emitUInt16(resumePoint)

            case .profileValue(let reg, let slot),
                 .profileType(let reg, let slot):
                serializeReg(reg)
                serializeProfileID(slot)

            case .profileBranch(let condition, let profile):
                serializeReg(condition)
                serializeProfileID(profile)

            case .profileCall(let callee, let call):
                serializeReg(callee)
                serializeCallSlot(call)

            case .checkStructure(let reg, let structures, let fail):
                serializeReg(reg)
                serializeStructureSetID(structures)
                serializeJumpOffset(fail)

            case .checkCell(let reg, let fail),
                 .checkNumber(let reg, let fail),
                 .checkInt32(let reg, let fail),
                 .checkString(let reg, let fail),
                 .checkObject(let reg, let fail),
                 .checkArray(let reg, let fail),
                 .checkInt32Index(let reg, let fail):
                serializeReg(reg)
                serializeJumpOffset(fail)

            case .runtimeCall(let dst, let id, let argsBase, let argc):
                serializeReg(dst)
                serializeRuntimeID(id)
                serializeReg(argsBase)
                serializeArgCount(argc)

            case .intrinsicCall(let dst, let id, let argsBase, let argc):
                serializeReg(dst)
                serializeIntrinsicID(id)
                serializeReg(argsBase)
                serializeArgCount(argc)
            }
    }

    func serializeTerminator(_ terminator: Terminator) {
        switch terminator {
        case .jump(let blockId):
            serializeBytecode(.jump(Bytecode.JumpOffset(rawValue: .backpatchRef(blockId))))

        case .conditionalJump(let condition, _, let falseBlockId):
            switch condition {
            case .jump,
                 .jumpIfTrue,
                 .jumpIfFalse,
                 .jumpIfNull,
                 .jumpIfUndefined,
                 .jumpIfNullish,
                 .jumpIfNotNullish,
                 .jumpIfEmpty,
                 .jumpIfResumeKind:
                serializeBytecode(condition)

            default:
                fatalError("Unsupported conditional terminator bytecode: \(condition)")
            }

            serializeBytecode(.jump(Bytecode.JumpOffset(rawValue: .backpatchRef(falseBlockId))))

        case .return(let reg):
            if let reg = reg {
                serializeBytecode(.returnValue(reg))
            } else {
                serializeBytecode(.returnUndefined)
            }

        case .throw:
            serializeBytecode(.rethrow)

        case .halt:
            serializeBytecode(.halt)
        }
    }
}

extension Serializer {
    func serializeReg(_ reg: Bytecode.Reg) {
        emitUInt16(reg.rawValue)
    }

    func serializeLocalSlot (_ slot: Bytecode.LocalSlot) {
        emitUInt16(slot.rawValue)
    }

    func serializeArgSlot (_ slot: Bytecode.ArgSlot) {
        emitUInt16(slot.rawValue)
    }

    func serializeContextSlot (_ slot: Bytecode.ContextSlot) {
        emitUInt16(slot.rawValue)
    }

    func serializeGlobalSlot (_ slot: Bytecode.GlobalSlot) {
        emitUInt16(slot.rawValue)
    }

    func serializeModuleSlot (_ slot: Bytecode.ModuleSlot) {
        emitUInt16(slot.rawValue)
    }

    func serializeCPIndex(_ index: Bytecode.CPIndex) {
        emitUInt32(index.rawValue)
    }

    func serializeFunctionID(_ functionId: Bytecode.FunctionID) {
        emitUInt32(functionId.rawValue)
    }

    func serializeHandlerID(_ handlerId: Bytecode.HandlerID) {
        emitUInt16(handlerId.rawValue)
    }

    func serializeProfileID(_ profileSlot: Bytecode.ProfileSlot) {
        emitUInt16(profileSlot.rawValue)
    }

    func serializeICSlot(_ icSlot: Bytecode.ICSlot) {
        emitUInt16(icSlot.rawValue)
    }

    func serializeCallSlot(_ callSlot: Bytecode.CallSlot) {
        emitUInt16(callSlot.rawValue)
    }

    func serializeArgCount(_ argCount: Bytecode.ArgCount) {
        emitUInt16(argCount.rawValue)
    }

    func serializeContextDepth(_ depth: Bytecode.ContextDepth) {
        emitUInt8(depth.rawValue)
    }

    func serializeScopeLayoutID(_ layoutId: Bytecode.ScopeLayoutID) {
        emitUInt16(layoutId.rawValue)
    }

    func serializeStructureSetID(_ setId: Bytecode.StructureSetID) {
        emitUInt16(setId.rawValue)
    }

    func serializeRuntimeID(_ runtimeId: Bytecode.RuntimeID) {
        emitUInt16(runtimeId.rawValue)
    }

    func serializeIntrinsicID(_ intrinsicId: Bytecode.IntrinsicID) {
        emitUInt16(intrinsicId.rawValue)
    }

    

    func serializeJumpOffset(_ offset: Bytecode.JumpOffset) {
        switch offset.rawValue {
        case .rawOffset(let rawOffset):
            emitUInt8(0)
            emitInt32(rawOffset)
        case .backpatchRef(let ref):
            emitUInt8(1)
            putRecordOnBackpatchList(ref: ref)
            emitUInt32(0xFFFFFFFF)
        }
    }

    func serializePropertyFlags(_ flags: Bytecode.PropertyFlags) {
        emitUInt8(flags.rawValue)
    }

    func serializeIteratorKind(_ kind: Bytecode.IteratorKind) {
        emitUInt8(kind.rawValue)
    }

    func serializeResumeKind(_ kind: Bytecode.ResumeKind) {
        emitUInt8(kind.rawValue)
    }

    func serializeOptionalReg(_ reg: Bytecode.Reg?) {
        guard let reg = reg else {
            emitUInt8(0)
            return
        }
        emitUInt8(1)
        serializeReg(reg)
    }

    func serializeOptionalProfileSlot(_ slot: Bytecode.ProfileSlot?) {
        guard let slot = slot else {
            emitUInt8(0)
            return
        }
        emitUInt8(1)
        serializeProfileID(slot)
    }

    func serializeOptionalICSlot(_ slot: Bytecode.ICSlot?) {
        guard let slot = slot else {
            emitUInt8(0)
            return
        }
        emitUInt8(1)
        serializeICSlot(slot)
    }

    func serializeOptionalCallSlot(_ slot: Bytecode.CallSlot?) {
        guard let slot = slot else {
            emitUInt8(0)
            return
        }
        emitUInt8(1)
        serializeCallSlot(slot)
    }
}
