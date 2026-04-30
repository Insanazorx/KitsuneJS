class BytecodeCompiler {

    var compilationUnit: CompilationUnit
    var bytecodeCompilation: [Bytecode] = []
    var constantsPool: [String: UInt32] = [:]
    
    var currentBlock: BasicBlock 
    var BasicBlocks: [BasicBlock] = []
    var blockCounter: Int = 0

    var regCounter: UInt16 = 0
    var currentNodeId: Int = 0
    var ICSlotCounter: UInt16 = 0
    var ProfileSlotCounter: UInt16 = 0

    init(compilationUnit: CompilationUnit) {
        self.compilationUnit = compilationUnit
        self.currentBlock = BasicBlock(id: 0)
        self.BasicBlocks.append(self.currentBlock)
    }
}

extension BytecodeCompiler {

    
    func putRecordOnConstantsPool(_ value: String) -> (UInt32, Bool) {
        if let existingIndex = constantsPool[value] {
            return (existingIndex, true)
        } else {
            let newIndex = UInt32(constantsPool.count)
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
        let reg = Bytecode.Reg(rawValue: regCounter)
        regCounter += 1
        return reg
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
    func walkExpression(_ expr: Expression) -> ExprResult {
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
                return compileNudExpression(currentNodeId: id, expr)

            case .binary(let left, let op, let right):
                return compileBinaryExpression(currentNodeId: id, left, op, right)
            case .assignment(let target, let op, let value):
                return compileAssignmentExpression(currentNodeId: id, target, op, value)
            case .call(let callee, let arguments):
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
        let rightResult = walkExpression(right)
        
        let leftReg: Bytecode.Reg
        let rightReg: Bytecode.Reg
        
        let resultReg = allocRegister()
        let ProfileSlot = allocProfileSlot()

        switch (leftResult, rightResult) {
            case (.expr(let lReg), .expr(let rReg)):
                leftReg = lReg
                rightReg = rReg
            default:
                fatalError("Unsupported expression result for binary expression")
        }

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
        return .todo
    }
    func compileComputedMemberExpression(currentNodeId: Int, _ object: Expression, _ propertyExpr: Expression) -> ExprResult {
        return .todo
    }
    func compileSequenceExpression(currentNodeId: Int, _ exprs: [Expression]) -> ExprResult {
        return .todo
    }
    func compileCallExpression(currentNodeId: Int, _ callee: Expression, _ arguments: [Expression]) -> ExprResult {
        return .todo
    }
    func compileNudExpression(currentNodeId: Int, _ expr: Expression) -> ExprResult {
        
        switch expr {
            case .identifier(let name):
                return compileIdentifierExpression(currentNodeId: currentNodeId, name)
                    
            case .literal(let literal):
                return compileLiteralExpression(currentNodeId: currentNodeId, literal)
            default:
                fatalError("Unsupported nud expression")
        }
    
    }

    func compileIdentifierExpression(currentNodeId: Int, _ name: String) -> ExprResult {
        
        let (cpIndex, isPresentAtPool) = putRecordOnConstantsPool(name)
        
        let resultReg: Bytecode.Reg = allocRegister()

        if isPresentAtPool { // in case of unknown identifier at compile time -> console.log
            emit(.loadConst(
                dst: resultReg,
                constant: Bytecode.CPIndex(rawValue: cpIndex)
            ))
        
        } else {
            
        }
        return .expr(resultReg)
    }

    func compileLiteralExpression(currentNodeId: Int, _ literal: Literal) -> ExprResult {
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
        return .todo
       
       
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
        
        return .todo
    }



    func compileMemberAssignmentTarget(currentNodeId: Int, _ object: Expression, _ property: Expression) -> AssignmentTargetInfo {

        return .todo
    }
    func compileComputedMemberAssignmentTarget(currentNodeId: Int, _ object: Expression, _ propertyExpr: Expression) -> AssignmentTargetInfo {
       return .todo
    }

    func compileDestructuringAssignmentTarget(currentNodeId: Int, _ DestructuringPattern: DestructuringPattern) -> AssignmentTargetInfo {
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

    }
    func compileClassDeclaration(currentNodeId: Int, _ name: String, _ superClass: Expression?, _ body: [ClassElement]) {
    
    }

    func compileVariableDeclaration(currentNodeId: Int, _ decls: [VariableDeclarator]) {
        let varDeclKind: VarDeclKind = .var
        decls.forEach { decl in
            walkVariableDeclarator(currentNodeId: currentNodeId, declKind: varDeclKind, decl.id, decl.init_)
        }   

        
    }
    
    func compileLexicalDeclaration(currentNodeId: Int, _ kind: LexicalKind, _ decls: [VariableDeclarator]) {

        let varDeclKind: VarDeclKind = {
            switch kind {
                case .let:
                    return .let
                case .const:
                    return .const
            }
        }()
        
        decls.forEach { decl in
            return walkVariableDeclarator(currentNodeId: currentNodeId, declKind: varDeclKind ,decl.id, decl.init_)
        }

    }

    func walkVariableDeclarator(currentNodeId: Int, declKind: VarDeclKind, _ pat: Pattern, _ initializer: Expression?)  {   
        
        var varDeclInfos: [VariableDeclInfo]? = nil

        let patternPlan = walkPattern(pat)
        
        if let initializer = initializer {
            let initResult = walkExpression(initializer)
            varDeclInfos = applyPatternPlan(patternPlan: patternPlan, exprResult: initResult)
        } 

        if let declInfos = varDeclInfos {
            declInfos.forEach { declInfo in

                if !(declInfo.isGlobal) {    
                    emit(.initLocal(
                        slot: Bytecode.LocalSlot(rawValue: declInfo.slot),
                        src: declInfo.reg
                    ))

                    
                } else {

                    switch declKind {
                        case .var:
                            emit(.initGlobalVar(
                                slot: Bytecode.GlobalSlot(rawValue: declInfo.slot),
                                src: declInfo.reg
                            ))

                        case .let, .const:
                            emit(.initGlobalLexical(
                                slot: Bytecode.GlobalSlot(rawValue: declInfo.slot),
                                src: declInfo.reg
                            ))
                        }
                }

            }
        }


    } 

    func applyPatternPlan (patternPlan: PatternBindingPlan, exprResult: ExprResult, directReg: Bytecode.Reg? = nil) -> [VariableDeclInfo] {
        switch patternPlan {
            case .single(let singlePattern):
                return applySinglePattern(singlePattern: singlePattern, exprResult: exprResult, directReg: directReg)
            case .array(let elementPlans):
                return applyArrayPattern(elementPlans: elementPlans, exprResult: exprResult)
            case .object(let propertyPlans):
                return applyObjectPattern(propertyPlans: propertyPlans, exprResult: exprResult)
            case .todo:
                return []
        }
    }

    func applySinglePattern(singlePattern: BytecodeCompiler.SinglePattern, exprResult: ExprResult, directReg: Bytecode.Reg? = nil) -> [VariableDeclInfo] {
        

        var varDeclInfo = VariableDeclInfo(reg: Bytecode.Reg(rawValue: 0xFFFF), slot: 0, isGlobal: false) //dummy initialization value
        
        switch singlePattern {
            case .bindingSlot(let slot, let isGlobal):
                varDeclInfo.slot = slot
                varDeclInfo.isGlobal = isGlobal
            case .undefined:
                fatalError("Unexpected undefined pattern in applySinglePattern")
        }
        
        if let directReg = directReg {
            varDeclInfo.reg = directReg
            return [varDeclInfo]
        }

        switch exprResult {
            case .expr(let reg):
                varDeclInfo.reg = reg
            default:
                fatalError("Unsupported expression result for single pattern")
        }

        return [varDeclInfo]
    }

    func applyArrayPattern(elementPlans: [BytecodeCompiler.PatternBindingPlan], exprResult: ExprResult) -> [VariableDeclInfo] {
        
        fatalError("applyArrayPattern not implemented yet")
        
    /*    
        var declInfos: [VariableDeclInfo] = []
        enum ElementAccessPlan {
            case directIndex(Int)
            case iterator
            case object
        }



        for p in elementPlans {
            let reg = allocRegister()
            switch p {
                case .single(let singlePattern):
                    declInfos += applySinglePattern(singlePattern: singlePattern, exprResult: exprResult, directReg: reg)
                case .array(let nestedElementPlans):
                    declInfos += applyArrayPattern(elementPlans: nestedElementPlans, exprResult: exprResult)
                case .object(let propertyPlans):
                    declInfos += applyObjectPattern(propertyPlans: propertyPlans, exprResult: exprResult)
                case .todo:
                    break
            }
        }
        */
        

    }

    func applyObjectPattern(propertyPlans: [Bytecode.CPIndex: BytecodeCompiler.PatternBindingPlan], exprResult: ExprResult) -> [VariableDeclInfo] {
        return []
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
        let binding = compilationUnit.getBindingByNodeId(nodeId: currentNodeId)
        
        guard binding.slot != nil else {
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
    func printCompilationResult() {
        print("=== Bytecode ===")
        for block in BasicBlocks {
            print(block)
        }
        print("=== Constants Pool ===")
        for (value, index) in constantsPool {
            print("Index: \(index), Value: \(value)")
        }
    }
}
    