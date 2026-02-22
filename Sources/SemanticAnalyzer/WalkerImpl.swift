public enum PreOrPost {
    case none
    case pre
    case post
}

public protocol NodeWalker {

    mutating func handleProgram(nodeId: Int, node: Program)

    mutating func preStmt(nodeId: Int, node: Statement) -> Bool
    mutating func postStmt(nodeId: Int, node: Statement)

    mutating func preExpr(nodeId: Int, node: Expression) -> Bool
    mutating func postExpr(nodeId: Int, node: Expression)

    mutating func preDecl(nodeId: Int, node: Declaration) -> Bool
    mutating func postDecl(nodeId: Int, node: Declaration)

    mutating func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool
    mutating func postObjProp(nodeId: Int, node: ObjectProperty)

    mutating func preClassElem(nodeId: Int, node: ClassElement) -> Bool
    mutating func postClassElem(nodeId: Int, node: ClassElement)

    mutating func preForInit(nodeId: Int, node: ForInit) -> Bool
    mutating func postForInit(nodeId: Int, node: ForInit)

    mutating func preForEachLeft(nodeId: Int, node: ForEachLeft) -> Bool
    mutating func postForEachLeft(nodeId: Int, node: ForEachLeft)

    mutating func prePattern(nodeId: Int, node: Pattern) -> Bool
    mutating func postPattern(nodeId: Int, node: Pattern)

    mutating func preAssignmentTarget(nodeId: Int, node: AssignmentTarget) -> Bool
    mutating func postAssignmentTarget(nodeId: Int, node: AssignmentTarget)

    mutating func prePropKey(nodeId: Int, node: PropertyKey) -> Bool
    mutating func postPropKey(nodeId: Int, node: PropertyKey)

    mutating func preClassElemKey(nodeId: Int, node: ClassElementKey) -> Bool
    mutating func postClassElemKey(nodeId: Int, node: ClassElementKey)

    mutating func preDestructuringPattern(nodeId: Int, node: DestructuringPattern) -> Bool
    mutating func postDestructuringPattern(nodeId: Int, node: DestructuringPattern)

    mutating func preDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) -> Bool
    mutating func postDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty)

    mutating func preObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) -> Bool
    mutating func postObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty)

    mutating func preObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) -> Bool
    mutating func postObjectPatternPropertyKey(nodeId: Int, node: PropertyKey)

    mutating func preVariableDeclarator(nodeId: Int, node: VariableDeclarator) -> Bool
    mutating func postVariableDeclarator(nodeId: Int, node: VariableDeclarator)

    mutating func preArrayElement(nodeId: Int, node: ArrayElement) -> Bool
    mutating func postArrayElement(nodeId: Int, node: ArrayElement)

    mutating func preArrayPatternElement(nodeId: Int, node: ArrayPatternElement) -> Bool
    mutating func postArrayPatternElement(nodeId: Int, node: ArrayPatternElement)

    mutating func preDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) -> Bool
    mutating func postDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement)


    mutating func handlePrimary(nodeId: Int, node: Expression)
    mutating func handleIdentifier(nodeId: Int, name: String, isDecl: Bool)

    
    mutating func specializedParamVisit(nodeId: Int, 
                                               phase: PreOrPost,
                                               mode: CatchOrParam) -> Bool

    func printDescription()

    
}

public struct WalkerImpl<Walker: NodeWalker> {

    public init(walker: Walker) {
        self.nextNodeId = 0
        self.walker = walker
    }

    var walker: Walker
    
    private var nextNodeId: Int
    private mutating func allocNodeId() -> Int {
        let id = nextNodeId
        nextNodeId += 1
        return id
    }
    
    mutating func walk(node: ASTNode){
        switch node {
        case .program (let program):
            let pid = allocNodeId()
            walker.handleProgram(nodeId: pid, node: program)
            switch program {
                case .program(let body):
                    body.forEach { walkStatement($0) }

            }
        default:
            fatalError("Unsupported node type in walkImpl")

        }

        
        
    }

    mutating func walkIdentifier(_ identifier: Identifier) {
        let id = allocNodeId()
    }

