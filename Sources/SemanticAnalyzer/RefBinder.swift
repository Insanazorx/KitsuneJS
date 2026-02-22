public enum RefKind {
    case Read             // x
    case Write            // x = 5
    case ReadWrite        // x += 1, x++
    case Delete           // delete x
    case ForInOf          // for (x in obj) / for (x of arr)
    case Typeof           // typeof x
}
/// Binder output for every identifier-like usage site.
/// This is *structural binding* (lookup result), not semantic legality.
public struct BoundRef {
    /// The nodeId of the identifier token/site in the AST.
    public var refNodeId: Int
    public var name: String
    public var kind: RefKind
    /// Index into `Binder.bindings` if resolved by lookup; nil if unresolved.
    public var bindingId: Int?
    /// The scope where this ref occurs (useful for diagnostics / later passes).
    public var refScopeId: Int
    
    public var isCaptured: Bool = false
    public var resolution: Resolution
    public var diagnostics: [ResolverDiagnostic]
}

public class RefBinder {

    var compilationUnit: CompilationUnit? = nil

    var refContextStack: [RefKind] = []
    private var currentBindingId: Int = 0
    
    var scopeCache: Scope? = nil  
    var bindingCache: Binding? = nil 

    
}


extension RefBinder {
    func allocBindingId() -> Int {
        let order = currentBindingId
        currentBindingId += 1
        return order
    }

    private func invalidateScopeCache() {
        scopeCache = nil
    }

    private func addBindingToScopeByLookingAstId(nodeId: Int, bindingId: Int) {
        if let cachedScope = scopeCache, cachedScope.nodeId == nodeId {
            compilationUnit?.scopes[cachedScope.id].bindings.append(bindingId)
            return
        }

        if let scopeIndex = compilationUnit?.scopes.firstIndex(where: { $0.nodeId == nodeId }) {
            compilationUnit?.scopes[scopeIndex].bindings.append(bindingId)
            scopeCache = compilationUnit?.scopes[scopeIndex]
        } else {
            // This should never happen if ScopeBuilder correctly attached scopeIds to all decl nodes.
            fatalError("DeclBinder: No scope found for decl nodeId \(nodeId)")
        }
    }

    private func getScopeIdForNodeId(nodeId: Int) -> Int {
        if let cachedScope = scopeCache, cachedScope.nodeId == nodeId {
            return cachedScope.id
        }

        if let scopeIndex = compilationUnit?.scopes.firstIndex(where: { $0.nodeId == nodeId }) {
            scopeCache = compilationUnit?.scopes[scopeIndex]
            return compilationUnit?.scopes[scopeIndex].id ?? -1
        } else {
            fatalError("DeclBinder: No scope found for nodeId \(nodeId)")
        }
    }

    private func addRefToScopeByLookingAstId(nodeId: Int, refId: Int) {
        if let cachedScope = scopeCache, cachedScope.nodeId == nodeId {
            compilationUnit?.scopes[cachedScope.id].boundRefs.append(refId)
            return
        }

        if let scopeIndex = compilationUnit?.scopes.firstIndex(where: { $0.nodeId == nodeId }) {
            compilationUnit?.scopes[scopeIndex].boundRefs.append(refId)
            scopeCache = compilationUnit?.scopes[scopeIndex]
        } else {
            fatalError("DeclBinder: No scope found for ref nodeId \(nodeId)")
        }
    }

    private func getBindingIdByName(name: String, scopeId: Int) -> Int? {
        
        //First check cache
        if let cachedBinding = bindingCache, cachedBinding.name == name, cachedBinding.scopeId == scopeId {
            return cachedBinding.declOrder
        } 

        // If cache miss, look up in 
        else if let cachedScope = scopeCache, cachedScope.id == scopeId {
            if let bindingId = cachedScope.bindings.first(where: { bindingId in
                if let binding = compilationUnit?.bindings.first(where: { $0.declOrder == bindingId }) {
                    return binding.name == name && binding.scopeId == scopeId
                }
                return false
            }) {
                bindingCache = compilationUnit?.bindings.first(where: { $0.declOrder == bindingId })
                return bindingId
            }
        }

        else if let bindingIndex = compilationUnit?.bindings.firstIndex(where: { $0.name == name && $0.scopeId == scopeId }) {
            bindingCache = compilationUnit?.bindings[bindingIndex]
            return compilationUnit?.bindings[bindingIndex].declOrder
        } 
        else {
            return nil
        }
        fatalError("VERIFY NOT REACHED: getBindingIdByName should have returned by now")
    } 




