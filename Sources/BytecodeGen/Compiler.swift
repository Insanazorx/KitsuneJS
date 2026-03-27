class BytecodeCompiler {

    var compilationUnit: CompilationUnit
    var bytecodeCompilation: [Bytecode] = []
    var currentBlock: BasicBlock 
    var BasicBlocks: [BasicBlock] = []
    var blockCounter: Int = 0
    var regCounter: UInt16 = 0
    var currentNodeId: Int = 0
    var constantsPool: [String: Int] = [:]



    init(compilationUnit: CompilationUnit) {
        self.compilationUnit = compilationUnit
        self.currentBlock = BasicBlock(id: 0)
        self.BasicBlocks.append(self.currentBlock)
    }
}

extension BytecodeCompiler {

    func createCPIndex(for name: String) -> Bytecode.CPIndex {
        let idx = putRecordOnConstantsPool(name)
        return Bytecode.CPIndex(rawValue: UInt32(idx))
    }
    
    func putRecordOnConstantsPool(_ value: String) -> Int {
        if let existingIndex = constantsPool[value] {
            return existingIndex
        } else {
            let newIndex = constantsPool.count
            constantsPool[value] = newIndex
            return newIndex
        }
    }


    func allocNodeId() -> Int {
        currentNodeId += 1
        return currentNodeId
    }

    func emit(_ bytecode: Bytecode) {
        currentBlock.instructions.append(bytecode)
    }

    func emitTerminator(_ terminator: Terminator) {
        currentBlock.terminator = terminator
    }

    func allocBasicBlock() -> BasicBlock {
        blockCounter += 1
        let newBlock = BasicBlock(id: blockCounter)
        BasicBlocks.append(newBlock)
        return newBlock
    }

    func switchBasicBlock(_ newBlock: BasicBlock) {
        currentBlock = newBlock
    }

    func allocRegister() -> Bytecode.Reg {
        regCounter += 1
        return Bytecode.Reg(rawValue: regCounter)
    }
}



extension BytecodeCompiler {
    func compile() {
        switch compilationUnit.ast {
            case .program(let program ):
                walkProgram(program)
            default:
                fatalError("Expected a program AST node")
        }
    }

    func walkProgram(_ program: Program) {
    let id = allocNodeId()
            if case .program(let body) = program {
                for statement in body {
                    walkStatement(statement)
                }
            }
        
    }
    //MARK: Statements
    func walkStatement(_ stmt: Statement) {
        let id = allocNodeId()
        switch stmt {
            case .expressionStatement(let expression):
                walkExpression(expression)
            
            case .declarationStatement(let declaration):
                walkDeclaration(declaration)

            case .block(let statements):
                for statement in statements {
                    if let statement = statement {
                        walkStatement(statement)
                    }
                }
                
            case .ifStatement(let test,let consequent,let alternate):
                compileIfStatement(currentNodeId: id, test, consequent, alternate)
            case .whileStatement(let test,let body):
                compileWhileStatement(currentNodeId: id, test, body)
            case .doWhileStatement(let body,let test):
                compileDoWhileStatement(currentNodeId: id, body, test)
            case .forStatement(let initial, let test, let update, let body):
                compileForStatement(currentNodeId: id, initial, test, update, body)
            case .forInStatement(let left,let right, let body):
                compileForInStatement(currentNodeId: id, left, right, body)
            case .forOfStatement(let left,let right, let body):
                compileForOfStatement(currentNodeId: id, left, right, body)
            case .forAwaitOfStatement(let left, let right, let body):
                compileForAwaitOfStatement(currentNodeId: id, left, right, body)
            case .returnStatement(let argument):
                compileReturnStatement(currentNodeId: id, argument)
            case .breakStatement(let label):
                compileBreakStatement(currentNodeId: id, label)
            case .continueStatement(let label):
                compileContinueStatement(currentNodeId: id, label)
            case .throwStatement(let argument):
                compileThrowStatement(currentNodeId: id, argument)
            case .tryStatement(let block, let catchDeclarations, handler: let handler, finalizer: let finalizer):
                compileTryStatement(currentNodeId: id, block, catchDeclarations, handler, finalizer)
            case .switchStatement(let discriminant,let cases):
                compileSwitchStatement(currentNodeId: id, discriminant, cases)
            case .labelledStatement(let label, let body):
                compileLabelledStatement(currentNodeId: id, label, body)
            case .empty:
                break
        }
    }

