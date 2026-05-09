class BytecodeCompiler {

    var compilationUnit: CompilationUnit
    var serializationUnit: SerializationUnit
    
    var GlobalConstantsPool: ConstantsPool = ConstantsPool()
    var currentConstantsPool: ConstantsPool
    var functionTable: [Bytecode.FunctionID: CodeBlock] = [:]
    var GlobalBasicBlocks: [BasicBlock] = []
    
    var currentBlock: BasicBlock 
    var VirtualCallStack: [Bytecode.FunctionID] = []
    var blockCounter: Int = 0

    var regCounter: UInt16 = 0
    var ContinuousRegistersMode: Bool = false //MARK: TODO: dummy for now, used in "argsBase" in emit(.call), it ensures that the registers are allocated in a continuous manner

    var argCounter: UInt16 = 0
    var callSlotCounter: UInt16 = 0
    var scopeLayoutCounter: UInt16 = 0
    var funcIdCounter: UInt32 = 0
    var currentNodeId: Int = -1
    var ICSlotCounter: UInt16 = 0
    var ProfileSlotCounter: UInt16 = 0

    var universalUndefinedReg: Bytecode.Reg? = nil // a register that holds the "undefined" value, to be reused whenever we need to load "undefined", to save bytecode space

    init(compilationUnit: CompilationUnit, serializationUnit: SerializationUnit) {
        self.compilationUnit = compilationUnit
        self.serializationUnit = serializationUnit
        self.currentBlock = BasicBlock(id: 0)
        self.GlobalBasicBlocks.append(self.currentBlock)
        self.currentConstantsPool = self.GlobalConstantsPool
    }
}

extension BytecodeCompiler {

    func putDebugMark(_ comment: String) {
        #if DEBUG
        #endif
    }

    func switchConstantsPool(_ pool: ConstantsPool) -> ConstantsPool {
        let oldCP = self.currentConstantsPool
        self.currentConstantsPool = pool
        return oldCP
    }
    
    func putRecordOnConstantsPool(_ value: String) -> (UInt32, Bool) {
        if let existingIndex = currentConstantsPool.pool[value] {
            return (existingIndex, true)
        } else {
            let newIndex = UInt32(currentConstantsPool.pool.count)
            currentConstantsPool.pool[value] = newIndex
            return (newIndex, false)
        }
    }

    func pushVirtualCallStack(_ funcId: Bytecode.FunctionID) {
        VirtualCallStack.append(funcId)
    }

    func popVirtualCallStack() {
        VirtualCallStack.removeLast()
    }

    //if called while not being in a function context
    func putBBOnRelevantContext(entryBlock: BasicBlock) {
        if let currentId = VirtualCallStack.last {
            guard case .some = functionTable[currentId] else {
                fatalError("Current function ID should have been put in the function table")
            }

            functionTable[currentId]!.addBasicBlock(entryBlock)
        } else {
            GlobalBasicBlocks.append(entryBlock)
        }
    }

    func enterFunctionBBContext(funcId: Bytecode.FunctionID) -> (BasicBlock, ConstantsPool) {
        let newBlock = allocBasicBlock()
        let constantsPool = ConstantsPool()
        let codeBlock = CodeBlock(constantPool: constantsPool)
        codeBlock.addBasicBlock(newBlock)
        
        pushVirtualCallStack(funcId)
        functionTable[funcId] = codeBlock

        return (switchBasicBlock(newBlock), switchConstantsPool(constantsPool))
         
    }

    func exitFunctionBBContext(oldBlock: BasicBlock, oldCP: ConstantsPool) {
        popVirtualCallStack()
        _ = switchBasicBlock(oldBlock)
        _ = switchConstantsPool(oldCP)
    }

    func allocNodeId() -> Int {
        currentNodeId += 1
        return currentNodeId
    }

    func allocCallSlot() -> Bytecode.CallSlot {
        let slot = Bytecode.CallSlot(rawValue: callSlotCounter)
        callSlotCounter += 1
        return slot
    }

    func emit(_ bytecode: Bytecode) {
        currentBlock.instructions.append(bytecode)
    }

    func emitOnTopLevel(_ bytecode: Bytecode, at index: Int = 2) {
        if currentBlock.instructions.count < index {
            while currentBlock.instructions.count < index{
                currentBlock.instructions.insert(.nop, at: 0)
            }
        } 
        currentBlock.instructions.insert(bytecode, at: index) // after the initial .enterGlobal
    }

    func emitOnFunctionLevel(_ bytecode: Bytecode, funcId: Bytecode.FunctionID, at index: Int = 1) {
        guard let codeBlock = functionTable[funcId] else {
            fatalError("Function ID should have been put in the function table")
        }

        guard let firstBlock = codeBlock.basicBlocks.first else {
            fatalError("There should be at least one block for the function")
        }

        firstBlock.instructions.insert(bytecode, at: index)
    }

    func emitTerminator(_ terminator: Terminator) {
        currentBlock.terminator = terminator
    }

    func allocBasicBlock() -> BasicBlock {
        blockCounter += 1
        let newBlock = BasicBlock(id: blockCounter)
        return newBlock
    }

