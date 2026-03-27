public enum RefKind {
    case Read             // x
    case Write            // x = 5
    case ReadWrite        // x += 1, x++
    case Delete           // delete x
    case ForInOf          // for (x in obj) / for (x of arr)
    case Typeof           // typeof x
}

public enum StorageKind {
    case unknown
    case lexical
    case context
    case global
}

public struct BoundRef {
    
    public var refNodeId: Int
    public var name: String
    public var kind: RefKind
    /// Index into `Binder.bindings` if resolved by lookup; nil if unresolved.
    public var bindingId: Int?
    /// The scope where this ref occurs (useful for diagnostics / later passes).
    public var refScopeId: Int
    
    public var isCaptured: Bool = false
    public var capturingDepth: Int = 0 // 0 means not captured, >0 means captured and the number indicates how many scopes away the declaration is.
    
    public var storageKind: StorageKind = .unknown // Will be updated during resolution in Resolver phase

    public var resolution: Resolution
    public var diagnostics: [ResolverDiagnostic]
}

public class RefBinder {

    var compilationUnit: CompilationUnit

    var refContextStack: [RefKind] = []
    private var currentBindingId: Int = 0

    public init(_ compilationUnit: CompilationUnit) {
        self.compilationUnit = compilationUnit
    }
    
    
}


extension RefBinder {
    func allocBindingId() -> Int {
        let order = currentBindingId
        currentBindingId += 1
        return order
    }


    private func enterContext(kind: RefKind) {
        refContextStack.append(kind)
        
    }

    private func exitContext() {
        refContextStack.removeLast()
    }
}
    

extension RefBinder: NodeWalker {




    public func specializedBindingVisit(nodeId: Int, type: AnyNode) -> Bool {
        return true
    }

    public func handleDeclIdentifier(nodeId: Int, name: String) {
        // Declarations are handled in DeclBinder, so we can ignore them here.
    }

    public func handleRefIdentifier(nodeId: Int, name: String) {
        
        let kind: RefKind = if let currentContext = refContextStack.last {
            currentContext
        } else {
            .Read // Default to Read if we are not in any specific context. This is a common case for simple identifier usage.
        }

        let scopeId = compilationUnit.getScopeIdByNodeId(nodeId: nodeId)
        let bindingId = compilationUnit.getBindingIdByName(name: name, scopeId: scopeId)
        let storageKind: StorageKind = bindingId != nil ? .lexical : .unknown
        let boundRef = BoundRef(
            refNodeId: nodeId,
            name: name,
            kind: kind,
            bindingId: bindingId,
            refScopeId: scopeId,
            storageKind: storageKind,
            resolution: .unresolved, // Will be updated during resolution in Resolver phase
            diagnostics: [] // Will be filled during resolution in Resolver phase
        )

        compilationUnit.boundRefs.append(boundRef)
        compilationUnit.addRefToScopeByLookingAstId(nodeId: nodeId)
    }


    public func handleBindingIdentifier(nodeId: Int, name: String) {

    }

    public func handleIdentifier(nodeId: Int, name: String, isDecl: Bool) {
       
        

    }

    public func preExpr(nodeId: Int, node: Expression) -> Bool {
        switch node {
        case .identifier(let name):

            handleIdentifier(nodeId: nodeId, name: name, isDecl: false)
            
        case .privateIdentifier(let name):
            handleIdentifier(nodeId: nodeId, name: name, isDecl: false)
        
        case .assignment:
            enterContext(kind: .Read)
            
        
        case .binary (_, let op, _)
            where op == .binaryOp(.plusAssign) || op == .binaryOp(.minusAssign) || op == .binaryOp(.multiplyAssign) || op == .binaryOp(.divideAssign) :
            enterContext(kind: .Read)

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
                
            case .assignment:
                fallthrough
            case .binary:
                exitContext()
            case .binary (_, let op, _)
                where op == .binaryOp(.plusAssign) || op == .binaryOp(.minusAssign) || op == .binaryOp(.multiplyAssign) || op == .binaryOp(.divideAssign) :
                exitContext()
            case .unary (let op,_,_)
                where op == .updateOp(.increment) || op == .updateOp(.decrement):
                fallthrough
            case .unary (let op,_,_)
                where op == .unaryOp(.delete):
                fallthrough
            case .unary (let op,_,_)
                where op == .unaryOp(.typeof):
                exitContext()
                
            default:
                break;
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

    public func preAssignmentTarget(nodeId: Int, node: AssignmentTarget) -> Bool {
        return true
    }

    public func postAssignmentTarget(nodeId: Int, node: AssignmentTarget) {
    
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


}