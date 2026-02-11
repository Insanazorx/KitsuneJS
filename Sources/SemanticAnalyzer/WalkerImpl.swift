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

    mutating func handlePrimary(nodeId: Int, node: Expression)
    
    mutating func specializedScopeBuilderVisit(nodeId: Int, 
                                               phase: PreOrPost,
                                               mode: CatchOrParam) -> Bool

    associatedtype CompilationComponent
    func extract() -> CompilationComponent

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
                
            case .forStatement(let initDecl,
                                let initExpr, 
                                let test,
                                let update,
                                let body):
                if let initDecl = initDecl {
                    walkDeclaration(initDecl)
                }
                if let initExpr = initExpr {
                    walkExpression(initExpr)
                }
                if let test = test {
                    walkExpression(test)
                }
                if let update = update {
                    walkExpression(update)
                }
                walkStatement(body)
            
            case .forInStatement(let left, let leftExpr, let right, let body):
                if let left = left {    
                    walkDeclaration(left)
                }
                if let leftExpr = leftExpr {
                    walkExpression(leftExpr)
                }
                walkExpression(right)   
                walkStatement(body)
            case .forOfStatement(let left, let leftExpr, let right, let body):
                if let left = left {    
                    walkDeclaration(left)
                }
                if let leftExpr = leftExpr {
                    walkExpression(leftExpr)
                }
                walkExpression(right)   
                walkStatement(body)
            case .forAwaitOfStatement(let left, let leftExpr, let right, let body):
                if let left = left {    
                    walkDeclaration(left)
                }
                if let leftExpr = leftExpr {
                    walkExpression(leftExpr)
                }
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

                _ = walker.specializedScopeBuilderVisit( // for catch clause processing
                        nodeId: sid, 
                        phase: .pre,
                        mode: .catch
                    )

                catchDeclarations.forEach {
                    if let decl = $0 {
                        walkExpression(decl)
                    }
                }

                if let handler = handler {
                    walkStatement(handler)
                }

                _ = walker.specializedScopeBuilderVisit( // for catch clause processing
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
                walkExpression(left)
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
                elements.forEach { walkExpression($0) }

            case .functionExpression(let name,
                                    let params,
                                    let body,
                                    _,_):
                
                if let name = name {
                    walkExpression(name)
                }

                _ = walker.specializedScopeBuilderVisit( // for function expression param scope processing
                        nodeId: eid, 
                        phase: .pre,
                        mode: .param
                    )
                
                params.forEach { if let param = $0 {
                    walkExpression(param)
                } }

                _ = walker.specializedScopeBuilderVisit( // for function expression param scope processing
                        nodeId: eid, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)

            case .classExpression(let name,
                               let superClass,
                               let body):
                
                if let name = name {
                    walkExpression(name)
                }
                
                if let superClass = superClass {
                    walkExpression(superClass)
                }
                
                body.forEach { walkClassElem($0) }

            case .arrowFunction(let params,
                                let body,
                                _):
                
                _ = walker.specializedScopeBuilderVisit( // for arrow function param scope processing
                        nodeId: eid, 
                        phase: .pre,
                        mode: .param
                    )

                params.forEach { if let param = $0 {
                    walkExpression(param)
                } }

                _ = walker.specializedScopeBuilderVisit( // for arrow function param scope processing
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

    mutating func walkDeclaration(_ decl: Declaration){
        let did = allocNodeId()

        _ = walker.preDecl(nodeId: did, node: decl)

        switch decl {
            case .variable(let declarations, 
                            let assignments):
                
                declarations.forEach {
                    if let decl = $0 {
                        walkExpression(decl)
                    }}
                
                if let assignments = assignments {
                    assignments.forEach {
                        walkExpression($0)
                    }
                }

            case .lexical(_, let declarations, 
                            let assignments):
                
                declarations.forEach {
                    if let decl = $0 {
                        walkExpression(decl)
                    }}
                
                if let assignments = assignments {
                    assignments.forEach {
                        walkExpression($0)
                    }
                }
            
            case .function(let name,
                           let params,
                           let body,
                            _,_):

                if let name = name {
                    walkExpression(name)
                }

                _ = walker.specializedScopeBuilderVisit( // for function declaration processing
                        nodeId: did, 
                        phase: .pre,
                        mode: .param
                    )
                
                params.forEach { if let param = $0 {
                    walkExpression(param)
                } }

                _ = walker.specializedScopeBuilderVisit( // for function declaration processing
                        nodeId: did, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)

            case .class(let name,
                                  let superClass,
                                  let body):
                if let name = name {
                    walkExpression(name)
                }
                
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
            
                _ = walker.specializedScopeBuilderVisit( // for method property param scope processing
                        nodeId: opid, 
                        phase: .pre,
                        mode: .param
                    )

                params.forEach { if let param = $0 {
                    walkExpression(param)
                } }

                _ = walker.specializedScopeBuilderVisit( // for method property param scope processing
                        nodeId: opid, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)
            case .shorthand(let key):
                walkPropKey(key)

            case .spread(let arg):
                walkExpression(arg)

            case .getter(let key, let body):
                walkPropKey(key)
                walkStatement(body)

            case .setter(let key, let param, let body):
                walkPropKey(key)
                
                _ = walker.specializedScopeBuilderVisit( // for setter property processing
                        nodeId: opid, 
                        phase: .pre,
                        mode: .param
                    )

                walkExpression(param)

                _ = walker.specializedScopeBuilderVisit( // for setter property processing
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
                _ = walker.specializedScopeBuilderVisit( 
                        nodeId: ceid, 
                        phase: .pre,
                        mode: .param
                    )

                params.forEach { if let param = $0 {
                    walkExpression(param)
                } }

                _ = walker.specializedScopeBuilderVisit( 
                        nodeId: ceid, 
                        phase: .post,
                        mode: .param
                    )

                walkStatement(body)
            case .member(let key, let params, let body,
                         _,_,_):
                walkClassElemKey(key)

                let compactParams = params.compactMap { $0 }
                if !compactParams.isEmpty {
                    _ = walker.specializedScopeBuilderVisit( 
                            nodeId: ceid, 
                            phase: .pre,
                            mode: .param
                        )

                    compactParams.forEach { walkExpression($0) }

                    _ = walker.specializedScopeBuilderVisit( 
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
                _ = walker.specializedScopeBuilderVisit( 
                        nodeId: ceid, 
                        phase: .pre,
                        mode: .param
                    )
                walkExpression(param)
                _ = walker.specializedScopeBuilderVisit( 
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
        switch key {
        case .privateName(let name):
            walkExpression(name)
        case .publicKey(let key):
            walkPropKey(key)
        }
    }


    mutating func walkPropKey(_ key: PropertyKey) {
        switch key {
        case .identifier:
            break
        case .literal:
            break
        case .computed(let value):
            walkExpression(value)
        }

    }



    func printDescription(){
        walker.printDescription()
    }
            
            
}