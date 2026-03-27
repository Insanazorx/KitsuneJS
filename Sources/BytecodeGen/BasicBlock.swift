final class BasicBlock {
    let id: Int
    var instructions: [Bytecode] = []
    var terminator: Terminator?
    
    init(id: Int) {
        self.id = id
    }

}
    enum Terminator {
        case jump(BlockID: Int)
        case conditionalJump(condition: Bytecode, trueBlockId: Int, falseBlockId: Int)
        case `return`
        case `throw`
    }