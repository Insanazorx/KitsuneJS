//AI generated

import Foundation

extension Serializer {

    func decodeAndRenderDescription() -> String {
        var lines: [String] = []
        let bytes = SerializedBytecode

        func hexByte(_ byte: UInt8) -> String {
            String(format: "%02X", byte)
        }

        func hexBytes(_ slice: ArraySlice<UInt8>) -> String {
            slice.map { hexByte($0) }.joined(separator: " ")
        }

        func hexBytes(_ bytes: [UInt8]) -> String {
            bytes.map { hexByte($0) }.joined(separator: " ")
        }

        func escapedString(_ string: String) -> String {
            string
                .replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "\n", with: "\\n")
                .replacingOccurrences(of: "\r", with: "\\r")
                .replacingOccurrences(of: "\t", with: "\\t")
        }

        func offsetLabel(_ offset: Int) -> String {
            guard offset >= 0 else { return "0x????????" }
            return String(format: "0x%08X", offset)
        }

        func readUInt32(at offset: Int) -> UInt32? {
            guard offset >= 0, offset + 4 <= bytes.count else { return nil }
            return UInt32(bytes[offset])
                | (UInt32(bytes[offset + 1]) << 8)
                | (UInt32(bytes[offset + 2]) << 16)
                | (UInt32(bytes[offset + 3]) << 24)
        }

        func readUInt16(at offset: Int) -> UInt16? {
            guard offset >= 0, offset + 2 <= bytes.count else { return nil }
            return UInt16(bytes[offset])
                | (UInt16(bytes[offset + 1]) << 8)
        }

        func magicAnnotation(for chunk: [UInt8]) -> String? {
            let upper = hexBytes(chunk).replacingOccurrences(of: " ", with: "")

            switch upper {
            case "DEADBEEFCAFEBABEFEEDFACE00010000":
                return "MAGIC BYTES"
            case "FFFFFFFFCAFEBABEDEADBEEFFFFFFFFF":
                return "MAGIC BYTES"
            case "FACEFACE":
                return "MAGIC BYTES"
            case "C0DEB10C":
                return "CODEBLOCK CONSTANT POOL"
            case "DEADBEEF":
                return "MAGIC BYTES"
            case "CAFEBABE":
                return "MAGIC BYTES"
            case "FEEDFACE":
                return "MAGIC BYTES"
            default:
                if upper.contains("DEADBEEF") || upper.contains("CAFEBABE") || upper.contains("FEEDFACE") || upper.contains("FACEFACE") {
                    return "MAGIC BYTES"
                }
                return nil
            }
        }

        func renderRawLine(offset: Int, label: String, count: Int) {
            guard offset >= 0 else {
                lines.append("\(offsetLabel(offset))  \(label): <invalid offset>")
                return
            }

            guard offset < bytes.count else {
                lines.append("\(offsetLabel(offset))  \(label): <out of range>")
                return
            }
            let end = min(offset + count, bytes.count)
            let chunk = Array(bytes[offset..<end])
            let truncated = end - offset < count ? " <truncated>" : ""
            if let annotation = magicAnnotation(for: chunk) {
                lines.append("\(offsetLabel(offset))  \(label): \(hexBytes(chunk)) => \(annotation)\(truncated)")
            } else {
                lines.append("\(offsetLabel(offset))  \(label): \(hexBytes(chunk))\(truncated)")
            }
        }

        func renderSectionSeparator(at offset: Int, name: String) {
            renderRawLine(offset: offset, label: name, count: 16)
        }

        func opcodeName(_ raw: UInt8) -> String {
            guard let opcode = Opcode(rawValue: raw) else {
                return "unknownOpcode(0x\(hexByte(raw)))"
            }
            return String(describing: opcode)
        }

