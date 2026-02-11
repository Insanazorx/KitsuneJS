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
    var homeFunctionScopeId: Int?
    // StorageType
    var mutable: Bool
    var has_tdz: Bool
    var is_hoisted: Bool
    var is_global: Bool
    var is_module: Bool
    var is_implicit: Bool
}

public struct Binder {
    

}

    

extension Binder: NodeWalker {
    public mutating func handleProgram(nodeId: Int, node: Program) {}

    public mutating func preStmt(nodeId: Int, node: Statement) -> Bool {return true}
    public mutating func postStmt(nodeId: Int, node: Statement) {}

    public mutating func preExpr(nodeId: Int, node: Expression) -> Bool {return true}
    public mutating func postExpr(nodeId: Int, node: Expression) {}

    public mutating func preDecl(nodeId: Int, node: Declaration) -> Bool { return true}
    public mutating func postDecl(nodeId: Int, node: Declaration) {}

    public mutating func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool { return true}
    public mutating func postObjProp(nodeId: Int, node: ObjectProperty) {}
 
    public mutating func preClassElem(nodeId: Int, node: ClassElement) -> Bool { return true}
    public mutating func postClassElem(nodeId: Int, node: ClassElement) {}

    public mutating func handlePrimary(nodeId: Int, node: Expression) {}
    
    public mutating func specializedScopeBuilderVisit(nodeId: Int, 
                                                      phase: PreOrPost = .none,
                                                      mode: CatchOrParam) -> Bool { return true }

    public typealias CompilationComponent = [Binding]
    public func extract() -> CompilationComponent {return []}

    public func printDescription() {}


}