    func switchBasicBlock(_ newBlock: BasicBlock) -> BasicBlock {
        let oldBlock = currentBlock
        currentBlock = newBlock
        return oldBlock
    }

    func allocRegister(continuousRegs: Bool = false) -> Bytecode.Reg { //MARK: TODO: continuousRegs is a dummy parameter for now, used in "argsBase" in emit(.call), it ensures that the register is allocated in a continuous manner
        let reg = Bytecode.Reg(rawValue: regCounter)
        regCounter += 1
        return reg
    }

    func allocArgumentSlot() -> Bytecode.ArgSlot {
        let slot = Bytecode.ArgSlot(rawValue: argCounter)
        argCounter += 1
        return slot
    }

    func resetArgumentSlots() {
        argCounter = 0
    }

    func allocScopeLayout() -> Bytecode.ScopeLayoutID {
        let layoutId = Bytecode.ScopeLayoutID(rawValue: scopeLayoutCounter)
        scopeLayoutCounter += 1
        return layoutId
    }

    func allocFunctionId() -> Bytecode.FunctionID {
        let funcId = Bytecode.FunctionID(rawValue: UInt32(funcIdCounter))
        funcIdCounter += 1
        return funcId
    }

    func allocICSlot() -> Bytecode.ICSlot {
        let slot = Bytecode.ICSlot(rawValue: ICSlotCounter)
        ICSlotCounter += 1
        return slot
    }

    func allocProfileSlot() -> Bytecode.ProfileSlot {
        let slot = Bytecode.ProfileSlot(rawValue: ProfileSlotCounter)
        ProfileSlotCounter += 1
        return slot
    }

    func universalCompilerUndefinedReg() -> Bytecode.Reg {
        if let reg = universalUndefinedReg {
            return reg
        } else {
            let reg = allocRegister()
            emit(.loadUndefined(dst: reg))
            universalUndefinedReg = reg
            return reg
        }
    }

    func returnSomeRegWithUndefined()-> Bytecode.Reg {
        let reg = allocRegister()
        let bytecode: Bytecode = .loadUndefined(dst: reg)
        emit(bytecode)
        
        return reg
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

            emit(.enterGlobal)
            _ = universalCompilerUndefinedReg()

            if case .program(let body) = program {
                for statement in body {
                    walkStatement(statement)
                }
            }

            emitTerminator(.halt)
        
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
        
        let testReg: Bytecode.Reg
        let testResult = walkExpression(test)

        switch testResult {
            case .expr(let reg):
                testReg = reg
            default:
                fatalError("Unsupported expression result for if statement test")
        }  

        let testAsBoolReg = allocRegister()
        let profileSlot = allocProfileSlot()

        emit(.toBoolean(dst: testAsBoolReg, src: testReg, profile: profileSlot))

        let trueBlock = allocBasicBlock()
        let falseBlock = allocBasicBlock()
        let afterIfBlock = allocBasicBlock()

        for block in [trueBlock, falseBlock, afterIfBlock] {
            putBBOnRelevantContext(entryBlock: block)
        }

        let conditionForJump: Bytecode = .jumpIfTrue(
            condition: testAsBoolReg,
            offset: Bytecode.JumpOffset(rawValue: .backpatchRef(trueBlock.id))
        )
        emitTerminator(.conditionalJump(condition: conditionForJump, trueBlockId: trueBlock.id, falseBlockId: falseBlock.id))

        let oldBlock = switchBasicBlock(trueBlock)
        do {walkStatement(consequent)}
        emitTerminator(.jump(BlockID: afterIfBlock.id))
        
        _ = switchBasicBlock(falseBlock)
        if let alternate = alternate {
            do {walkStatement(alternate)}    
            
        }

        _ = switchBasicBlock(afterIfBlock)

    }

    func compileWhileStatement(currentNodeId: Int, _ test: Expression, _ body: Statement) {
        
        let testBlock = allocBasicBlock()
        let bodyBlock = allocBasicBlock()
        let afterLoopBlock = allocBasicBlock()
        
        for block in [testBlock, bodyBlock, afterLoopBlock] {
            putBBOnRelevantContext(entryBlock: block)
        }    

        emitTerminator(.jump(BlockID: testBlock.id))

        _ = switchBasicBlock(testBlock)

        do {
            
            let testResult = walkExpression(test)
            guard case .expr(let testReg) = testResult else {
                fatalError("Unsupported expression result for while statement test")
            }

            let testAsBoolReg = allocRegister()
            emit(.toBoolean(dst: testAsBoolReg, src: testReg, profile: allocProfileSlot()))

            emitTerminator(.conditionalJump(
                condition: .jumpIfTrue(
                    condition: testAsBoolReg,
                    offset: Bytecode.JumpOffset(rawValue: .backpatchRef(bodyBlock.id))),
                trueBlockId: bodyBlock.id,
                falseBlockId: afterLoopBlock.id
            ))

        }

        _ = switchBasicBlock(bodyBlock)

        do {
            walkStatement(body)
            emitTerminator(.jump(BlockID:testBlock.id))
        }

        _ = switchBasicBlock(afterLoopBlock)




    }
    func compileDoWhileStatement(currentNodeId: Int, _ body: Statement, _ test: Expression) {
        let bodyBlock = allocBasicBlock()
        let testBlock = allocBasicBlock()
        let afterLoopBlock = allocBasicBlock()
        
        for block in [bodyBlock, testBlock, afterLoopBlock] {
            putBBOnRelevantContext(entryBlock: block)
        }    

        emitTerminator(.jump(BlockID: bodyBlock.id))

        _ = switchBasicBlock(bodyBlock)

        do {
            walkStatement(body)
            emitTerminator(.jump(BlockID: testBlock.id))
        }

        _ = switchBasicBlock(testBlock)

        do {
            
            let testResult = walkExpression(test)
            guard case .expr(let testReg) = testResult else {
                fatalError("Unsupported expression result for do-while statement test")
            }

            let testAsBoolReg = allocRegister()
            emit(.toBoolean(dst: testAsBoolReg, src: testReg, profile: allocProfileSlot()))

            emitTerminator(.conditionalJump(
                condition: .jumpIfTrue(
                    condition: testAsBoolReg,
                    offset: Bytecode.JumpOffset(rawValue: .backpatchRef(bodyBlock.id))
                ),
                trueBlockId: bodyBlock.id,
                falseBlockId: afterLoopBlock.id
            ))

        }

        _ = switchBasicBlock(afterLoopBlock)
    }

