struct BytecodeHeader {
    var magic: UInt32

    var instructionSetMajor: UInt16
    var instructionSetMinor: UInt16

    var flags: UInt32

    var fileSize: UInt32
    var headerSize: UInt32

    var sectionCount: UInt16
    var entryFunctionIndex: UInt16
}