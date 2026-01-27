protocol NodeWalker {

    mutating func handleProgram(node: Program)

    mutating func preStmt(node: Statement) -> Bool
    mutating func postStmt(node: Statement)

    mutating func preExpr(node: Expression) -> Bool
    mutating func postExpr(node: Expression)

    mutating func preDecl(node: Declaration) -> Bool
    mutating func postDecl(node: Declaration)

    mutating func preObjProp(node: ObjectProperty) -> Bool
    mutating func postObjProp(node: ObjectProperty)

    mutating func preClassElem(node: ClassElement) -> Bool
    mutating func postClassElem(node: ClassElement) 

    mutating func handlePrimary(node: Expression)

    associatedtype CompilationComponent
    func extract() -> CompilationComponent

    func printDescription()

    
}

struct WalkerImpl<Walker: NodeWalker> {
    var walker: Walker
    
    mutating func walk(node: ASTNode){
        switch node {
        case .program (let program):
            walker.handleProgram(node: program)
            switch program {
                case .program(let body):
                    body.forEach { walkStatement($0) }

            }
        default:
            fatalError("Unsupported node type in walkImpl")

        }

        
        
    }

    mutating func walkStatement(_ stmt: Statement) {

        _ = walker.preStmt(node: stmt)

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

                catchDeclarations.forEach {
                    if let decl = $0 {
                        walkExpression(decl)
                    }
                }

                if let handler = handler {
                    walkStatement(handler)
                }

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

        walker.postStmt(node: stmt)
            
    }

    mutating func walkExpression(_ expr: Expression){

        _ = walker.preExpr(node: expr)

        switch expr {
            case .literal, .identifier, .privateIdentifier, .this :
                walker.handlePrimary(node: expr)
            
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
                fatalError("Not implementation yet")

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
                
                params.forEach { if let param = $0 {
                    walkExpression(param)
                } }

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
                
                params.forEach { if let param = $0 {
                    walkExpression(param)
                } }

                walkStatement(body)

            case .parenthesized(let expr):
                if let expr = expr {
                    walkExpression(expr)
                }

            case .objectLiteral(let properties):
                properties.forEach { walkObjProp($0) }
        }

        walker.postExpr(node: expr)
    }

    mutating func walkDeclaration(_ decl: Declaration){

        _ = walker.preDecl(node: decl)

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
                
                params.forEach { if let param = $0 {
                    walkExpression(param)
                } }

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

        walker.postDecl(node: decl)
    }

    func walkObjProp(_ property: ObjectProperty){
    }
    
    func walkClassElem(_ element: ClassElement){
    }

    func walkCaseStmt(_ caseStmt: CaseStatement){

    }

    func printDescription(){
        
    }
            
            
}