        func opcodeAnnotation(_ raw: UInt8) -> String {
            guard let opcode = Opcode(rawValue: raw) else {
                return ""
            }

            switch opcode {
            case .jump,
                 .jumpIfTrue,
                 .jumpIfFalse,
                 .jumpIfNull,
                 .jumpIfUndefined,
                 .jumpIfNullish,
                 .jumpIfNotNullish,
                 .jumpIfEmpty,
                 .jumpIfResumeKind,
                 .returnValue,
                 .returnUndefined,
                 .throwValue,
                 .rethrow,
                 .halt,
                 .unreachable:
                return " [terminator]"

            default:
                return ""
            }
        }

        func instructionLength(at pc: Int) -> Int {
            guard pc < bytes.count else { return 0 }
            let opcodeRaw = bytes[pc]
            guard let opcode = Opcode(rawValue: opcodeRaw) else {
                return 1
            }

            func optionalPayloadSize(at tagOffset: Int) -> Int {
                guard tagOffset < bytes.count else { return 1 }
                return bytes[tagOffset] == 0 ? 1 : 3
            }

            switch opcode {
            case .nop, .debugDumpScope, .unreachable, .halt,
                 .enterGlobal, .enterFunction,
                 .popLexicalEnvironment,
                 .returnUndefined,
                 .rethrow,
                 .clearException,
                 .generatorEnter,
                 .checkStack:
                return 1

            case .coverageMark:
                return 1 + 4

            case .debugTrap:
                return 1 + 2

            case .debugLog,
                 .debugDumpIC,
                 .clearReg,
                 .loadThis,
                 .loadNewTarget,
                 .loadSuperConstructor,
                 .loadUndefined,
                 .loadNull,
                 .loadTrue,
                 .loadFalse,
                 .loadEmpty,
                 .newObject,
                 .getImportMeta,
                 .createPromise,
                 .getResumeValue,
                 .getResumeKind,
                 .returnValue,
                 .throwValue,
                 .getException,
                 .pushLexicalEnvironment,
                 .asyncEnter,
                 .generatorReturn,
                 .generatorThrow,
                 .asyncGeneratorReturn,
                 .asyncGeneratorThrow,
                 .enqueueMicrotask:
                return 1 + 2

            case .move,
                 .swap,
                 .newObjectWithProto,
                 .setHomeObject,
                 .getArgument,
                 .putArgument,
                 .getLocal,
                 .putLocal,
                 .initLocal,
                 .getModuleVariable,
                 .putModuleVariable,
                 .isCallable,
                 .isConstructor,
                 .voidOp,
                 .logicalNot,
                 .profileValue,
                 .profileType,
                 .profileBranch,
                 .profileCall,
                 .fulfillPromise,
                 .rejectPromise,
                 .promiseResolve:
                return 1 + 2 + 2

            case .loadInt32:
                return 1 + 2 + 4

            case .loadDouble,
                 .loadString,
                 .loadBigInt,
                 .loadSymbol,
                 .loadConst,
                 .newObjectLiteral,
                 .newArrayLiteral,
                 .newRegExp,
                 .switchInt,
                 .switchString,
                 .createFunction,
                 .createGeneratorObject,
                 .createAsyncGeneratorObject:
                return 1 + 2 + 4

            case .newArray,
                 .newArrayWithSpread:
                return 1 + 2 + 2 + 2

            case .newArrayWithSize:
                return 1 + 2 + 2

            case .createClosure,
                 .createArrowClosure,
                 .createGeneratorClosure,
                 .createAsyncClosure:
                return 1 + 2 + 4 + 2

            case .createClass:
                return 1 + 2 + 4 + optionalPayloadSize(at: pc + 1 + 2 + 4) + 4

            case .checkTDZLocal,
                 .enterCatch,
                 .enterFinally,
                 .asyncResumePoint,
                 .resumePoint:
                return 1 + 2

            case .createLexicalEnvironment:
                return 1 + 2 + 2

            case .getContext:
                return 1 + 2 + 1 + 2

            case .putContext:
                return 1 + 1 + 2 + 2

            case .checkTDZContext:
                return 1 + 1 + 2

            case .materializeScope:
                return 1 + 2 + 1

            case .resolveName:
                return 1 + 2 + 4 + optionalPayloadSize(at: pc + 1 + 2 + 4)

            case .getGlobalLexical,
                 .typeofGlobal,
                 .putGlobalLexical,
                 .getGlobalVar,
                 .putGlobalVar:
                return 1 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2)

            case .initGlobalLexical,
                 .initGlobalVar,
                 .deleteGlobal:
                return 1 + 2 + 2

            case .getGlobalProperty:
                return 1 + 2 + 4 + optionalPayloadSize(at: pc + 1 + 2 + 4)

            case .putGlobalProperty:
                return 1 + 4 + 2 + optionalPayloadSize(at: pc + 1 + 4 + 2)

            case .getById:
                return 1 + 2 + 2 + 4 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 4)