    func compileForStatement(currentNodeId: Int, _ initial: ForInit?, _ test: Expression?, _ update: Expression?, _ body: Statement) {
        
        let initReg, testReg, updateReg: Bytecode.Reg? 
        
        if let initial = initial {

            switch initial {
                case .declaration(let decl):
                    walkDeclaration(decl)
                case .expression(let expr):
                    guard case .expr(let reg) = walkExpression(expr) else {
                        fatalError("Unsupported expression result for for statement initial")
                    }
                    initReg = reg
            }
        }

        let testBlock = allocBasicBlock()
        let bodyBlock = allocBasicBlock()
        let updateBlock = allocBasicBlock()
        let afterLoopBlock = allocBasicBlock()

        for block in [testBlock, bodyBlock, updateBlock, afterLoopBlock] {
            putBBOnRelevantContext(entryBlock: block)
        }

        emitTerminator(.jump(BlockID: testBlock.id))

        _ = switchBasicBlock(testBlock)

        do {
            if let test = test {
                let testResult = walkExpression(test)
                guard case .expr(let testReg) = testResult else {
                    fatalError("Unsupported expression result for for statement test")
                }

                let testAsBoolReg = allocRegister()
                emit(.toBoolean(dst: testAsBoolReg, src: testReg, profile: allocProfileSlot()))

                emitTerminator(.conditionalJump(
                    condition: .jumpIfTrue(
                        condition: testAsBoolReg,
                        offset: Bytecode.JumpOffset(rawValue: .backpatchRef(bodyBlock.id))
                    ),
                    trueBlockId: bodyBlock.id,
                    falseBlockId: afterLoopBlock.id
                ))
            } else {
                emitTerminator(.jump(BlockID: updateBlock.id))
            }
        }

        _ = switchBasicBlock(updateBlock)

        do {
            if let update = update {
                _ = walkExpression(update)
                emitTerminator(.jump(BlockID: bodyBlock.id))
            } else {
                emitTerminator(.jump(BlockID: bodyBlock.id))
            }
        }

        _ = switchBasicBlock(bodyBlock)

        do {
            walkStatement(body)
            emitTerminator(.jump(BlockID: testBlock.id))
        }

        _ = switchBasicBlock(afterLoopBlock)


    }

    func compileForInStatement(currentNodeId: Int, _ left: ForEachLeft, _ right: Expression, _ body: Statement) {
        
    }

    func compileForOfStatement(currentNodeId: Int, _ left: ForEachLeft, _ right: Expression, _ body: Statement) {
        
    }

    func compileForAwaitOfStatement(currentNodeId: Int, _ left: ForEachLeft, _ right: Expression, _ body: Statement) {
        
    }

    func compileReturnStatement(currentNodeId: Int, _ argument: Expression?) {
        
        if let argument = argument {
            let returnValueResult = walkExpression(argument)
            guard case .expr(let returnValueReg) = returnValueResult else {
                fatalError("Unsupported expression result for return statement argument")
            }

            emitTerminator(.return(returnValueReg))
        } else {
            let undefinedReg = universalCompilerUndefinedReg()
            emitTerminator(.return(undefinedReg))
        }

        putBBOnRelevantContext(entryBlock: allocBasicBlock())
        
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
    func walkExpression(_ expr: Expression, isPropertyKey: Bool = false) -> ExprResult {
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
                return compileNudExpression(currentNodeId: id, expr, isPropertyKey: isPropertyKey)

            case .binary(let left, let op, let right):
                return compileBinaryExpression(currentNodeId: id, left, op, right)
            case .assignment(let target, let op, let value): //DONE~
                return compileAssignmentExpression(currentNodeId: id, target, op, value)
            case .call(let callee, let arguments):  //DONE
                return compileCallExpression(currentNodeId: id, callee, arguments) 
            case .member(let object, let property):
                return compileMemberExpression(currentNodeId: id, object, property)
            case .computedMember(let object, let propertyExpr):
                return compileComputedMemberExpression(currentNodeId: id, object, propertyExpr)
            case .sequence(let expressions):
                return compileSequenceExpression(currentNodeId: id, expressions)

        }

    }