    mutating func walkStatement(_ stmt: Statement) {
        let sid = allocNodeId()

        _ = walker.preStmt(nodeId: sid, node: stmt)

        switch stmt {
            case .block(let blockStmt):
                blockStmt.forEach { 
                    if let statement = $0 {
                        walkStatement(statement)
                    }  
                }
            
            case .declarationStatement(let decl):
                walkDeclaration(decl)
            
            case .expressionStatement(let expr):
                walkExpression(expr)
            
            case .ifStatement(let test,let consequent, let alternate):
                walkExpression(test)
                walkStatement(consequent)
                if let alternate = alternate {
                    walkStatement(alternate)
                }
            case .whileStatement(let test, let body):
                walkExpression(test)
                walkStatement(body) 
            
            case .doWhileStatement(let body, let test):
                walkStatement(body)
                walkExpression(test)
                
            case .forStatement( let initial, 
                                let test,
                                let update,
                                let body):
                if let initializer = initial {
                    walkForInit(initializer)
                }
                
                if let test = test {
                    walkExpression(test)
                }

                if let update = update {
                    walkExpression(update)
                }

                walkStatement(body)
            
            case .forInStatement(let left, let right, let body):
                
                walkForEachLeft(left)
                walkExpression(right)   
                walkStatement(body)

            case .forOfStatement(let left, let right, let body):
                walkForEachLeft(left)
                walkExpression(right)   
                walkStatement(body)

            case .forAwaitOfStatement(let left, let right, let body):
                
                walkForEachLeft(left)
                walkExpression(right)   
                walkStatement(body)

            case .returnStatement(let expr):
                if let expr = expr {
                    walkExpression(expr)
                }
            case .breakStatement(let label):
                if let label = label {
                    walkExpression(label)
                }
            case .continueStatement(let label):
                if let label = label {
                    walkExpression(label)
                }
            case .throwStatement(let expr):
                walkExpression(expr)

            case .tryStatement(let block, 
                               let catchDeclarations,
                               let handler, 
                               let finalizer):
                
                walkStatement(block)

                _ = walker.specializedParamVisit( // for catch clause processing
                        nodeId: sid, 
                        phase: .pre,
                        mode: .catch
                    )

                
                if let catchDecls = catchDeclarations {
                    catchDecls.forEach {
                        walkPattern($0)
                    }
                }

                if let handler = handler {
                    walkStatement(handler)
                }

                _ = walker.specializedParamVisit( // for catch clause processing
                        nodeId: sid, 
                        phase: .post,
                        mode: .catch
                    )

                if let finalizer = finalizer {
                    walkStatement(finalizer)
                }

            case .switchStatement(let discriminant, let cases):
                walkExpression(discriminant)
                cases.forEach {
                    walkCaseStmt($0)
                }
            case .labelledStatement(let label, let body):
                walkExpression(label)
                walkStatement(body)
            
            case .empty:
                break
            
        }

        walker.postStmt(nodeId: sid, node: stmt)
            
    }

    mutating func walkForInit(_ init: ForInit){
        let fid = allocNodeId()
        _ = walker.preForInit(nodeId: fid, node: `init`)
        
        switch `init` {
        case .declaration(let decl):
            walkDeclaration(decl)
        case .expression(let expr):
            walkExpression(expr)
        }

        walker.postForInit(nodeId: fid, node: `init`)
    }

    mutating func walkForEachLeft(_ left: ForEachLeft) {
        let fid = allocNodeId()
        _ = walker.preForEachLeft(nodeId: fid, node: left)

        switch left {
        case .declaration(let decl):
            walkDeclaration(decl)
        case .target(let expr):
            walkAssignmentTarget(expr)
        }

        walker.postForEachLeft(nodeId: fid, node: left)
    }

