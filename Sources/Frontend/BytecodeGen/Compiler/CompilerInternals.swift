extension BytecodeCompiler {
    
    enum LoopContext {
        case forIn(BasicBlock, BasicBlock)
        case forOf(BasicBlock, BasicBlock)
        case forClassic(afterLoopBlock: BasicBlock, testBlock: BasicBlock, label: Int? = nil)
        case whileClassic(afterLoopBlock: BasicBlock, testBlock: BasicBlock, label: Int? = nil)
        case doWhile(afterLoopBlock: BasicBlock, testBlock: BasicBlock, label: Int? = nil)
        case labelled(nodeId: Int)
    }

    enum RefType {
        case local(UInt16)
        case context(UInt8, UInt16)
        case globalVar(UInt16)
        case globalLexical(UInt16)
        case unresolved(Bytecode.CPIndex)
    }

    enum AssignmentTargetInfo {
        case identifier(RefType)
        case namedMember(Bytecode.Reg, Bytecode.CPIndex)
        case computedMember(Bytecode.Reg, Bytecode.Reg)
        case destructuring
        case todo
    }

    enum DestructionPlan {
        case single(AssignmentTargetInfo)
        case array([DestructionPlan])
        case object([Bytecode.CPIndex: DestructionPlan])
        case todo        
    }

    enum PatternBindingPlan {
        case single(SinglePattern)
        case array([PatternBindingPlan])
        case object([Bytecode.CPIndex: PatternBindingPlan])
        case todo
    }
    
    enum SinglePattern {
        case bindingSlot(slot: UInt16, isGlobal: Bool) 
        case undefined
    }

    enum VarDeclKind {
        case `var`
        case `let`
        case `const`
    }

    struct VariableDeclInfo {
        var reg: Bytecode.Reg?
        var slot: UInt16
        var isGlobal: Bool
    }

    enum ExprResult {
        case assignment
        case propertyKey(Bytecode.CPIndex)
        case expr(Bytecode.Reg)
        
        case todo
        
    }

    enum PropertyKeyResult {
        case identifier(Bytecode.CPIndex)
        case computed(Bytecode.Reg)
    }
}