    func compileBinaryExpression(currentNodeId: Int,_ left: Expression, _ op: TokenType, _ right: Expression) -> ExprResult {
        
        let leftResult = walkExpression(left)
        guard case .expr(let leftReg) = leftResult else {
            fatalError("Unsupported expression result for binary expression left operand")
        }
        
        let rightResult = walkExpression(right)
        guard case .expr(let rightReg) = rightResult else {
            fatalError("Unsupported expression result for binary expression right operand")
        }
        
        let resultReg = allocRegister()
        let ProfileSlot = allocProfileSlot()

       

        switch op {
            case .binaryOp(.plus):
                emit(.add(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.minus):
                emit(.sub(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.multiply):
                emit(.mul(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.divide):
                emit(.div(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.percent):
                emit(.mod(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            //case pow

            
            case .binaryOp(.ampersand):
                emit(.bitAnd(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.pipe):
                emit(.bitOr(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.caret):
                emit(.bitXor(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.leftShift):
                emit(.leftShift(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.rightShift):
                emit(.rightShift(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.unsignedRightShift):
                emit(.unsignedRightShift(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))


            case .binaryOp(.equal):
                emit(.equal(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.notEqual):
                emit(.notEqual(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.strictEqual):
                emit(.strictEqual(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.strictNotEqual):
                emit(.strictNotEqual(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.lessThan):
                emit(.lessThan(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.greaterThan):
                emit(.greaterThan(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.lessThanOrEqual):   
                emit(.lessThanOrEqual(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            case .binaryOp(.greaterThanOrEqual):
                emit(.greaterThanOrEqual(dst: resultReg, lhs: leftReg, rhs: rightReg, profile: ProfileSlot))
            
            default:
                fatalError("Unsupported binary operator")
        }

        
        return .expr(resultReg)
    }
    func compileMemberExpression(currentNodeId: Int, _ object: Expression, _ property: Expression) -> ExprResult {
        let objectResult = walkExpression(object)
        guard case .expr(let objectReg) = objectResult else {
            fatalError("Unsupported expression result for member expression object")
        }

        let propertyResult = walkExpression(property, isPropertyKey: true)
        guard case .propertyKey(let propertyName) = propertyResult else {
            fatalError("Unsupported expression result for member expression property")
        }

        let resultReg = allocRegister()

        emit(.getById(dst: resultReg, base: objectReg, name: propertyName, cache: allocICSlot() ))
        return .expr(resultReg)
    }
    func compileComputedMemberExpression(currentNodeId: Int, _ object: Expression, _ propertyExpr: Expression) -> ExprResult {
        let objectResult = walkExpression(object)
        guard case .expr(let objectReg) = objectResult else {
            fatalError("Unsupported expression result for computed member expression object")
        }

        let propertyResult = walkExpression(propertyExpr)
        guard case .expr(let propertyReg) = propertyResult else {
            fatalError("Unsupported expression result for computed member expression property")
        }

        let propertyKeyReg = allocRegister()
        emit(.toPropertyKey(dst: propertyKeyReg, src: propertyReg, profile: allocProfileSlot()))

        let resultReg = allocRegister()
        emit(.getByVal(dst: resultReg, base: objectReg, key: propertyKeyReg, cache: allocICSlot() ))
        
        return .expr(resultReg)
    }

    func compileSequenceExpression(currentNodeId: Int, _ exprs: [Expression]) -> ExprResult {
        return .todo
    }
    func compileCallExpression(currentNodeId: Int, _ callee: Expression, _ arguments: [Expression]) -> ExprResult {
        putDebugMark("Entered Call Expression")
        
        let calleeResult = walkExpression(callee)
        guard case .expr(let calleeReg) = calleeResult else {
            fatalError("Unsupported expression result for call expression callee")
        }   

        let argc = Bytecode.ArgCount(rawValue: UInt16(arguments.count))

        var argumentRegs: [Bytecode.Reg] = []
        for argument in arguments {
            let argResult = walkExpression(argument)
            guard case .expr(let argReg) = argResult else {
                fatalError("Unsupported expression result for call expression argument")
            }
            argumentRegs.append(argReg)
        }

        var argsBaseReg: Bytecode.Reg? = nil
        
        for i in 0..<argumentRegs.count {
            if case .none = argsBaseReg {
                argsBaseReg = allocRegister()

                guard let argsBaseReg = argsBaseReg else {
                    fatalError("argsBaseReg should have been allocated")
                }

                emit(.move(dst: argsBaseReg, src: argumentRegs[i]))
                continue
            }

            let dstReg = allocRegister()

            emit(.move(dst: dstReg, src: argumentRegs[i]))
        }

        let resultReg = allocRegister()

        let thisValueReg = allocRegister()
        emit(.loadThis(dst: thisValueReg))

        if arguments.count == 0 {
            argsBaseReg = allocRegister()
        }

        let callSlot = allocCallSlot()
        
        emit(.call(dst: resultReg, callee: calleeReg, thisValue: thisValueReg, argsBase: argsBaseReg!, argc: argc, call: callSlot))
        
        return .expr(resultReg)
    }
    func compileNudExpression(currentNodeId: Int, _ expr: Expression, isPropertyKey: Bool = false) -> ExprResult {
        putDebugMark("Entered Nud Expression")
        switch expr {
            case .identifier(let name):
                return compileIdentifierExpression(currentNodeId: currentNodeId, name, isPropertyKey: isPropertyKey)
                    
            case .literal(let literal):
                return compileLiteralExpression(currentNodeId: currentNodeId, literal)
            default:
                fatalError("Unsupported nud expression")
        }
    
    }

    func compileIdentifierExpression(currentNodeId: Int, _ name: String, isPropertyKey: Bool = false) -> ExprResult {
        putDebugMark("Entered Identifier Expression")
        let (cpIndex, isPresentAtPool) = putRecordOnConstantsPool(name)

        if isPropertyKey {
            return .propertyKey(Bytecode.CPIndex(rawValue: cpIndex))
        }
        
        let resultReg: Bytecode.Reg = allocRegister()
        let profileSlot = allocProfileSlot()

            // in case of unknown identifier at compile time -> console.log
            // it must be a reference to read, not write
        let boundRef = compilationUnit.getBoundRefByNodeId(nodeId: currentNodeId)
        if case .none = boundRef.bindingId {
            // Unresolved identifier, treat as global property access
            emit(.getGlobalProperty(
                dst: resultReg, 
                name: Bytecode.CPIndex(rawValue: cpIndex), 
                cache: allocICSlot()
            ))
                return .expr(resultReg)
            }

        let binding = compilationUnit.findBindingById(boundRef.bindingId!)!
            
        guard let slot = binding.slot else {
            fatalError("No binding slot found for captured identifier")
        }
            
        if boundRef.capturingDepth != 0 && boundRef.bindingId != nil {
            
            emit(.getContext(
                dst: resultReg, 
                depth: Bytecode.ContextDepth(rawValue: UInt8(boundRef.capturingDepth)), 
                slot: Bytecode.ContextSlot(rawValue: UInt16(slot))
            ))

        } else if binding.is_global {
                
            if case .lexical = binding.kind {
                    
                emit(.getGlobalLexical(
                    dst: resultReg, 
                    slot: Bytecode.GlobalSlot(rawValue: UInt16(slot)), 
                    profile: profileSlot
                ))
                
            } else {
            
                    let ICSlot = allocICSlot()
                    
                    emit(.getGlobalVar(
                        dst: resultReg, 
                        slot: Bytecode.GlobalSlot(rawValue: UInt16(slot)),
                        cache: ICSlot
                    ))
            
                }
            
            } else {
            
                emit(.getLocal(
                    dst: resultReg, 
                    slot: Bytecode.LocalSlot(rawValue: UInt16(slot))
                ))
            
            } 

            
            
        
        return .expr(resultReg)
    }

    func compileLiteralExpression(currentNodeId: Int, _ literal: Literal) -> ExprResult {
        putDebugMark("Entered Literal Expression")
        let resultReg: Bytecode.Reg = allocRegister()
        
        switch literal {
            case .null:
                emit(.loadNull(dst: resultReg))
            case .undefined:
                emit(.loadUndefined(dst: resultReg))
            case .bool(let value):
                if value {
                    emit(.loadTrue(dst: resultReg))
                } else {
                    emit(.loadFalse(dst: resultReg))
                }
            case .int(let value):
                emit(.loadInt32(dst: resultReg, value: Int32(value)))
            case .float:
                fatalError("Float literals not supported yet")
            case .string(let value):
                let (cpIndex, _) = putRecordOnConstantsPool(value)
                emit(.loadString(dst: resultReg,name: Bytecode.CPIndex(rawValue: cpIndex)))
        }

        return .expr(resultReg)
    }

    func compileAssignmentExpression(currentNodeId: Int, _ target: AssignmentTarget, _ op: TokenType, _ value: Expression) -> ExprResult{
        putDebugMark("Entered Assignment Expression")
        let targetInfo = walkAssignmentTarget(target)
        let valueResult = walkExpression(value)
        
        guard case .expr(let valueReg) = valueResult else {
            fatalError("Unsupported expression result for assignment expression value")
        }

        switch op { // for the varying assignment operators (+=, *=, etc.)
        case .binaryOp(.assign):
            switch targetInfo { //main logic of simple assignment
            case .destructuring:
                fatalError("Destructuring assignment not implemented yet")

            case .identifier(let refType):
                switch refType {
                    case .local(let slot):
                        emit(.putLocal(slot: Bytecode.LocalSlot(rawValue: UInt16(slot)), src: valueReg))
                    case .context(let depth, let slot):
                        emit(.putContext(depth: Bytecode.ContextDepth(rawValue: depth), slot: Bytecode.ContextSlot(rawValue: UInt16(slot)), src: valueReg))
                    case .globalVar(let slot):
                        emit(.putGlobalVar(slot: Bytecode.GlobalSlot(rawValue: UInt16(slot)), src: valueReg, cache: allocICSlot()))
                    case .globalLexical(let slot):
                        emit(.putGlobalLexical(slot: Bytecode.GlobalSlot(rawValue: UInt16(slot)), src: valueReg, profile: allocProfileSlot()))
                    case .unresolved(let cpIndex):
                        emit(.putGlobalProperty( name: cpIndex, src: valueReg, cache: allocICSlot()))
                }
            case .namedMember(let objectReg, let propertyName):
                // if that propertyName is not defined yet, a new property will be created on the object
                emit(.putById(
                    base: objectReg,
                    name: propertyName, 
                    value: valueReg, 
                    cache: allocICSlot()
                ))

            case .computedMember(let objectReg, let propertyReg):
                
                let propertyKeyReg = allocRegister()
                emit(.toPropertyKey(
                    dst: propertyKeyReg, 
                    src: propertyReg, 
                    profile: allocProfileSlot()
                ))

                emit(.putByVal(
                    base: objectReg,
                    key: propertyKeyReg, 
                    value: valueReg, 
                    cache: allocICSlot()
                ))

            default: 
                fatalError("Unsupported value expression or .todo")
            }
        
        default:
            fatalError("Unsupported assignment operator")
        }

    
        return .assignment
    }

    func walkAssignmentTarget(_ target: AssignmentTarget) -> AssignmentTargetInfo {
        let id = allocNodeId()
        switch target {
            case .identifier(let name):
                return compileIdentifierAssignmentTarget(currentNodeId: id, name)

            case .member(let object, let property):
                return compileMemberAssignmentTarget(currentNodeId: id, object, property)
                
            case .computedMember(let object, let propertyExpr):
                return compileComputedMemberAssignmentTarget(currentNodeId: id, object, propertyExpr)
                
            case .destructuring(let pattern):
                // emit bytecode to compute the destructuring assignment and load it into the accumulator.
                return compileDestructuringAssignmentTarget(currentNodeId: id, pattern)
        }
    }


    
    func compileIdentifierAssignmentTarget(currentNodeId: Int, _ name: String) -> AssignmentTargetInfo {
        putDebugMark("Entered Identifier Assignment Target")

        let boundRef = compilationUnit.getBoundRefByNodeId(nodeId: currentNodeId)
        guard boundRef.kind == .Write else {
            fatalError("Identifier assignment target must be a write reference")
        }

        if case .none = boundRef.bindingId {
            // Unresolved identifier, treat as global property assignment
            let (cpIndex, _) = putRecordOnConstantsPool(name)
            return .identifier(.unresolved(Bytecode.CPIndex(rawValue: cpIndex)))
        }

        guard let bindingId = boundRef.bindingId else {
            fatalError("No binding found for identifier in assignment target")
        }
        
        let binding = compilationUnit.findBindingById(bindingId)
        guard let binding = binding else {
            fatalError("No binding found for identifier in assignment target")
        }

        guard let slot = binding.slot else {
            fatalError("No binding slot found for identifier in assignment target")
        }
        
        if binding.is_global {
            if case .lexical = binding.kind {
                return .identifier(.globalLexical(UInt16(slot)))
            } else {
                return .identifier(.globalVar(UInt16(slot)))
            }
        } else if boundRef.capturingDepth != 0 {
            return .identifier(.context(UInt8(boundRef.capturingDepth), UInt16(slot)))
        } else {
            return .identifier(.local(UInt16(slot)))
        }
    }

    func compileMemberAssignmentTarget(currentNodeId: Int, _ object: Expression, _ property: Expression) -> AssignmentTargetInfo {
        putDebugMark("Entered Member Assignment Target")
        
        let objectResult = walkExpression(object)
        
        guard case .expr(let objectReg) = objectResult else {
            fatalError("Unsupported expression result for member assignment target object")
        }

        let propertyResult = walkExpression(property, isPropertyKey: true)
        
        guard case .propertyKey(let propertyName) = propertyResult else {
            fatalError("Unsupported expression result for member assignment target property")
        }

        return .namedMember(objectReg, propertyName)
    }
    func compileComputedMemberAssignmentTarget(currentNodeId: Int, _ object: Expression, _ propertyExpr: Expression) -> AssignmentTargetInfo {
        putDebugMark("Entered Computed Member Assignment Target")

        let objectResult = walkExpression(object)
        guard case .expr(let objectReg) = objectResult else {
            fatalError("Unsupported expression result for computed member assignment target object")
        }
        
        let propertyResult = walkExpression(propertyExpr)
        guard case .expr(let propertyReg) = propertyResult else {
            fatalError("Unsupported expression result for computed member assignment target property") 
        }

        return .computedMember(objectReg, propertyReg)


    }

    func compileDestructuringAssignmentTarget(currentNodeId: Int, _ DestructuringPattern: DestructuringPattern) -> AssignmentTargetInfo {
        putDebugMark("Entered Destructuring Assignment Target")
        return .destructuring
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
        putDebugMark("Entered Function Declaration")
        if isAsync || isGenerator {
            fatalError("Async and generator functions not supported yet")
        }
        
        let (cpIndex, _) = putRecordOnConstantsPool(name)
        

        let funcId = allocFunctionId()
        let funcReg = allocRegister()
        
        let envReg = allocRegister()
        let scopeLayout = allocScopeLayout()

        emitOnTopLevel(.createLexicalEnvironment(dst: envReg, layout: scopeLayout))
        
        let functionBinding = compilationUnit.getBindingByNodeId(nodeId: currentNodeId)

        guard let slot = functionBinding.slot else {
            fatalError("No binding slot found for function declaration")
        }

        if VirtualCallStack.isEmpty {

            emitOnTopLevel(.createFunction(
                dst: funcReg, 
                function: funcId
            ), at: 2) // after the initial .enterGlobal and .createLexicalEnvironment for the global scope

            emitOnTopLevel(.initGlobalVar(
                slot: Bytecode.GlobalSlot(rawValue: UInt16(slot)),
                src: funcReg
            ), at: 3) // after the .createFunction
        
        } else {
            
            emitOnTopLevel(.createClosure(
                dst: funcReg,
                function: funcId, 
                environment: envReg
            ), at: 2) // same as above

            emitOnTopLevel(.initLocal(
                slot: Bytecode.LocalSlot(rawValue: UInt16(slot)),
                src: funcReg
            ), at: 3) // same as above
        }
                
        let (oldBlock, oldCP) = enterFunctionBBContext(funcId: funcId)
        
        emit(.enterFunction)
        emit(.pushLexicalEnvironment(environment: envReg))

        let paramInfos: [BytecodeCompiler.PatternBindingPlan] = if let parameters = params {
            parameters.map { walkPattern($0) }
        } else {
            []
        }
        
        if !paramInfos.isEmpty {
            paramInfos.forEach {
                
                let declInfos: [BytecodeCompiler.VariableDeclInfo] = applyPatternPlan(patternPlan: $0, exprResult: nil)
                let reg = allocRegister()
                for declInfo in declInfos {
                    emit(.getArgument(
                        dst: declInfo.reg ?? reg,
                        slot: allocArgumentSlot()
                    ))

                    emit(.initLocal(
                        slot: Bytecode.LocalSlot(rawValue: declInfo.slot),
                        src: declInfo.reg ?? reg
                    ))
                }
            }
        }

        do {
            walkStatement(body)
        }
        
        emit(.popLexicalEnvironment)
        emitTerminator(.return(nil))
        
        exitFunctionBBContext(oldBlock: oldBlock, oldCP: oldCP)
        resetArgumentSlots()

    }


    func compileClassDeclaration(currentNodeId: Int, _ name: String, _ superClass: Expression?, _ body: [ClassElement]) {
        putDebugMark("Entered Class Declaration")
    
    }

    func compileVariableDeclaration(currentNodeId: Int, _ decls: [VariableDeclarator]) {
        putDebugMark("Entered Variable Declaration")
        let varDeclKind: VarDeclKind = .var
        decls.forEach { decl in
            walkVariableDeclarator(declKind: varDeclKind, decl.id, decl.init_)
        }   

        
    }
    
    func compileLexicalDeclaration(currentNodeId: Int, _ kind: LexicalKind, _ decls: [VariableDeclarator]) {
        putDebugMark("Entered Lexical Declaration")

        let varDeclKind: VarDeclKind = {
            switch kind {
                case .let:
                    return .let
                case .const:
                    return .const
            }
        }()
        
        decls.forEach { decl in
            return walkVariableDeclarator(declKind: varDeclKind ,decl.id, decl.init_)
        }

    }

    func walkVariableDeclarator(declKind: VarDeclKind, _ pat: Pattern, _ initializer: Expression?)  {   
        putDebugMark("Entered Variable Declarator Walker")
        let currentNodeId = allocNodeId()   

        var varDeclInfos: [VariableDeclInfo]? = nil

        let patternPlan = walkPattern(pat)
        
        if let initializer = initializer {
            let initResult = walkExpression(initializer)
            varDeclInfos = applyPatternPlan(patternPlan: patternPlan, exprResult: initResult)
        }
        
        if let declInfos = varDeclInfos {
            
            
            declInfos.forEach { declInfo in
              
                if !(declInfo.isGlobal) {
                    
                    if case .var = declKind {
                        emitOnTopLevel(.initLocal(
                            slot: Bytecode.LocalSlot(rawValue: declInfo.slot),
                            src: declInfo.reg ?? universalCompilerUndefinedReg()
                        ))

                        
                    } else {
                        emit(.initLocal(
                            slot: Bytecode.LocalSlot(rawValue: declInfo.slot),
                            src: declInfo.reg ?? universalCompilerUndefinedReg()
                        ))
                    }
                    
                } else {

                    switch declKind {
                        case .var:
                            emitOnTopLevel(.initGlobalVar(
                                slot: Bytecode.GlobalSlot(rawValue: declInfo.slot),
                                src: declInfo.reg ?? universalCompilerUndefinedReg()
                            ))

                        case .let, .const:
                            emit(.initGlobalLexical(
                                slot: Bytecode.GlobalSlot(rawValue: declInfo.slot),
                                src: declInfo.reg ?? universalCompilerUndefinedReg()
                            ))
                    }
                }
            }
        }


    } 

    func applyPatternPlan (patternPlan: PatternBindingPlan, exprResult: ExprResult?) -> [VariableDeclInfo] {
        switch patternPlan {
            case .single(let singlePattern):
                return applySinglePattern(singlePattern: singlePattern, exprResult: exprResult)
            case .array(let elementPlans):
                return applyArrayPattern(elementPlans: elementPlans, exprResult: exprResult)
            case .object(let propertyPlans):
                return applyObjectPattern(propertyPlans: propertyPlans, exprResult: exprResult)
            case .todo:
                return []
        }
    }

    func applySinglePattern(singlePattern: BytecodeCompiler.SinglePattern, exprResult: ExprResult?) -> [VariableDeclInfo] {
        

        var varDeclInfo = VariableDeclInfo(reg: Bytecode.Reg(rawValue: 0xFFFF), slot: 0, isGlobal: false) //dummy initialization value
        
        switch singlePattern {
            case .bindingSlot(let slot, let isGlobal):
                varDeclInfo.slot = slot
                varDeclInfo.isGlobal = isGlobal
            case .undefined:
                fatalError("Unexpected undefined pattern in applySinglePattern")
        }

        switch exprResult {
            case .expr(let reg):
                varDeclInfo.reg = reg
            case nil:
                varDeclInfo.reg = nil
            default:
                fatalError("Unsupported expression result for single pattern")
        }

        return [varDeclInfo]
    }

    func applyArrayPattern(elementPlans: [BytecodeCompiler.PatternBindingPlan], exprResult: ExprResult?) -> [VariableDeclInfo] {
        
        fatalError("Array pattern not implemented yet")    

    }

    func applyObjectPattern(propertyPlans: [Bytecode.CPIndex: BytecodeCompiler.PatternBindingPlan], exprResult: ExprResult?) -> [VariableDeclInfo] {
        fatalError("Object pattern not implemented yet")
    }
    

    func walkPattern(_ pattern: Pattern) -> PatternBindingPlan {
        let id = allocNodeId()
        switch pattern {
            case .bindingIdentifier(let name):
                return compileIdentifierPattern(currentNodeId: id, name)
            case .object(let properties):
                return compileObjectPattern(currentNodeId: id, properties)
            case .array(let elements):
                return compileArrayPattern(currentNodeId: id, elements)
            case .assignment(let left, let right):
                return compileAssignmentPattern(currentNodeId: id, left, right)
            case .rest(let argument):
                return compileRestElementPattern(currentNodeId: id, argument)
        }

    }
    func compileIdentifierPattern(currentNodeId: Int, _ name: String) -> PatternBindingPlan {
        let (cpIndex, _) = putRecordOnConstantsPool(name)
        
        let binding = compilationUnit.getBindingByNodeId(nodeId: currentNodeId)
        
        guard case .some = binding.slot else {
            fatalError("No binding slot found for identifier pattern")
        }
        
        let plan: PatternBindingPlan = .single(.bindingSlot(slot: UInt16(binding.slot!), isGlobal: binding.is_global))

        return plan

    }
    func compileObjectPattern(currentNodeId: Int, _ properties: [ObjectPatternProperty]) -> PatternBindingPlan {
        return .todo
    }
    func compileArrayPattern(currentNodeId: Int, _ elements: [ArrayPatternElement]) -> PatternBindingPlan {  
       
        return .todo 
    }

    func compileAssignmentPattern(currentNodeId: Int, _ left: Pattern, _ right: Expression) -> PatternBindingPlan {
        return .todo
    }

    
    func compileRestElementPattern(currentNodeId: Int, _ argument: Pattern) -> PatternBindingPlan {
        return .todo
    }
    func walkPropertyKey(_ propertyKey: PropertyKey) {
        let id = allocNodeId()
        switch propertyKey {
            case .identifier(let name):
                compileIdentifierPropertyKey(currentNodeId: id, name)
            case .literal:
                break
            case .computed(let expr):
                compileComputedPropertyKey(currentNodeId: id, expr)
        }
    }
    func compileIdentifierPropertyKey(currentNodeId: Int, _ name: String) {

    }
    func compileComputedPropertyKey(currentNodeId: Int, _ expr: Expression) {
        
    }
}

extension BytecodeCompiler {
    func exportSerializationUnit() -> SerializationUnit {
        serializationUnit.globalConstantsPool = GlobalConstantsPool
        serializationUnit.functionTable = functionTable
        serializationUnit.globalBasicBlocks = GlobalBasicBlocks
        return serializationUnit
    }
}


extension BytecodeCompiler: CustomStringConvertible {
    
    var description: String {
        var result = ""
        result += "=O================BYTECODE DUMP=================O=\n"
        result += "=== Global Basic Block ===\n"
        for block in GlobalBasicBlocks {
            result += "\(block)\n"
        }

        result += "=== Global Constants Pool ===\n"
        result += "\(GlobalConstantsPool)\n"
        
        result += "=== Function Table ===\n"
        for (funcId, codeBlock) in functionTable {
            result += "Function ID: \(funcId)\n"
            result += "\(codeBlock)\n"
        }
        
        return result
    }
    
}
    
