public enum ScopeKind {
    case global
    case block
    case function
    case param
    case `class`
    case `catch`
    case module
    case with
}

public enum CatchOrParam {
    case `catch`
    case param
}

public struct Scope {
    var id: Int
    var nodeId: Int
    var kind: ScopeKind
    var ownerFunctionId: Int?
    var parentId: Int?
    var childIds: [Int]
}

public class ScopeBuilder {
    private var scopeStack: [Scope] = []
    private var scopes: [Scope] = []
}

extension ScopeBuilder {

    func createNewScope(nodeId: Int, kind: ScopeKind) -> Scope {
        let newScopeId = scopes.count
        let parentId = scopeStack.last?.id
        let newScope = Scope(id: newScopeId, nodeId: nodeId, kind: kind, parentId: parentId, childIds: [])
        return newScope
    }

    private func addChildScope(childId: Int) {
        if scopeStack.isEmpty {
            fatalError("Cannot add child scope with id \(childId) because there is no parent scope in the stack")
        }
        guard let parentId = scopeStack.last?.id else { fatalError("No parent scope found for child scope with id \(childId)") }
        if let index = scopes.firstIndex(where: { $0.id == parentId }) {
            scopes[index].childIds.append(childId)
        } else {
            fatalError("Parent scope with id \(parentId) not found in scopes list")
        }
    }

    private func enterGlobalScope(nodeId: Int) {
        let globalScope = Scope(id: 0, nodeId: nodeId, kind: .global, parentId: nil, childIds: [])
        scopes.append(globalScope)
        scopeStack.append(globalScope)
    }
   
    private func enterScope(nodeId: Int, kind: ScopeKind) {
        
        let newScope = createNewScope(nodeId: nodeId, kind: kind)   
        addChildScope(childId: newScope.id)

        scopes.append(newScope)
        scopeStack.append(newScope)
    }
 
    private func exitScope() {
        scopeStack.removeLast()
    }

}



extension ScopeBuilder: NodeWalker {
    public func handleProgram(nodeId: Int, node: Program) {
        enterGlobalScope(nodeId: nodeId)
    }

    public func preStmt(nodeId: Int, node: Statement) -> Bool {
        switch node {
            case .block:
                enterScope(nodeId: nodeId, kind: .block)
            
            default:
                break
        }
        return true 
    }
    public func postStmt(nodeId: Int, node: Statement) {
        switch node {
            case .block:
                exitScope()
            default:
                break
        }
    }

    public func preExpr(nodeId: Int, node: Expression) -> Bool {
        switch node {
            case .functionExpression:
                enterScope(nodeId: nodeId, kind: .function)
            case .classExpression:
                enterScope(nodeId: nodeId, kind: .class)
            default:
                break
        }
        return true
    }
    public func postExpr(nodeId: Int, node: Expression) {
        switch node {
            case .functionExpression, .classExpression:
                exitScope()
            default:
                break
        }
    }
    public func preDecl(nodeId: Int, node: Declaration) -> Bool { 
        switch node {
            case .function:
                enterScope(nodeId: nodeId, kind: .function)
            case .class:
                enterScope(nodeId: nodeId, kind: .class)
            default:
                break
        }    
        return true
    }
    public func postDecl(nodeId: Int, node: Declaration) {
        switch node {
            case .function, .class:
                exitScope()
            default:
                break
        }
    }

    public func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool { return true}
    public func postObjProp(nodeId: Int, node: ObjectProperty) {}

    public func preClassElem(nodeId: Int, node: ClassElement) -> Bool { return true}
    public func postClassElem(nodeId: Int, node: ClassElement) {}

    public func handlePrimary(nodeId: Int, node: Expression) {}


    public func specializedScopeBuilderVisit(nodeId: Int, 
                                             phase: PreOrPost = .none,
                                             mode: CatchOrParam) -> Bool {
        switch (phase, mode) {
        case (.pre, .catch):
            enterScope(nodeId: nodeId, kind: .catch)
        case (.post, .catch):
            exitScope()
        case (.pre, .param):
            enterScope(nodeId: nodeId, kind: .param)
        case (.post, .param):
            exitScope()
        default: 
            break
        }   
        return true 
    }

    public typealias CompilationComponent = [Scope]
    public func extract() -> CompilationComponent {return scopes}

    public func printDescription() {
        print (scopes[0].renderDescription(builder: self))
    }


}

extension ScopeBuilder {
    
    public func findScopeById(_ id: Int) -> Scope? {
        return scopes.first(where: { $0.id == id } )
    }
    
}

extension Scope {
    
    // Since scope tree is meaningful only in the context of the entire scope builder, 
    // we need to pass the builder as it is not designed as a tree node structure but id based table.

    public func renderDescription(builder: ScopeBuilder) -> String {
        return renderTree(
            toTreeBox(builder: builder) 
        )
    }
        

    public func toTreeBox(builder: ScopeBuilder) -> TreeBox {
        box("Scope \(id)", [
            box("nodeId: \(nodeId)"),
            box("kind: \(kind)"),
            box("ownerFunctionId: \(ownerFunctionId.map(String.init) ?? "nil")"),
            box("parentId: \(parentId.map(String.init) ?? "nil")"),
            boxList("children", 
                childIds.map {childId in 
                    builder
                        .findScopeById(childId)?
                        .toTreeBox(builder: builder) 
                        ?? box("Scope \(childId) not found")
                }
            )
        ])
    }
}