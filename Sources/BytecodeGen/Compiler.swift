class BytecodeCompiler {

    var compilationUnit: CompilationUnit
    var bytecodeCompilation: [Bytecode] = []
    var currentBlock: BasicBlock 
    var BasicBlocks: [BasicBlock] = []
    var blockCounter: Int = 0
    var regCounter: UInt16 = 0
    var currentNodeId: Int = 0
    var constantsPool: [String: Int] = [:]

    var sharedCompileTimeInfo: UInt64 = 0 // This can be used to store any information that needs to be shared across different compile functions, such as loop depth, switch case depth, etc.


    init(compilationUnit: CompilationUnit) {
        self.compilationUnit = compilationUnit
        self.currentBlock = BasicBlock(id: 0)
        self.BasicBlocks.append(self.currentBlock)
    }
}

extension BytecodeCompiler {

    func createCPIndex(for name: String) -> Bytecode.CPIndex {
        let (idx, _) = putRecordOnConstantsPool(name)
        return Bytecode.CPIndex(rawValue: UInt32(idx))
    }
    
    func putRecordOnConstantsPool(_ value: String) -> (Int, Bool) {
        if let existingIndex = constantsPool[value] {
            return (existingIndex, true)
        } else {
            let newIndex = constantsPool.count
            constantsPool[value] = newIndex
            return (newIndex, false)
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
        _ = allocNodeId()
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


    
    
    
    
    func compileBinaryExpression(currentNodeId: Int,_ left: Expression, _ op: TokenType, _ right: Expression) {
        walkExpression(left)
        let leftReg = allocRegister()
        emit(.star(leftReg))
        
        walkExpression(right)
        
        guard case .binaryOp(let binaryOp) = op else{
            fatalError("Expected a binary operator token, but got \(op). NodeId: \(currentNodeId)")
        }

        switch binaryOp {
            case .plus:
                emit(.add(leftReg))
            case .minus:
                emit(.sub(leftReg))
            case .multiply:
                emit(.mul(leftReg))
            case .divide:
                emit(.div(leftReg))
            case .percent:
                emit(.mod(leftReg))
            case .equal:
                emit(.eq(leftReg))
            case .notEqual:
                emit(.neq(leftReg))
            case .lessThan:
                emit(.lt(leftReg))
            case .lessThanOrEqual:
                emit(.le(leftReg))
            case .greaterThan:
                emit(.gt(leftReg))
            case .greaterThanOrEqual:
                emit(.ge(leftReg))
            case .ampersand:
                emit(.and(leftReg))
            case .pipe:
                emit(.or(leftReg))
            case .caret:
                emit(.xor(leftReg))
            case .logicalAnd:
                emit(.logicalAnd(leftReg))
            case .logicalOr:
                emit(.logicalOr(leftReg))
            case .instanceof:
                emit(.instanceof(leftReg))
            case .in:
                emit(.inOp(leftReg))
            case .assign:
                break
            case .leftShift:
                emit(.shl(leftReg))
            case .rightShift:
                emit(.shr(leftReg))
            case .unsignedRightShift:
                emit(.ushr(leftReg))
            case .strictEqual:
                emit(.strictEq(leftReg))
            case .strictNotEqual:
                emit(.strictNeq(leftReg))
            default:
                fatalError("Binary operator \(binaryOp) is not supported yet. NodeId: \(currentNodeId)")
}


    }
    func compileMemberExpression(currentNodeId: Int, _ object: Expression, _ property: Expression) {}
    func compileComputedMemberExpression(currentNodeId: Int, _ object: Expression, _ propertyExpr: Expression) {}
    func compileSequenceExpression(currentNodeId: Int, _ exprs: [Expression]) {}
    func compileCallExpression(currentNodeId: Int, _ callee: Expression, _ arguments: [Expression]) {}
    func compileNudExpression(currentNodeId: Int, _ expr: Expression) {
        switch expr {
            case .identifier(let name):
                let ref = compilationUnit.getBoundRefByNodeId(nodeId: currentNodeId)
                if ref.storageKind == .global && ref.bindingId == nil {
                    // If there is no binding, it must be a global variable.
                    // We assume that VM will match the global variable,
                    // else it will throw a ReferenceError at runtime.
                    let cpIndex = createCPIndex(for: name)

                    // Put "vm->acc" state to global variable index to be used later
                    emit(.ldaGlobal(cpIndex))
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
                    case .global:
                        let cpIndex = createCPIndex(for: name)
                        emit(.ldaGlobal(cpIndex))
                    default:
                        fatalError("Invalid storage kind for identifier \(name). NodeId: \(currentNodeId)")

                }
                
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
                    case .float:
                        break //TODO
                }
                break
            default:
                fatalError("Not implemented yet")
        }
    }
    func compileAssignmentExpression(currentNodeId: Int, _ target: AssignmentTarget, _ op: TokenType, _ value: Expression) {
        
        walkAssignmentTarget(target)                            // acc = [31:0] slot or cp index | [63:32] storage kind  
        
        walkExpression(value)
        let valueReg = allocRegister()
        emit(.star(valueReg))

        let isNamedMemberAssignment = sharedCompileTimeInfo & (1<<63) != 0 // Check if the highest bit is set, which indicates an object assignment target (member or computed member)
        let isComputedMemberAssignment = sharedCompileTimeInfo & (1<<62) != 0 // Check if the second highest bit is set, which indicates a computedMember assignment target
        let isDestructuringAssignment = sharedCompileTimeInfo & (1<<61) != 0 // Check if the third highest bit is set, which indicates a destructuring assignment target
        
        if isNamedMemberAssignment{
            
            let (cpIndex, objectReg) = (sharedCompileTimeInfo & 0xFFFF, Bytecode.Reg(rawValue: UInt16((sharedCompileTimeInfo >> 32) & 0x1FFF))) // [31:0] cp index, [61:32] object register
            
            emit(.ldar(valueReg))
            emit(.setPropNamed(objectReg, Bytecode.CPIndex(rawValue: UInt32(cpIndex))))
       
        } else if isComputedMemberAssignment {
            
            let objectReg = Bytecode.Reg(rawValue: UInt16((sharedCompileTimeInfo >> 32) & 0x1FFF)) // [61:32] property register
            let propertyReg = Bytecode.Reg(rawValue: UInt16(sharedCompileTimeInfo & 0x1FFF)) // [31:0] object register
            
            emit(.ldar(valueReg))
            emit(.setPropKeyed(objectReg, propertyReg))
            
        } else {

            let storageKindBits = (sharedCompileTimeInfo >> 48) & 0x7F // [63:32] storage kind (0 = unknown, 1 = lexical, 2 = context, 4 = global)
            switch storageKindBits {
                case 1: // lexical
                    let slot = sharedCompileTimeInfo & 0xFFFF // [31:0] slot index
                    emit(.staLexical(UInt16(slot)))
                case 2: // context
                    let depth = (sharedCompileTimeInfo >> 32) & 0xFFFF // [47:32] capturing depth
                    let slot = sharedCompileTimeInfo & 0xFFFF // [31:0] slot index
                    emit(.staContextSlot(UInt8(depth), UInt16(slot)))
                case 4: // global
                    let cpIndex = sharedCompileTimeInfo & 0xFFFF // [31:0] cp index
                    emit(.staGlobal(Bytecode.CPIndex(rawValue: UInt32(cpIndex))))
                default:
                    fatalError("Invalid storage kind bits in sharedCompileTimeInfo for assignment target. NodeId: \(currentNodeId)")
            }

        } 
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
                compileDestructuringAssignmentTarget(currentNodeId: id, pattern)
        }
    }