    func compileIfStatement(currentNodeId: Int, _ test: Expression, _ consequent: Statement, _ alternate: Statement?) {
        
    }
    func compileWhileStatement(currentNodeId: Int, _ test: Expression, _ body: Statement) {
        
    }
    func compileDoWhileStatement(currentNodeId: Int, _ body: Statement, _ test: Expression) {

    }

    func compileForStatement(currentNodeId: Int, _ initial: ForInit?, _ test: Expression?, _ update: Expression?, _ body: Statement) {
        
    }

    func compileForInStatement(currentNodeId: Int, _ left: ForEachLeft, _ right: Expression, _ body: Statement) {
        
    }

    func compileForOfStatement(currentNodeId: Int, _ left: ForEachLeft, _ right: Expression, _ body: Statement) {
        
    }

    func compileForAwaitOfStatement(currentNodeId: Int, _ left: ForEachLeft, _ right: Expression, _ body: Statement) {
        
    }

    func compileReturnStatement(currentNodeId: Int, _ argument: Expression?) {
        
    }

    func compileBreakStatement(currentNodeId: Int, _ label: Expression?) {
        
    }

    func compileContinueStatement(currentNodeId: Int, _ label: Expression?) {
        
    }

    func compileThrowStatement(currentNodeId: Int, _ argument: Expression) {
        
    }
    func compileTryStatement(currentNodeId: Int, _ block: Statement, _ catchDeclarations: [Pattern]?, _ handler: Statement?, _ finalizer: Statement?) {
        
    }
    func compileSwitchStatement(currentNodeId: Int, _ discriminant: Expression, _ cases: [CaseStatement]) {
        
    }
    func compileLabelledStatement(currentNodeId: Int, _ label: Expression, _ body: Statement) {
        
    }
    //MARK: Expressions
    func walkExpression(_ expr: Expression) {
        let id = allocNodeId()
        switch expr {
            case .privateIdentifier:
                fallthrough
            case .new:
                fallthrough
            case .yield:
                fallthrough
            case .await:
                fallthrough
            case .unary:
                fallthrough
            case .this:
                fallthrough
            case .identifier:
                fallthrough
            case .literal:
                fallthrough
            case .arrowFunction:
                fallthrough
            case .parenthesized:
                fallthrough
            case .arrayLiteral:
                fallthrough
            case .objectLiteral:
                fallthrough
            case .functionExpression:
                fallthrough
            case .classExpression:
                compileNudExpression(currentNodeId: id, expr)

            case .binary(let left, let op, let right):
                compileBinaryExpression(currentNodeId: id, left, op, right)
            case .assignment(let target, let op, let value):
                compileAssignmentExpression(currentNodeId: id, target, op, value)
            case .call(let callee, let arguments):
                compileCallExpression(currentNodeId: id, callee, arguments)
            case .member(let object, let property):
                compileMemberExpression(currentNodeId: id, object, property)
            case .computedMember(let object, let propertyExpr):
                compileComputedMemberExpression(currentNodeId: id, object, propertyExpr)
            case .sequence(let expressions):
                compileSequenceExpression(currentNodeId: id, expressions)

        }
    }


    
    
    
    