    private func enterContext(kind: RefKind) {
        refContextStack.append(kind)
        
    }

    private func exitContext() {
        refContextStack.removeLast()
    }





}
    




extension RefBinder: NodeWalker {
    public func handleIdentifier(nodeId: Int, name: String, isDecl: Bool) {
        if isDecl {
            // Declarations are handled in DeclBinder, so we can ignore them here.
            return
        }
        
        let kind: RefKind = if let currentContext = refContextStack.last {
            currentContext
        } else {
            .Read // Default to Read if we are not in any specific context. This is a common case for simple identifier usage.
        }

        let refId = allocBindingId()
        let scopeId = getScopeIdForNodeId(nodeId: nodeId)
        let bindingId = getBindingIdByName(name: name, scopeId: scopeId)
        let boundRef = BoundRef(
            refNodeId: nodeId,
            name: name,
            kind: kind,
            bindingId: bindingId,
            refScopeId: scopeId,
            resolution: .unresolved, // Will be updated during resolution in Resolver phase
            diagnostics: [] // Will be filled during resolution in Resolver phase
        )

        compilationUnit?.boundRefs.append(boundRef)
        addRefToScopeByLookingAstId(nodeId: nodeId, refId: refId)

    }

    public func preExpr(nodeId: Int, node: Expression) -> Bool {
        switch node {
        case .literal, .this:
            break
        case .identifier(let name):
            handleIdentifier(nodeId: nodeId, name: name, isDecl: false)
        case .privateIdentifier(let name):
            handleIdentifier(nodeId: nodeId, name: name, isDecl: false)
        
        case .assignment:
            enterContext(kind: .Write)
        
        case .binary (_, let op, _)
            where op == .binaryOp(.plusAssign) || op == .binaryOp(.minusAssign) || op == .binaryOp(.multiplyAssign) || op == .binaryOp(.divideAssign) :
            enterContext(kind: .Write)

        case .binary:
            enterContext(kind: .Read) 
        
        case .unary (let op,_,_)
            where op == .updateOp(.increment) || op == .updateOp(.decrement):
                enterContext(kind: .ReadWrite) 
            
        case .unary (let op,_,_)
            where op == .unaryOp(.delete):
                enterContext(kind: .Delete)

        case .unary (let op,_,_) 
            where op == .unaryOp(.typeof):
                enterContext(kind: .Typeof)

        default:
            break;
        
        }
        return true
    }
    public func postExpr(nodeId: Int, node: Expression) {
        switch node {
            default:
                exitContext()
        }
        
    }

    public func preForEachLeft(nodeId: Int, node: ForEachLeft) -> Bool {
        switch node {
            case .declaration:
                break;
            case .target:
                enterContext(kind: .ForInOf)
        }
        return true
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

    public func preDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) -> Bool {
        return true
    }

    public func postDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) {
        
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

    public func preForInit(nodeId: Int, node: ForInit) -> Bool {
        return true
    }

    public func postForInit(nodeId: Int, node: ForInit) {
        
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

    public func handleProgram(nodeId: Int, node: Program) {}

    public func preStmt(nodeId: Int, node: Statement) -> Bool {return true}
    public func postStmt(nodeId: Int, node: Statement) {}

    public func preDecl(nodeId: Int, node: Declaration) -> Bool { return true}
    public func postDecl(nodeId: Int, node: Declaration) {}

    public func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool { return true}
    public func postObjProp(nodeId: Int, node: ObjectProperty) {}
 
    public func preClassElem(nodeId: Int, node: ClassElement) -> Bool { return true}
    public func postClassElem(nodeId: Int, node: ClassElement) {}

    public func handlePrimary(nodeId: Int, node: Expression) {}
    
    public func specializedParamVisit(nodeId: Int, 
                                             phase: PreOrPost = .none,
                                             mode: CatchOrParam) -> Bool { return true }

    public func printDescription() {}


}