    //ABI: sharedCompileTimeInfo = slot (or) cp index | storageKind << 32 
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
            let (cpidx, _) = putRecordOnConstantsPool(name)
            
            sharedCompileTimeInfo = (4 << 48) | UInt64(cpidx) // storageKind = 4 for global variables
            return
        }

        if mode == 1 {
            guard let slot = binding.slot else{
                fatalError("Expected binding for identifier \(name) to have an allocated slot by slotAllocator in scope analysis, but it was nil. NodeId: \(currentNodeId)")
            }
            let storageKind = ref.storageKind
                    
            // 0x0000 0000 0000 0000  0000 0000 0000 0000
            // [31:0] slot index for lexical/context variables or cp index for global variables
            // [63:32] storage kind (0 = unknown, 1 = lexical, 2 = context, 4 = global)
                    
            var maybeCPIndex: UInt64? = nil
            var depth: UInt64 = 0000
            var storageKindBits: UInt64 = 0
            switch storageKind {
                case .lexical:
                    storageKindBits = 1
                
                case .context:
                    storageKindBits = 2

                    depth = UInt64(ref.capturingDepth)
                
                case .global:
                    storageKindBits = 4
                    
                    let (cpidx, _) = putRecordOnConstantsPool(name)
                   
                    maybeCPIndex = UInt64(cpidx)
                    guard let CPIndex = maybeCPIndex else {
                        fatalError("Failed to put global variable \(name) on constants pool. NodeId: \(currentNodeId)")
                    }
                    
                    sharedCompileTimeInfo = (storageKindBits << 48) | UInt64(CPIndex)
                    
                    return
                
                default:
                    fatalError("Invalid storage kind for identifier \(name). NodeId: \(currentNodeId)")
                }
                    
               sharedCompileTimeInfo = (storageKindBits << 48) | (depth << 32) | UInt64(slot)
        } else if mode == 2 {
            fatalError("TODO: Implement for-in/of assignment target handling for identifier \(name). NodeId: \(currentNodeId)")
        }
        
    }



    func compileMemberAssignmentTarget(currentNodeId: Int, _ object: Expression, _ property: Expression) {
        //TODO: First, expression compiler must be implemented.
        walkExpression(object)
        let objectReg = allocRegister()
        emit(.star(objectReg))

        guard case .identifier(let propName) = property else {
            fatalError("Expected member assignment target to have an identifier as property, but got \(property). NodeId: \(currentNodeId)")
        }

        let (cpIndex, isPresentAtPool) = putRecordOnConstantsPool(propName)

        if !isPresentAtPool {
            // If the property name is not already in the constants pool, we need to emit a bytecode to put it there.
            emit(.definePropNamed(objectReg, Bytecode.CPIndex(rawValue: UInt32(cpIndex)), 0))    
        }

        sharedCompileTimeInfo = UInt64(cpIndex) | UInt64(objectReg.rawValue) << 32 | 1<<63// Put cp index in sharedCompileTimeInfo for later use in staPropNamed bytecode emission 

    }
    func compileComputedMemberAssignmentTarget(currentNodeId: Int, _ object: Expression, _ propertyExpr: Expression) {
        walkExpression(object)
        let objectReg = allocRegister()
        emit(.star(objectReg))

        walkExpression(propertyExpr)
        let propertyReg = allocRegister()
        emit(.star(propertyReg))
    }

    func compileDestructuringAssignmentTarget(currentNodeId: Int, _ DestructuringPattern: DestructuringPattern) {
        
    }

    //MARK: Declarations
    func walkDeclaration(_ decl: Declaration) {
        let id = allocNodeId()
        switch decl {
            case .function(let name, let params, let body, let isAsync, let isGenerator):
                compileFunctionDeclaration(currentNodeId: id, name, params, body, isAsync, isGenerator)
                
            case .variable(let initializer):
                compileVariableDeclaration(currentNodeId: id, initializer)
            case .lexical (let kind, let initializer):
                compileLexicalDeclaration(currentNodeId: id, kind, initializer)
            case .class(let name, let superClass, let body):
                compileClassDeclaration(currentNodeId: id, name, superClass, body)
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

    func walkVariableDeclarator(currentNodeId: Int, _ id: Pattern, _ init: Expression?) {   
    
    }

    func walkPattern(_ pattern: Pattern) {
        let id = allocNodeId()
        switch pattern {
            case .bindingIdentifier(let name):
                compileIdentifierPattern(currentNodeId: id, name)
            case .object(let properties):
                compileObjectPattern(currentNodeId: id, properties)
            case .array(let elements):
                compileArrayPattern(currentNodeId: id, elements)
            case .assignment(let left, let right):
                compileAssignmentPattern(currentNodeId: id, left, right)
            case .rest(let argument):
                compileRestElementPattern(currentNodeId: id, argument)
        }

    }
    func compileIdentifierPattern(currentNodeId: Int, _ name: String) {

    }
    func compileObjectPattern(currentNodeId: Int, _ properties: [ObjectPatternProperty]) {

    }
    func compileArrayPattern(currentNodeId: Int, _ elements: [ArrayPatternElement]) {  

    }

    func compileAssignmentPattern(currentNodeId: Int, _ left: Pattern, _ right: Expression) {

    }
    func compileRestElementPattern(currentNodeId: Int, _ argument: Pattern) {
    
    }
}
    