    mutating func walkExpression(_ expr: Expression){
        let eid = allocNodeId()

        _ = walker.preExpr(nodeId: eid, node: expr)

        switch expr {
            case .literal, .identifier, .privateIdentifier, .this :
                walker.handlePrimary(nodeId: eid, node: expr)
            
            case .binary(let left,  _ , let right):
                walkExpression(left)
                walkExpression(right)
            
            case .unary( _, let argument, _):
                walkExpression(argument)

            case .call (let callee, let arguments):
                walkExpression(callee)
                arguments.forEach { walkExpression($0) }
            
            case .member(let object,let property):
                walkExpression(object)
                walkExpression(property)

            case .computedMember(let object, let property):
                walkExpression(object)
                walkExpression(property)

            case .sequence(let expr):
                expr.forEach { walkExpression($0) }
            
            case .assignment(let left, _, let right):
                walkAssignmentTarget(left)
                walkExpression(right)

            case .new(let callee, let arguments):
                walkExpression(callee)
                arguments.forEach {
                    if let arg = $0 {
                        walkExpression(arg)
                    }
                }
            
            case .yield (let argument):
                if let argument = argument {
                    walkExpression(argument)
                }

            case .await (let argument):
                walkExpression(argument)

            case .arrayLiteral(let elements):
                elements.forEach { walkArrayElement($0) }

            case .functionExpression(let name,
                                    let params,
                                    let body,
                                    _,_):
                
                if let name = name {
                    walkIdentifier(name)
                }

                _ = walker.specializedParamVisit( // for function expression param scope processing
                        nodeId: eid, 
                        phase: .pre,
                        mode: .param
                    )
                
                if let params = params {
                    params.forEach { 
                        walkPattern($0)
                    }
                }

                _ = walker.specializedParamVisit( // for function expression param scope processing
                        nodeId: eid, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)

            case .classExpression(let name,
                               let superClass,
                               let body):
                
                if let name = name {
                    walkIdentifier(name)
                }
                
                if let superClass = superClass {
                    walkExpression(superClass)
                }
                
                body.forEach { walkClassElem($0) }

            case .arrowFunction(let params,
                                let body,
                                _):
                
                _ = walker.specializedParamVisit( // for arrow function param scope processing
                        nodeId: eid, 
                        phase: .pre,
                        mode: .param
                    )
                    if let params = params {
                        params.forEach { 
                            walkPattern($0)
                        }
                    }

                _ = walker.specializedParamVisit( // for arrow function param scope processing
                        nodeId: eid, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)

            case .parenthesized(let expr):
                if let expr = expr {
                    walkExpression(expr)
                }

            case .objectLiteral(let properties):
                properties.forEach { walkObjProp($0) }
        }

        walker.postExpr(nodeId: eid, node: expr)
    }

    mutating func walkArrayElement (_ element: ArrayElement) {
        let elementId = allocNodeId()
        _ = walker.preArrayElement(nodeId: elementId, node: element)

        switch element {
        case .element(let expr):
            walkExpression(expr)
        case .spread(let expr):
            walkExpression(expr)
        case .elision:
            break
        }
        walker.postArrayElement(nodeId: elementId, node: element)
    }

    mutating func walkDeclaration(_ decl: Declaration) {
        let did = allocNodeId()

        _ = walker.preDecl(nodeId: did, node: decl)

        switch decl {
            case .variable(let varDeclarators):
                
                varDeclarators.forEach {
                    walkVariableDeclarator($0)
                }
                

            case .lexical(_, let varDeclarators):
                
                varDeclarators.forEach {
                    walkVariableDeclarator($0)
                }
                
            
            case .function(let name,
                           let params,
                           let body,
                            _,_):

                
                walkIdentifier(name)
                

                _ = walker.specializedParamVisit( // for function declaration processing
                        nodeId: did, 
                        phase: .pre,
                        mode: .param
                    )
                
                if let params = params {
                    params.forEach {
                        walkPattern($0)
                    }
                }

                _ = walker.specializedParamVisit( // for function declaration processing
                        nodeId: did, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)

            case .class(let name,
                        let superClass,
                        let body):
                
                walkIdentifier(name)
                
                
                if let superClass = superClass {
                    walkExpression(superClass)
                }
                
                body.forEach { walkClassElem($0) }

            case .importDecl(let module,
                               let specifiers):
                walkExpression(module)
                specifiers.forEach { walkExpression($0) }
            
            case .exportDecl(let specifiers,let source):
                specifiers.forEach { walkExpression($0) }
                if let source = source {
                    walkExpression(source)
                }

        }

        walker.postDecl(nodeId: did, node: decl)
    }

    mutating func walkVariableDeclarator(_ decl: VariableDeclarator) {
        let vdId = allocNodeId()

        _ = walker.preVariableDeclarator(nodeId: vdId, node: decl)
        
        walkPattern(decl.id)
        if let initializer = decl.init_ {
            walkExpression(initializer)
        }
        walker.postVariableDeclarator(nodeId: vdId, node: decl)
    }

