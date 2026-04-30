extension BytecodeCompiler {
    
    enum RefType {
        case lexical(UInt16)
        case context(UInt8, UInt16)
        case global(Bytecode.CPIndex)
        case todo
    }

    enum AssignmentTargetInfo {
        case identifier(RefType)
        case namedMember(Bytecode.Reg, Bytecode.CPIndex)
        case computedMember(Bytecode.Reg, Bytecode.Reg)
        case destructuring
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
        var reg: Bytecode.Reg
        var slot: UInt16
        var isGlobal: Bool
    }

    enum ExprResult {
        case assignment(AssignmentTargetInfo)
        case expr(Bytecode.Reg)
        
        case todo
        
    }
    

}