    func compileBinaryExpression(currentNodeId: Int,_ left: Expression, _ op: TokenType, _ right: Expression) {}
    func compileMemberExpression(currentNodeId: Int, _ object: Expression, _ property: Expression) {}
    func compileComputedMemberExpression(currentNodeId: Int, _ object: Expression, _ propertyExpr: Expression) {}
    func compileSequenceExpression(currentNodeId: Int, _ exprs: [Expression]) {}
    func compileCallExpression(currentNodeId: Int, _ callee: Expression, _ arguments: [Expression]) {}
    func compileNudExpression(currentNodeId: Int, _ expr: Expression) {
        switch expr {
            case .identifier(let name):
                let ref = compilationUnit.getBoundRefByNodeId(nodeId: currentNodeId)
                if ref.storageKind == .global {
                    // If there is no binding, it must be a global variable.
                    // We assume that VM will match the global variable,
                    // else it will throw a ReferenceError at runtime.
                    let cpconst = createCPIndex(for: name)

                    // Put "vm->acc" state to global variable index to be used later
                    emit(.ldaGlobal(cpconst))
                    return
                }
                guard let bindingId = ref.bindingId else {
                    fatalError("Expected to find a binding for identifier \(name) in compilation unit, but it was not found and is not a global variable. NodeId: \(currentNodeId)")
                }
                
                let binding = compilationUnit.bindings[bindingId]
                
                guard let slot = binding.slot else {
                    fatalError("Expected binding for identifier \(name) to have an allocated slot by slotAllocator in scope analysis, but it was nil. NodeId: \(currentNodeId)")
                }

                let storageKind = ref.storageKind
                switch storageKind {
                    case .lexical:
                        emit(.ldaLexical(UInt16(slot)))
                    case .context:
                        let depth = ref.capturingDepth
                        emit(.ldaContextSlot( UInt8(depth), UInt16(slot)))
                    default:
                        fatalError("Invalid storage kind for identifier \(name). NodeId: \(currentNodeId)")

                }

                
                
                
                break
            case .literal(let lit):
                switch lit {
                    case .string(let str):
                        let cpIndex = createCPIndex(for: str)
                        emit(.ldaSmi32(Int32(cpIndex.rawValue)))
                    case .int(let num):
                        emit(.ldaSmi32(Int32(num)))
                    case .bool(let bool):
                        emit(bool ? .ldaTrue : .ldaFalse)
                    case .null:
                        emit(.ldaNull)
                    case .undefined:
                        emit(.ldaUndef)
                    case .float(let num):
                        break //TODO
                }
                break
            default:
                fatalError("Not implemented yet")
        }
    }
    func compileAssignmentExpression(currentNodeId: Int, _ target: AssignmentTarget, _ op: TokenType, _ value: Expression) {
        
        walkAssignmentTarget(target)                            // acc = [31:0] slot or cp index | [63:32] storage kind  
        let storingInfoReg = allocRegister()      // save storing information elsewhere
        emit(.star(storingInfoReg))   

        walkExpression(value)
    }

    func walkAssignmentTarget(_ target: AssignmentTarget) {
        let id = allocNodeId()
        switch target {
            case .identifier(let name):
                compileIdentifierAssignmentTarget(currentNodeId: id, name)

            case .member(let object, let property):
                compileMemberAssignmentTarget(currentNodeId: id, object, property)
                
            case .computedMember(let object, let propertyExpr):
                compileComputedMemberAssignmentTarget(currentNodeId: id, object, propertyExpr)
                
            case .destructuring(let pattern):
                // emit bytecode to compute the destructuring assignment and load it into the accumulator.
                break
        }
    }


    //ABI: acc = slot (or) cp index | storageKind << 32 