    mutating func walkObjProp(_ property: ObjectProperty){

        let opid = allocNodeId()
        
        _ = walker.preObjProp(nodeId: opid, node: property)
        
        switch property {
            case .property(key: let key, value: let value):
                walkPropKey(key)
                walkExpression(value)
            case .method(let key, let params, let body,
                        _,_):
                walkPropKey(key)
            
                _ = walker.specializedParamVisit( // for method property param scope processing
                        nodeId: opid, 
                        phase: .pre,
                        mode: .param
                    )

                if let params = params {
                    params.forEach {
                        walkPattern($0)
                    }
                }

                _ = walker.specializedParamVisit( // for method property param scope processing
                        nodeId: opid, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)
            case .shorthand(let key):
                walker.handleIdentifier(nodeId: opid, name: key, isDecl: false)
                

            case .spread(let arg):
                walkExpression(arg)

            case .getter(let key, let body):
                walkPropKey(key)
                walkStatement(body)

            case .setter(let key, let param, let body):
                walkPropKey(key)
                
                _ = walker.specializedParamVisit( // for setter property processing
                        nodeId: opid, 
                        phase: .pre,
                        mode: .param
                    )

                walkPattern(param)

                _ = walker.specializedParamVisit( // for setter property processing
                        nodeId: opid, 
                        phase: .post,
                        mode: .param
                    )
                
                walkStatement(body)

        }
        walker.postObjProp(nodeId: opid, node: property)
    }
    
    mutating func walkClassElem(_ element: ClassElement){
        let ceid = allocNodeId()
        
        _ = walker.preClassElem(nodeId: ceid, node: element)

        switch element {
            case .constructor(let params, let body):
                _ = walker.specializedParamVisit( 
                        nodeId: ceid, 
                        phase: .pre,
                        mode: .param
                    )
                if let params = params {
                    params.forEach { walkPattern($0) }
                }

                _ = walker.specializedParamVisit( 
                        nodeId: ceid, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)
            case .member(let key, let params, let body,
                         _,_,_):
                walkClassElemKey(key)

                let compactParams: [Pattern] = if let params = params {
                    params.compactMap { $0 }
                } else {
                    []
                }

                if !compactParams.isEmpty {
                    _ = walker.specializedParamVisit( 
                            nodeId: ceid, 
                            phase: .pre,
                            mode: .param
                        )

                    compactParams.forEach { walkPattern($0) }

                    _ = walker.specializedParamVisit( 
                            nodeId: ceid, 
                            phase: .post,
                            mode: .param
                        )
                }

                walkStatement(body)

            case .field(let key, let value,_):
                walkClassElemKey(key)
                if let value = value {
                    walkExpression(value)
                }
            
            case .getter(let key, let body, _):
                walkClassElemKey(key)
                walkStatement(body)
            
            case .setter (let key, let param, let body, _):
                walkClassElemKey(key)
                _ = walker.specializedParamVisit( 
                        nodeId: ceid, 
                        phase: .pre,
                        mode: .param
                    )
                walkPattern(param)
                _ = walker.specializedParamVisit( 
                        nodeId: ceid, 
                        phase: .post,
                        mode: .param
                    )
                walkStatement(body)

            case .staticBlock(let body):
                walkStatement(body)
            
            case .empty:
                break

        }

        walker.postClassElem(nodeId: ceid, node: element) 
    }

    mutating func walkCaseStmt(_ caseStmt: CaseStatement){

    }

    mutating func walkClassElemKey (_ key: ClassElementKey) {
        let keyId = allocNodeId()
        _ = walker.preClassElemKey(nodeId: keyId, node: key)
        
        switch key {
        case .privateName(let name):
            walkExpression(name)
        case .publicKey(let key):
            walkPropKey(key)
        }
        
        walker.postClassElemKey(nodeId: keyId, node: key)
    }


    mutating func walkPropKey(_ key: PropertyKey) {
        let keyId = allocNodeId()
        _ = walker.prePropKey(nodeId: keyId, node: key)


        switch key {
        case .identifier(let name):
            walker.handleIdentifier(nodeId: keyId, name: name, isDecl: true)
            
        case .literal:
            break

        case .computed(let value):
            walkExpression(value)
        }

        walker.postPropKey(nodeId: keyId, node: key)

    }
    
    mutating func walkObjPropKey(_ key: PropertyKey) {
        let keyId = allocNodeId()
        _ = walker.preObjectPatternPropertyKey(nodeId: keyId, node: key)

        switch key {
        case .identifier(let name):
            walker.handleIdentifier(nodeId: keyId, name: name, isDecl: true)
        case .literal:
            break
        case .computed(let value):
            walkExpression(value)
        }

        walker.postObjectPatternPropertyKey(nodeId: keyId, node: key)
    }