            case .putById:
                return 1 + 2 + 4 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 4 + 2)

            case .getByVal,
                 .putByVal:
                return 1 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2)

            case .getByIdWithThis,
                 .getMethodById,
                 .getSuperById:
                return 1 + 2 + 2 + 2 + 4 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2 + 4)

            case .getByValWithThis,
                 .getMethodByVal,
                 .getSuperByVal,
                 .putSuperByVal:
                return 1 + 2 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2 + 2)

            case .putSuperById:
                return 1 + 2 + 2 + 4 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 4 + 2)

            case .defineOwnById,
                 .defineClassMethod,
                 .defineInstanceField,
                 .defineStaticField:
                return 1 + 2 + 4 + 2 + 1

            case .defineOwnByVal:
                return 1 + 2 + 2 + 2 + 1

            case .deleteById,
                 .inById:
                return 1 + 2 + 2 + 4 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 4)

            case .deleteByVal,
                 .hasProperty,
                 .inByVal:
                return 1 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2)

            case .getPrivateById,
                 .hasPrivateById:
                return 1 + 2 + 2 + 4

            case .putPrivateById,
                 .definePrivateById:
                return 1 + 2 + 4 + 2

            case .getLength,
                 .putLength,
                 .arrayPop:
                return 1 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2)

            case .getByIndex,
                 .putByIndex:
                return 1 + 2 + 4 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 4 + 2)

            case .arrayPush:
                return 1 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2)

            case .toNumber,
                 .toNumeric,
                 .toString,
                 .toObject,
                 .toBoolean,
                 .toPropertyKey,
                 .typeofValue,
                 .bitNot,
                 .negate,
                 .increment,
                 .decrement:
                return 1 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2)

            case .add,
                 .sub,
                 .mul,
                 .div,
                 .mod,
                 .pow,
                 .bitAnd,
                 .bitOr,
                 .bitXor,
                 .leftShift,
                 .rightShift,
                 .unsignedRightShift,
                 .equal,
                 .notEqual,
                 .strictEqual,
                 .strictNotEqual,
                 .lessThan,
                 .lessThanOrEqual,
                 .greaterThan,
                 .greaterThanOrEqual,
                 .sameValue,
                 .sameValueZero,
                 .instanceOf,
                 .inOperator:
                return 1 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2)

            case .call,
                 .callEval:
                return 1 + 2 + 2 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2 + 2 + 2)

            case .callDirect:
                return 1 + 2 + 4 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 4 + 2 + 2 + 2)

            case .callVarargs,
                 .tailCall:
                return 1 + 2 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2 + 2)

            case .construct,
                 .superConstruct:
                return 1 + 2 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2 + 2)

            case .constructVarargs,
                 .superConstructVarargs:
                return 1 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2)

            case .jump:
                return 1 + 1 + 4

            case .jumpIfTrue,
                 .jumpIfFalse,
                 .jumpIfNull,
                 .jumpIfUndefined,
                 .jumpIfNullish,
                 .jumpIfNotNullish,
                 .jumpIfEmpty:
                return 1 + 2 + 1 + 4

            case .getIterator:
                return 1 + 2 + 2 + 1 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 1)

            case .iteratorNext,
                 .iteratorValue,
                 .iteratorDone:
                return 1 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2)

            case .iteratorClose:
                return 1 + 2 + optionalPayloadSize(at: pc + 1 + 2)

            case .createMethod:
                return 1 + 2 + 4 + 2

            case .promiseThen:
                return 1 + 2 + 2 + 2 + optionalPayloadSize(at: pc + 1 + 2 + 2 + 2)

            case .awaitSuspend:
                return 1 + 2 + 2 + 2

            case .jumpIfResumeKind:
                return 1 + 1 + 1 + 4

            case .generatorSuspend,
                 .asyncGeneratorSuspend,
                 .yieldStar:
                return 1 + 2 + 2 + 2

            case .checkStructure:
                return 1 + 2 + 2 + 1 + 4

            case .checkCell,
                 .checkNumber,
                 .checkInt32,
                 .checkString,
                 .checkObject,
                 .checkArray,
                 .checkInt32Index:
                return 1 + 2 + 1 + 4

            case .runtimeCall,
                 .intrinsicCall:
                return 1 + 2 + 2 + 2 + 2
            }
        }

        func renderBasicBlocks(start: Int, end: Int, linePrefix: String) {
            guard start >= 0, start <= bytes.count else {
                lines.append("\(linePrefix)\(offsetLabel(start)) <invalid code block start>")
                return
            }

            guard end >= start, end <= bytes.count else {
                lines.append("\(linePrefix)\(offsetLabel(end)) <invalid code block end>")
                return
            }

            let sortedBlockOffsets = basicBlockOffsets
                .map { Int($0) }
                .filter { $0 >= start && $0 < end }
                .sorted()
                .reduce(into: [Int]()) { uniqueOffsets, offset in
                    if uniqueOffsets.last != offset {
                        uniqueOffsets.append(offset)
                    }
                }

            let blockOffsets: [Int]
            if sortedBlockOffsets.isEmpty && start < end {
                lines.append("\(linePrefix)\(offsetLabel(start)) <missing basicBlockOffsets metadata; decoding range as BasicBlock #0>")
                blockOffsets = [start]
            } else {
                blockOffsets = sortedBlockOffsets
            }

            guard !blockOffsets.isEmpty else {
                lines.append("\(linePrefix)<empty>")
                return
            }

            for (blockIndex, blockStart) in blockOffsets.enumerated() {
                let blockEnd: Int
                if blockIndex + 1 < blockOffsets.count {
                    blockEnd = min(blockOffsets[blockIndex + 1], end)
                } else {
                    blockEnd = end
                }

                lines.append("\(linePrefix)\(offsetLabel(blockStart)) BasicBlock #\(blockIndex)")

                var pc = blockStart
                while pc < blockEnd {
                    guard pc >= 0, pc < bytes.count else {
                        lines.append("\(linePrefix)  \(offsetLabel(pc)) <out of range>")
                        break
                    }

                    let expectedLength = max(1, instructionLength(at: pc))
                    let availableLength = min(expectedLength, blockEnd - pc, bytes.count - pc)
                    let length = max(1, availableLength)
                    let chunk = bytes[pc..<pc + length]
                    let op = bytes.indices.contains(pc) ? opcodeName(bytes[pc]) : "<out of range>"
                    let annotation = bytes.indices.contains(pc) ? opcodeAnnotation(bytes[pc]) : ""
                    let truncated = length < expectedLength ? " <truncated expectedLen=\(expectedLength)>" : ""
                    lines.append("\(linePrefix)  \(offsetLabel(pc)) \(op)\(annotation) [len=\(length)] \(hexBytes(chunk))\(truncated)")
                    pc += length
                }
            }
        }

        struct FunctionTableEntry {
            let functionId: UInt32
            let entryOffset: Int
            let recordOffset: Int
        }

        struct ConstantEntry {
            let index: UInt32
            let value: String
            let valueOffset: Int
        }

        func parseFunctionTableEntries(start: Int, end: Int) -> [FunctionTableEntry] {
            guard start >= 0, end >= start, end <= bytes.count else {
                return []
            }

            var entries: [FunctionTableEntry] = []
            var pc = start
            while pc + 8 <= end {
                let functionId = readUInt32(at: pc) ?? 0
                let entryOffset = readUInt32(at: pc + 4).map { Int($0) } ?? 0
                entries.append(FunctionTableEntry(
                    functionId: functionId,
                    entryOffset: entryOffset,
                    recordOffset: pc
                ))
                pc += 8
            }

            return entries
        }

        func renderFunctionTable(start: Int, end: Int) {
            lines.append("")
            lines.append("[FUNCTION TABLE]")

            guard start >= 0, start <= bytes.count else {
                lines.append("\(offsetLabel(start))  <invalid function table start>")
                return
            }

            guard end >= start, end <= bytes.count else {
                lines.append("\(offsetLabel(end))  <invalid function table end>")
                return
            }

            let entries = parseFunctionTableEntries(start: start, end: end)
            for (row, entry) in entries.enumerated() {
                lines.append("\(offsetLabel(entry.recordOffset))  entry #\(row): functionId=\(entry.functionId), entryOffset=\(offsetLabel(entry.entryOffset)), bytes=\(hexBytes(bytes[entry.recordOffset..<entry.recordOffset + 8]))")
            }

            let trailingOffset = start + entries.count * 8
            if entries.isEmpty && trailingOffset == end {
                lines.append("\(offsetLabel(start))  <empty function table>")
            }

            if trailingOffset < end {
                lines.append("\(offsetLabel(trailingOffset))  trailing bytes: \(hexBytes(bytes[trailingOffset..<end]))")
            }
        }

        func parseConstantPools(start: Int, end: Int) -> [UInt32: [ConstantEntry]] {
            guard start >= 0, end >= start, start + 4 <= end, end <= bytes.count else {
                return [:]
            }

            let codeBlockPoolCount = readUInt32(at: start) ?? 0
            var pools: [UInt32: [ConstantEntry]] = [:]
            var pc = start + 4

            for _ in 0..<Int(codeBlockPoolCount) {
                guard pc + 12 <= end else {
                    break
                }

                pc += 4 // CodeBlock constant-pool marker.
                let codeBlockId = readUInt32(at: pc) ?? 0
                pc += 4

                let constantsCount = readUInt32(at: pc) ?? 0
                pc += 4

                var entries: [ConstantEntry] = []
                for _ in 0..<Int(constantsCount) {
                    guard pc + 8 <= end else {
                        break
                    }

                    pc += 4 // Constant entry marker.
                    let cpIndex = readUInt32(at: pc) ?? 0
                    pc += 4

                    let stringStart = pc
                    while pc < end && bytes[pc] != 0 {
                        pc += 1
                    }

                    let stringBytes = bytes[stringStart..<pc]
                    let constant = String(bytes: stringBytes, encoding: .utf8) ?? "<invalid utf8>"
                    entries.append(ConstantEntry(
                        index: cpIndex,
                        value: constant,
                        valueOffset: stringStart
                    ))

                    if pc < end && bytes[pc] == 0 {
                        pc += 1
                    }
                }

                pools[codeBlockId] = entries
            }

            return pools
        }

        func renderConstantPool(_ entries: [ConstantEntry], linePrefix: String) {
            guard !entries.isEmpty else {
                lines.append("\(linePrefix)<empty>")
                return
            }

            for entry in entries.sorted(by: { $0.index < $1.index }) {
                lines.append("\(linePrefix)cp[\(entry.index)] @ \(offsetLabel(entry.valueOffset)) = \"\(escapedString(entry.value))\"")
            }
        }

        func renderCodeBlocks(
            codeStart: Int,
            codeEnd: Int,
            functionEntries: [FunctionTableEntry],
            constantPools: [UInt32: [ConstantEntry]]
        ) {
            lines.append("")
            lines.append("[CODE BLOCKS]")

            guard codeStart >= 0, codeEnd >= codeStart, codeEnd <= bytes.count else {
                lines.append("\(offsetLabel(codeStart))  <invalid code block range>")
                return
            }

            struct CodeBlockRenderInfo {
                let name: String
                let constantPoolId: UInt32
                let start: Int
                let end: Int
            }

            let validFunctionEntries = functionEntries
                .filter { $0.entryOffset >= codeStart && $0.entryOffset <= codeEnd }
                .sorted {
                    if $0.entryOffset == $1.entryOffset {
                        return $0.functionId < $1.functionId
                    }
                    return $0.entryOffset < $1.entryOffset
                }

            let globalEnd = validFunctionEntries.first?.entryOffset ?? codeEnd
            var codeBlocks: [CodeBlockRenderInfo] = [
                CodeBlockRenderInfo(
                    name: "global",
                    constantPoolId: UInt32.max,
                    start: codeStart,
                    end: globalEnd
                )
            ]

            for (index, functionEntry) in validFunctionEntries.enumerated() {
                let end = index + 1 < validFunctionEntries.count
                    ? validFunctionEntries[index + 1].entryOffset
                    : codeEnd

                codeBlocks.append(CodeBlockRenderInfo(
                    name: "function \(functionEntry.functionId)",
                    constantPoolId: functionEntry.functionId,
                    start: functionEntry.entryOffset,
                    end: end
                ))
            }

            for (index, codeBlock) in codeBlocks.enumerated() {
                lines.append("")
                lines.append("CODE BLOCK #\(index) (\(codeBlock.name)) [\(offsetLabel(codeBlock.start)), \(offsetLabel(codeBlock.end)))")
                lines.append("|->[BasicBlocks]")
                renderBasicBlocks(start: codeBlock.start, end: codeBlock.end, linePrefix: "|  ")
                lines.append("|->[ConstantPool]")
                renderConstantPool(constantPools[codeBlock.constantPoolId] ?? [], linePrefix: "|  ")
            }
        }

        lines.append("Serialized Bytecode Decode")
        lines.append("totalBytes=\(bytes.count)")

        lines.append("")
        lines.append("[HEADER]")
        renderRawLine(offset: 0, label: "magic+version", count: 16)

        let basicBlocksOffset = readUInt32(at: 16).map { Int($0) }
        let functionTableOffset = readUInt32(at: 20).map { Int($0) }
        let constantsPoolOffset = readUInt32(at: 24).map { Int($0) }

        func renderSectionTableEntry(offset: Int, name: String, value: Int?) {
            guard let value = value else {
                lines.append("\(offsetLabel(offset))  \(name) = <truncated>")
                return
            }

            lines.append("\(offsetLabel(offset))  \(name) = \(offsetLabel(value))")
        }

        lines.append("")
        lines.append("[SECTION TABLE]")
        renderSectionTableEntry(offset: 16, name: "basicBlocksOffset", value: basicBlocksOffset)
        renderSectionTableEntry(offset: 20, name: "functionTableOffset", value: functionTableOffset)
        renderSectionTableEntry(offset: 24, name: "constantsPoolOffset", value: constantsPoolOffset)

        let sectionSeparatorBytes: [UInt8] = [
            0xFF, 0xFF, 0xFF, 0xFF,
            0xCA, 0xFE, 0xBA, 0xBE,
            0xDE, 0xAD, 0xBE, 0xEF,
            0xFF, 0xFF, 0xFF, 0xFF
        ]

        func bytesMatch(at offset: Int, expected: [UInt8]) -> Bool? {
            guard offset >= 0, offset + expected.count <= bytes.count else {
                return nil
            }

            return Array(bytes[offset..<offset + expected.count]) == expected
        }

        var warnings: [String] = []

        func warn(_ message: String) {
            warnings.append(message)
        }

        let expectedCodeOffset = 28 + sectionSeparatorBytes.count
        if bytes.count < 16 {
            warn("header is truncated; expected 16 bytes")
        }
        if bytes.count < 28 {
            warn("section table is truncated; expected offsets at 0x00000010, 0x00000014, 0x00000018")
        }
        if let basicBlocksOffset, basicBlocksOffset != expectedCodeOffset {
            warn("basicBlocksOffset is \(offsetLabel(basicBlocksOffset)); expected \(offsetLabel(expectedCodeOffset)) after header + first separator")
        }
        if let basicBlocksOffset, basicBlocksOffset > bytes.count {
            warn("basicBlocksOffset is out of range")
        }
        if let functionTableOffset, functionTableOffset > bytes.count {
            warn("functionTableOffset is out of range")
        }
        if let constantsPoolOffset, constantsPoolOffset > bytes.count {
            warn("constantsPoolOffset is out of range")
        }
        if let basicBlocksOffset, let functionTableOffset, functionTableOffset < basicBlocksOffset {
            warn("functionTableOffset is before basicBlocksOffset")
        }
        if let functionTableOffset, let constantsPoolOffset, constantsPoolOffset < functionTableOffset {
            warn("constantsPoolOffset is before functionTableOffset")
        }
        if bytesMatch(at: 28, expected: sectionSeparatorBytes) == false {
            warn("separator.beforeCode does not match expected section separator bytes")
        }

        let firstSeparatorOffset = 28
        let separatorBeforeFunctionTable = functionTableOffset.map { $0 - sectionSeparatorBytes.count }
        let separatorBeforeConstantsPool = constantsPoolOffset.map { $0 - sectionSeparatorBytes.count }
        let constantsPoolEnd = bytes.count

        if let separatorBeforeFunctionTable {
            if separatorBeforeFunctionTable < 0 {
                warn("functionTableOffset is too small to have a preceding 16-byte separator")
            } else if bytesMatch(at: separatorBeforeFunctionTable, expected: sectionSeparatorBytes) == false {
                warn("separator.beforeFunctionTable does not match expected section separator bytes")
            }
        }

        if let separatorBeforeConstantsPool {
            if separatorBeforeConstantsPool < 0 {
                warn("constantsPoolOffset is too small to have a preceding 16-byte separator")
            } else if bytesMatch(at: separatorBeforeConstantsPool, expected: sectionSeparatorBytes) == false {
                warn("separator.beforeConstantPool does not match expected section separator bytes")
            }
        }

        if !warnings.isEmpty {
            lines.append("")
            lines.append("[DECODE WARNINGS]")
            for warning in warnings {
                lines.append("- \(warning)")
            }
        }

        func renderOptionalSectionSeparator(at offset: Int?, name: String) {
            guard let offset = offset else {
                lines.append("0x????????  \(name): <unavailable>")
                return
            }

            renderSectionSeparator(at: offset, name: name)
        }

        lines.append("")
        lines.append("[MAGIC / SECTION SEPARATORS]")
        renderSectionSeparator(at: firstSeparatorOffset, name: "separator.beforeCode")
        renderOptionalSectionSeparator(at: separatorBeforeFunctionTable, name: "separator.beforeFunctionTable")
        renderOptionalSectionSeparator(at: separatorBeforeConstantsPool, name: "separator.beforeConstantPool")

        if let functionTableOffset, let functionTableEnd = separatorBeforeConstantsPool {
            renderFunctionTable(start: functionTableOffset, end: functionTableEnd)
        } else {
            lines.append("")
            lines.append("[FUNCTION TABLE]")
            lines.append("0x????????  <unavailable: missing section offsets>")
        }

        let functionEntries: [FunctionTableEntry] = {
            guard let functionTableOffset, let functionTableEnd = separatorBeforeConstantsPool else {
                return []
            }
            return parseFunctionTableEntries(start: functionTableOffset, end: functionTableEnd)
        }()

        let constantPools: [UInt32: [ConstantEntry]] = {
            guard let constantsPoolOffset else {
                return [:]
            }
            return parseConstantPools(start: constantsPoolOffset, end: constantsPoolEnd)
        }()

        if let basicBlocksOffset, let codeEnd = separatorBeforeFunctionTable {
            renderCodeBlocks(
                codeStart: basicBlocksOffset,
                codeEnd: codeEnd,
                functionEntries: functionEntries,
                constantPools: constantPools
            )
        } else {
            lines.append("")
            lines.append("[CODE BLOCKS]")
            lines.append("0x????????  <unavailable: missing section offsets>")
        }

        return lines.joined(separator: "\n")
    }
}

extension Serializer: CustomStringConvertible {

    var description: String {
        return decodeAndRenderDescription()
    }

}