    func compileIdentifierAssignmentTarget(currentNodeId: Int, _ name: String) {

        let ref=compilationUnit.getBoundRefByNodeId(nodeId: currentNodeId)

        var mode = 0
        switch ref.kind {
            case .Write:
                mode = 1
            case .ForInOf:
                mode = 2
            default:
                fatalError("Invalid assignment target: identifier \(name) is not writable. NodeId: \(currentNodeId)")
        }

        var binding: Binding
        if let bindingId = ref.bindingId {
            binding = compilationUnit.bindings[bindingId]
        
        } else {

            // If there is no binding, it must be a global variable.
            // We assume that VM will match the global variable,
            // else it will throw a ReferenceError at runtime.
            let cpidx = putRecordOnConstantsPool(name)

            // Put "vm->acc" state to global variable index to be used later
            emit(.ldaSmi32(Int32(cpidx)))        
            return
        }

        if mode == 1 {
            guard let slot = binding.slot else{
                fatalError("Expected binding for identifier \(name) to have an allocated slot by slotAllocator in scope analysis, but it was nil. NodeId: \(currentNodeId)")
            }
            let storageKind = ref.storageKind
                    
            // Load accumulator with the value from the slot and storage kind
            // so that VM can determine slot and storage kind to perform the write operation
            // in the caller compile function with "staLexical", "staContext" or "staGlobal" bytecode.

            // 0x0000 0000 0000 0000  0000 0000 0000 0000
            // [31:0] slot index for lexical/context variables or cp index for global variables
            // [63:32] storage kind (0 = unknown, 1 = lexical, 2 = context, 4 = global)
                    
            var storageKindBits: Int = 0
            switch storageKind {
                case .lexical:
                    storageKindBits = 1
                case .context:
                    storageKindBits = 2
                case .global:
                    storageKindBits = 4
                default:
                    fatalError("Invalid storage kind for identifier \(name). NodeId: \(currentNodeId)")
                }
                    
                emit(.ldaSmi8(Int8(32)))
                    
                let shlAmountReg = allocRegister()
                emit(.star(shlAmountReg))

                emit(.ldaSmi32(Int32(storageKindBits)))
                emit(.shl(shlAmountReg))
                
                if storageKindBits == 4 {
                    guard let cpidx = constantsPool[name] else {
                        fatalError("VERIFY_NOT_REACHED: Expected to find constant pool index for global variable \(name), but it was not found. NodeId: \(currentNodeId) |---> NOTE: This case must have been handled by now!")
                    }
                    emit(.ldaSmi32(Int32(cpidx)))
                    
                    return
                }
                emit(.ldaSmi32(Int32(slot)))
                    
            
        } else if mode == 2 {
            fatalError("TODO: Implement for-in/of assignment target handling for identifier \(name). NodeId: \(currentNodeId)")
        }
        
    }



    func compileMemberAssignmentTarget(currentNodeId: Int, _ object: Expression, _ property: Expression) {
       //TODO: First, expression compiler must be implemented.

    }
    func compileComputedMemberAssignmentTarget(currentNodeId: Int, _ object: Expression, _ propertyExpr: Expression) {
    }

    //MARK: Declarations
    func walkDeclaration(_ decl: Declaration) {
        let id = allocNodeId()
        switch decl {
            case .function(let name, let params, let body, let isAsync, let isGenerator):
                break
            case .variable(let initializer):
                break
            case .lexical (let kind, let initializer):
                break
            case .class(let name, let superClass, let body):
                break
            case .importDecl:
                fatalError ("Not implemented yet")
            case .exportDecl:
                fatalError ("Not implemented yet")
        }
    }

    func compileFunctionDeclaration(currentNodeId: Int, _ name: String, _ params: [Pattern]?, _ body: Statement, _ isAsync: Bool, _ isGenerator: Bool) {

    }
    func compileVariableDeclaration(currentNodeId: Int, _ initializer: [VariableDeclarator]) {

    }
    func compileLexicalDeclaration(currentNodeId: Int, _ kind: LexicalKind, _ initializer: [VariableDeclarator]) {
    
    }
    func compileClassDeclaration(currentNodeId: Int, _ name: String, _ superClass: Expression?, _ body: [ClassElement]) {
    
    }

}
    