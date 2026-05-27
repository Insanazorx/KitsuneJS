enum Terminator {
    case jump(BlockID: Int)
    case conditionalJump(condition: Bytecode, trueBlockId: Int, falseBlockId: Int)
    case `return`(Bytecode.Reg?)
    case `throw`
    case halt
}

extension Terminator: CustomStringConvertible {
    var description: String {
        switch self {
        case .jump(let blockId):
            return "jump #bb[\(blockId)]"
        case .conditionalJump(let condition, let trueBlockId, let falseBlockId):
            return "jumpIf #c{\(condition)} #bbtrue[\(trueBlockId)] #bbfalse[\(falseBlockId)]"
        case .return(let reg):
            if let reg = reg {
                return "return r\(reg.rawValue)"
            } else {
                return "returnUndefined"
            }
        case .throw:
            return "throw"
        case .halt:
            return "halt"
        }
    }
}


final class BasicBlock {
    let id: Int
    var instructions: [Bytecode] = []
    var terminator: Terminator?
    var isSyntheticContinuation: Bool = false
    
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
