enum NodeWithId {
    case WrappedProgram(id: Int, program: Program)
    case WrappedExpr(id: Int, expr: Expression)
    case WrappedStmt(id: Int, stmt: Statement)
    case WrappedDecl(id: Int, decl: Declaration)
    case WrappedObjProp(id: Int, property: ObjectProperty)
    case WrappedClassElem(id: Int, element: ClassElement)
}

extension NodeWithId : CustomStringConvertible{
    var description: String {
        switch self {
        case .WrappedProgram(let id, let program):
            return "[+] N\(id) -> \(program)"
        case .WrappedExpr(let id, let expr):
            return "[+] N\(id) -> \(expr)"
        case .WrappedStmt(let id, let stmt):
            return "[+] N\(id) -> \(stmt)"
        case .WrappedDecl(let id, let decl):
            return "[+] N\(id) -> \(decl)"
        case .WrappedObjProp(let id, let property):
            return "[+] N\(id) -> \(property)"
        case .WrappedClassElem(let id, let element):
            return "[+] N\(id) -> \(element)"
        }
    
    }
}

protocol IdWrapperHelpers {
    mutating func wrapProgram(_ program: Program)  
    mutating func wrapExpr(_ expr: Expression) 
    mutating func wrapStmt(_ stmt: Statement) 
    mutating func wrapDecl(_ decl: Declaration) 
    mutating func wrapObjProp(_ property: ObjectProperty) 
    mutating func wrapClassElem(_ element: ClassElement)
}

struct IdWrapper {
    private var currentId: Int = 0
    var nodesWrapped: [NodeWithId] = []    
}

extension IdWrapper: NodeWalker {
    mutating func handleProgram(node: Program) {
        wrapProgram(node)
    }

    mutating func preStmt(node: Statement) -> Bool {
        wrapStmt(node)
        return true
    }
    mutating func postStmt(node: Statement) {
        return
    }

    mutating func preExpr(node: Expression) -> Bool {
        wrapExpr(node)
        return true
    }
    mutating func postExpr(node: Expression) {
        return
    }

    mutating func preDecl(node: Declaration) -> Bool {
        wrapDecl(node)
        return true
    }
    mutating func postDecl(node: Declaration) {
        return
    }

    mutating func preObjProp(node: ObjectProperty) -> Bool {
        wrapObjProp(node)
        return true
    }
    mutating func postObjProp(node: ObjectProperty) {
        return
    }

    mutating func preClassElem(node: ClassElement) -> Bool {
        wrapClassElem(node)
        return true
    }
    mutating func postClassElem(node: ClassElement) {
        return
    }

    mutating func handlePrimary(node: Expression) {
        wrapExpr(node)
    }


    typealias CompilationComponent = [NodeWithId]
    func extract() -> CompilationComponent {
        return nodesWrapped
    }

    func printDescription() {
        print("----------------------------------------")
        print("IdWrapper with currentId: \(currentId)")
        nodesWrapped.forEach { node in
            print(node.description)
        }
        print("----------------------------------------")


    }
}


extension IdWrapper: IdWrapperHelpers {  

    mutating func wrapProgram(_ program: Program) {
        currentId += 1
        nodesWrapped.append(.WrappedProgram(id: currentId, program: program))
    }
    mutating func wrapExpr(_ expr: Expression) {
        currentId += 1
        nodesWrapped.append(.WrappedExpr(id: currentId, expr: expr))
    }
    mutating func wrapStmt(_ stmt: Statement) {
        currentId += 1
        nodesWrapped.append(.WrappedStmt(id: currentId, stmt: stmt))
    }
    mutating func wrapDecl(_ decl: Declaration) {
        currentId += 1
        nodesWrapped.append(.WrappedDecl(id: currentId, decl: decl))
    }
    mutating func wrapObjProp(_ property: ObjectProperty) {
        currentId += 1
        nodesWrapped.append(.WrappedObjProp(id: currentId, property: property))
    }
    mutating func wrapClassElem(_ element: ClassElement) {
        currentId += 1
        nodesWrapped.append(.WrappedClassElem(id: currentId, element: element))
    }
}