    mutating func walkAssignmentTarget(_ target: AssignmentTarget) {

        let targetId = allocNodeId()
        _ = walker.preAssignmentTarget(nodeId: targetId, node: target)

        switch target {
        case .identifier(let name):
            walker.handleIdentifier(nodeId: targetId, name: name, isDecl: false)

        case .member(let object, let property):
            walkExpression(object)
            walkExpression(property)
        
        case .computedMember(let object, let property):
            walkExpression(object)
            walkExpression(property)

        case .destructuring(let destPattern):
            walkDestructuringPattern(destPattern)
        }

        walker.postAssignmentTarget(nodeId: targetId, node: target)
    }

    mutating func walkDestructuringPattern(_ pattern: DestructuringPattern) {
        let patternId = allocNodeId()
        _ = walker.preDestructuringPattern(nodeId: patternId, node: pattern)

        switch pattern {
        case .object(let properties):
            properties.forEach { walkDestructuringObjectProperty($0) }
            
        case .array(let elements):
            elements.forEach { walkDestructuringArrayPatternElement($0)}
        case .rest(let target):
            walkAssignmentTarget(target)
        
        case .assignment(let target, let initExpr):
            walkAssignmentTarget(target)
            walkExpression(initExpr)
        
        case .target(let target):
            walkAssignmentTarget(target)
        }

        walker.postDestructuringPattern(nodeId: patternId, node: pattern)
    }

    mutating func walkDestructuringObjectProperty(_ element: DestructuringObjectProperty) {
            let elementId = allocNodeId()
            _ = walker.preDestructingObjectProperty(nodeId: elementId, node: element)


        switch element {
        case .property(let key, let value):
            walkPropKey(key)
            walkDestructuringPattern(value)
        case .rest(let target):
            walkAssignmentTarget(target)
        case .shorthand(let name):
            walker.handleIdentifier(nodeId: elementId, name: name, isDecl: true)
            

        }

        walker.postDestructingObjectProperty(nodeId: elementId, node: element)
    }

    mutating func walkPattern(_ pattern: Pattern) {

        let patternId = allocNodeId()
        _ = walker.prePattern(nodeId: patternId, node: pattern)


        switch pattern {
        case .bindingIdentifier(let name):
            walker.handleIdentifier(nodeId: patternId, name: name, isDecl: true)
            
        case .object(let properties):
            properties.forEach { walkObjectPatternProperty($0) }
        
        case .array(let elements):
            elements.forEach { walkArrayPatternElement($0) }

        case .rest(let target):
            walkPattern(target)
        
        case .assignment(let target, let initExpr):
            walkPattern(target)
            walkExpression(initExpr)
        }

        walker.postPattern(nodeId: patternId, node: pattern)
    }

    mutating func walkObjectPatternProperty(_ element: ObjectPatternProperty) {
        let elementId = allocNodeId()
        _ = walker.preObjectPatternProperty(nodeId: elementId, node: element)

        switch element {
        case .property(let key, let value):
            walkPropKey(key)
            walkPattern(value)
        case .rest(let target):
            walkPattern(target)
        case .shorthand(let name):
            walker.handleIdentifier(nodeId: elementId, name: name, isDecl: true)


        }

        walker.postObjectPatternProperty(nodeId: elementId, node: element)
    }


   

    mutating func walkArrayPatternElement(_ element: ArrayPatternElement) {
        let elementId = allocNodeId()
        _ = walker.preArrayPatternElement(nodeId: elementId, node: element)

        switch element {
        case .pattern(let pattern):
            walkPattern(pattern)
        case .elision:
            break
        }
        walker.postArrayPatternElement(nodeId: elementId, node: element)
    }

    mutating func walkDestructuringArrayPatternElement(_ element: DestructuringArrayPatternElement) {
        let elementId = allocNodeId()
        _ = walker.preDestructuringArrayPatternElement(nodeId: elementId, node: element)

        switch element {
        case .pattern(let pattern):
            walkDestructuringPattern(pattern)
        case .elision:
            break
        }
        walker.postDestructuringArrayPatternElement(nodeId: elementId, node: element)
    }



    func printDescription(){
        walker.printDescription()
    }
            
            
}