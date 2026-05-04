// RefKind is determined syntactically at binding time (Binder) and then interpreted semantically (Resolver).
// Keeping it module-global allows both passes to share the same enum.
public enum Resolution {
    case unresolved
    case local
    case global
    case module
    case implicitGlobal   // sloppy + LHS assign
    case dynamic          // with / direct eval barrier
}

/// Resolver output is *semantic resolution* and legality checks.
/// It MUST NOT contain capture or layout addressing (depth/slot/cell).

public enum ResolverDiagnostic {
    case tdzViolation
    case illegalConstWrite
    case unresolvedInStrictMode
    case illegalDeleteInStrictMode
    case dynamicScopeBarrier
}

extension ResolverDiagnostic: CustomStringConvertible {
    public var description: String {
        switch self {
        case .tdzViolation:
            return "TDZ_Violation"
        case .illegalConstWrite:
            return "illegalConstWrite"
        case .unresolvedInStrictMode:
            return "unresolvedInStrictMode"
        case .illegalDeleteInStrictMode:
            return "illegalDeleteInStrictMode"
        case .dynamicScopeBarrier:
            return "dynamicScopeBarrier"
        }
    }
}


public class Resolver {
    
    var compilationUnit: CompilationUnit
    
    public init(_ compilationUnit: CompilationUnit) {
        self.compilationUnit = compilationUnit
    }
    

}

extension Resolver: NodeWalker {

    public func specializedBindingVisit(nodeId: Int, type: AnyNode) -> Bool {
        return true
    }

    public func handleDeclIdentifier(nodeId: Int, name: String) {
        // This will be handled in DeclBinder, so we can ignore it here.
    }

    public func handleRefIdentifier(nodeId: Int, name: String) {
        // This will be handled in Resolver, so we can ignore it here.
    }

    public func handleBindingIdentifier(nodeId: Int, name: String) {
    
    }
    
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

    public func handleProgram(nodeId: Int, node: Program) {}

    public func preStmt(nodeId: Int, node: Statement) -> Bool {return true}
    public func postStmt(nodeId: Int, node: Statement) {}

    public func preExpr(nodeId: Int, node: Expression) -> Bool {return true}
    public func postExpr(nodeId: Int, node: Expression) {}

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