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

    var bindings: [Int] = []
    var boundRefs: [Int] = []
    
}

public class ScopeBuilder {

    var compilationUnit: CompilationUnit? = nil

    private var scopestack: [Scope] = []
    private var funcIdStack: [Int] = []
}

extension ScopeBuilder {

    func createNewScope(nodeId: Int, kind: ScopeKind, ownerFunctionId: Int?) -> Scope {
        let newScopeId = compilationUnit?.scopes.count ?? -1
        let parentId = scopestack.last?.id
        let newScope = Scope(id: newScopeId, nodeId: nodeId, kind: kind, ownerFunctionId: ownerFunctionId, parentId: parentId, childIds: [])
        return newScope
    }

    private func addChildScope(childId: Int) {
        if scopestack.isEmpty {
            fatalError("Cannot add child scope with id \(childId) because there is no parent scope in the stack")
        }
        guard let parentId = scopestack.last?.id else { fatalError("No parent scope found for child scope with id \(childId)") }
        if let index = compilationUnit?.scopes.firstIndex(where: { $0.id == parentId }) {
            compilationUnit?.scopes[index].childIds.append(childId)
        } else {
            fatalError("Parent scope with id \(parentId) not found in compilationUnit?.scopes list")
        }
    }

    private func enterGlobalScope(nodeId: Int) {
        let globalScope = Scope(id: 0, nodeId: nodeId, kind: .global, ownerFunctionId: nil, parentId: nil, childIds: [])
        compilationUnit?.scopes.append(globalScope)
        scopestack.append(globalScope)
    }
   
    private func enterScope(nodeId: Int, kind: ScopeKind) {
        
        let newScope = createNewScope(nodeId: nodeId, kind: kind, ownerFunctionId: funcIdStack.last)   
        addChildScope(childId: newScope.id)

        compilationUnit?.scopes.append(newScope)
        scopestack.append(newScope)
    }
 
    private func exitScope() {
        scopestack.removeLast()
    }

    private func enterFunction(nodeId: Int) {
        funcIdStack.append(nodeId)
    }

    private func exitFunction() {
        funcIdStack.removeLast()
    }

}



extension ScopeBuilder: NodeWalker {
    public func handleIdentifier(nodeId: Int, name: String, isDecl: Bool) {
        
    }

    public func preArrayElement(nodeId: Int, node: ArrayElement) -> Bool {
        return true
    }

    public func postArrayElement(nodeId: Int, node: ArrayElement) {
        
    }

    public func preArrayPatternElement(nodeId: Int, node: ArrayPatternElement) -> Bool {
        return true
    }

    public func postArrayPatternElement(nodeId: Int, node: ArrayPatternElement) {
        
    }

    public func preDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) -> Bool {
        return true
    }

    public func postDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) {
        
    }

    public func preForInit(nodeId: Int, node: ForInit) -> Bool {
        return true
    }

    public func postForInit(nodeId: Int, node: ForInit) {
        
    }

    public func preForEachLeft(nodeId: Int, node: ForEachLeft) -> Bool {
        return true
    }

    public func postForEachLeft(nodeId: Int, node: ForEachLeft) {
        
    }

    public func prePattern(nodeId: Int, node: Pattern) -> Bool {
        return true
    }

    public func postPattern(nodeId: Int, node: Pattern) {
        
    }

    public func preAssignmentTarget(nodeId: Int, node: AssignmentTarget) -> Bool {
        return true
    }

    public func postAssignmentTarget(nodeId: Int, node: AssignmentTarget) {
        
    }

    public func prePropKey(nodeId: Int, node: PropertyKey) -> Bool {
        return true
    }

    public func postPropKey(nodeId: Int, node: PropertyKey) {
        
    }

    public func preClassElemKey(nodeId: Int, node: ClassElementKey) -> Bool {
        return true
    }

    public func postClassElemKey(nodeId: Int, node: ClassElementKey) {
        
    }

    public func preDestructuringPattern(nodeId: Int, node: DestructuringPattern) -> Bool {
        return true
    }

    public func postDestructuringPattern(nodeId: Int, node: DestructuringPattern) {
        
    }

    public func preDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) -> Bool {
        return true
    }

    public func postDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) {
        
    }

    public func preObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) -> Bool {
        return true
    }

    public func postObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) {
        
    }

    public func preObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) -> Bool {
        return true
    }

    public func postObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) {
        
    }

    public func preVariableDeclarator(nodeId: Int, node: VariableDeclarator) -> Bool {
        return true
    }

    public func postVariableDeclarator(nodeId: Int, node: VariableDeclarator) {
        
    }

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
            case .functionExpression, .arrowFunction:
                enterScope(nodeId: nodeId, kind: .function)
                enterFunction(nodeId: nodeId)

            case .classExpression:
                enterScope(nodeId: nodeId, kind: .class)
            default:
                break
        }
        return true
    }
    public func postExpr(nodeId: Int, node: Expression) {
        switch node {
            case .functionExpression, .arrowFunction:
                exitScope()
                exitFunction()
            
            case .classExpression:
                exitScope()
            
            default:
                break
        }
    }
    public func preDecl(nodeId: Int, node: Declaration) -> Bool { 
        switch node {
            case .function:
                enterScope(nodeId: nodeId, kind: .function)
                enterFunction(nodeId: nodeId)
            case .class:
                enterScope(nodeId: nodeId, kind: .class)
            default:
                break
        }    
        return true
    }
    public func postDecl(nodeId: Int, node: Declaration) {
        switch node {
            case .function:
                exitScope()
                exitFunction()
            case .class:
                exitScope()
            default:
                break
        }
    }

    public func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool { 
        switch node {
            case .method, .getter, .setter:
                enterScope(nodeId: nodeId, kind: .function)
                enterFunction(nodeId: nodeId)
                
            default:
                break
        }
        return true
    }
    public func postObjProp(nodeId: Int, node: ObjectProperty) {
        switch node {
            case .method, .getter, .setter:
                exitScope()
                exitFunction()
            default:
                break
        }
    }

    public func preClassElem(nodeId: Int, node: ClassElement) -> Bool { 
        switch node {
            case .constructor, .member, .getter, .setter:
                enterScope(nodeId: nodeId, kind: .function)
                enterFunction(nodeId: nodeId)
            default:
                break
        }
        
        return true
    }
    public func postClassElem(nodeId: Int, node: ClassElement) {
        switch node {
            case .constructor, .member, .getter, .setter:
                exitScope()
                exitFunction()
            default:
                break
        }
    }

    public func handlePrimary(nodeId: Int, node: Expression) {}


    public func specializedParamVisit(nodeId: Int, 
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

    public func printDescription() {
        print (compilationUnit?.scopes[0].renderDescription(builder: self) ?? "No global scope found")
    }


}

extension ScopeBuilder {
    
    public func findScopeById(_ id: Int) -> Scope? {
        return compilationUnit?.scopes.first(where: { $0.id == id } )
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