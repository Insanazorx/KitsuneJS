class CodeBlock {
  var basicBlocks: [BasicBlock] = []
  var constantPool: ConstantsPool = ConstantsPool()

  init() {}

  init(constantPool: ConstantsPool) {
    self.constantPool = constantPool
  }

  func addBasicBlock(_ basicBlock: BasicBlock) {
    basicBlocks.append(basicBlock)
  }
  
  func setConstantPool(_ constantPool: ConstantsPool) {
    self.constantPool = constantPool
  }
}

extension CodeBlock: CustomStringConvertible {
    var description: String {
        let blocksDescription = basicBlocks.map { $0.description }.joined(separator: "\n")
        let constantsDescription = constantPool.description
        return "CodeBlock:\nBasic Blocks:\n\(blocksDescription)\nConstant Pool:\n\(constantsDescription)"
    }
}

class ConstantsPool {
    var pool: [String: UInt32] = [:]
}

extension ConstantsPool: CustomStringConvertible {
    var description: String {
        return pool.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }
}
