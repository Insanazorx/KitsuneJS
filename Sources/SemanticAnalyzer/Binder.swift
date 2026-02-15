public enum BindingKind{
    case global
    case function
    case block
    case `class`
    case module
    case `catch`
    case with
}

public struct Binding {
    var kind: BindingKind
    var name: String
    var scopeId: Int
    var declNodeId: Int
    var declOrder: Int
    var homeFunctionScopeId: Int?

    // StorageType
    var mutable: Bool = false 
    var has_tdz: Bool = false 
    var is_hoisted: Bool = false 
    var is_global: Bool = false 
    var is_module: Bool = false 
    var is_implicit: Bool = false
}

public class Binder {
    
}

    

extension Binder: NodeWalker {
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

    public func preExpr(nodeId: Int, node: Expression) -> Bool {
        
        return true
    }
    public func postExpr(nodeId: Int, node: Expression) {}

    public func preDecl(nodeId: Int, node: Declaration) -> Bool { return true}
    public func postDecl(nodeId: Int, node: Declaration) {}

    public func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool { return true}
    public func postObjProp(nodeId: Int, node: ObjectProperty) {}
 
    public func preClassElem(nodeId: Int, node: ClassElement) -> Bool { return true}
    public func postClassElem(nodeId: Int, node: ClassElement) {}

    public func handlePrimary(nodeId: Int, node: Expression) {}
    
    public func specializedScopeBuilderVisit(nodeId: Int, 
                                             phase: PreOrPost = .none,
                                             mode: CatchOrParam) -> Bool { return true }

    public typealias CompilationComponent = [Binding]
    public func extract() -> CompilationComponent {return []}

    public func printDescription() {}


}