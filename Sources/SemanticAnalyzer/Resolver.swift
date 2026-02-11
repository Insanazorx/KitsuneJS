public enum RefKind {
    case Read             // x
    case Write            // x = 5
    case ReadWrite        // x += 1, x++
    case Delete           // delete x
    case Init             // let x = ... (initializer write, TDZ bypass)
    case ForInOf          // for (x in obj) / for (x of arr)
    case Typeof           // typeof x
}

public enum Resolution {
    case local
    case global
    case module
    case implicitGlobal   // sloppy + LHS assign
    case dynamic          // with / direct eval barrier
}

public struct ResolvedRef {
    var kind: RefKind
    var depth: Int
    var binding: Int
    var isCaptured: Bool
}

public struct Resolver {

}

extension Resolver: NodeWalker {
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

    public typealias CompilationComponent = [ResolvedRef]
    public func extract() -> CompilationComponent {return []}

    public func printDescription() {}


}