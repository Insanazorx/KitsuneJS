enum Terminator {
    case jump(BlockID: Int)
    case conditionalJump(condition: Bytecode, trueBlockId: Int, falseBlockId: Int)
    case `return`
    case `throw`
}

final class BasicBlock {
    let id: Int
    var instructions: [Bytecode] = []
    var terminator: Terminator?
    
    init(id: Int) {
        self.id = id
    }

}

extension BasicBlock: CustomStringConvertible {
    var description: String {
        let instrs = instructions.map { "  \($0)" }.joined(separator: "\n")
        let termStr: String
        if let term = terminator {
            termStr = "  \(term)"
        } else {
            termStr = "  <no terminator>"
        }
        return "Block \(id):\n\(instrs)\n\(termStr)"
    }
}

