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