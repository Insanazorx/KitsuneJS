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
    var resolution: Resolution
    var name: String
    var depth: Int
    var binding: Int
    var isCaptured: Bool
}

public struct Resolver {

}

extension Resolver: NodeWalker {
    public mutating func preArrayElement(nodeId: Int, node: ArrayElement) -> Bool {
        return true
    }

    public mutating func postArrayElement(nodeId: Int, node: ArrayElement) {
        
    }

    public mutating func preArrayPatternElement(nodeId: Int, node: ArrayPatternElement) -> Bool {
        return true
    }

    public mutating func postArrayPatternElement(nodeId: Int, node: ArrayPatternElement) {
        
    }

    public mutating func preDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) -> Bool {
        return true
    }

    public mutating func postDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) {
        
    }

    public mutating func preForInit(nodeId: Int, node: ForInit) -> Bool {
        return true 
    }

    public mutating func postForInit(nodeId: Int, node: ForInit) {
        
    }

    public mutating func preForEachLeft(nodeId: Int, node: ForEachLeft) -> Bool {
        return true 
    }

    public mutating func postForEachLeft(nodeId: Int, node: ForEachLeft) {
        
    }

    public mutating func prePattern(nodeId: Int, node: Pattern) -> Bool {
        return true
    }

    public mutating func postPattern(nodeId: Int, node: Pattern) {
        
    }

    public mutating func preAssignmentTarget(nodeId: Int, node: AssignmentTarget) -> Bool {
        return true 
    }

    public mutating func postAssignmentTarget(nodeId: Int, node: AssignmentTarget) {
        
    }

    public mutating func prePropKey(nodeId: Int, node: PropertyKey) -> Bool {
        return true
    }

    public mutating func postPropKey(nodeId: Int, node: PropertyKey) {
        
    }

    public mutating func preClassElemKey(nodeId: Int, node: ClassElementKey) -> Bool {
        return true
    }

    public mutating func postClassElemKey(nodeId: Int, node: ClassElementKey) {
        
    }

    public mutating func preDestructuringPattern(nodeId: Int, node: DestructuringPattern) -> Bool {
        return true
    }

    public mutating func postDestructuringPattern(nodeId: Int, node: DestructuringPattern) {
        
    }

    public mutating func preDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) -> Bool {
        return true
    }

    public mutating func postDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) {
        
    }

    public mutating func preObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) -> Bool {
        return true
    }

    public mutating func postObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) {
        
    }

    public mutating func preObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) -> Bool {
        return true
    }

    public mutating func postObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) {
        
    }

    public mutating func preVariableDeclarator(nodeId: Int, node: VariableDeclarator) -> Bool {
        return true
    }

    public mutating func postVariableDeclarator(nodeId: Int, node: VariableDeclarator) {
        
    }

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