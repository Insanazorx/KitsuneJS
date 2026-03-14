class ASTLineerizer {
    public var descs: [String] = []
    var ast: ASTNode

    init(ast: ASTNode) {
        self.ast = ast
    }

    func linearize() -> [String] {
        descs.removeAll(keepingCapacity: true)
        return descs
    }

    func append(_ value: String) {
        descs.append(value)
    }
}

extension ASTLineerizer: NodeWalker {

    func handleBindingIdentifier(nodeId: Int, name: String) {
        
    }


    func handleProgram(nodeId: Int, node: Program) {
        append(node.justName)
    }

    func preStmt(nodeId: Int, node: Statement) -> Bool {
        append(node.justName)
        return true
    }

    func postStmt(nodeId: Int, node: Statement) {}

    func preExpr(nodeId: Int, node: Expression) -> Bool {
        append(node.justName)
        return true
    }

    func postExpr(nodeId: Int, node: Expression) {}

    func preDecl(nodeId: Int, node: Declaration) -> Bool {
        append(node.justName)
        return true
    }

    func postDecl(nodeId: Int, node: Declaration) {}

    func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool {
        append(node.justName)
        return true
    }

    func postObjProp(nodeId: Int, node: ObjectProperty) {}

    func preClassElem(nodeId: Int, node: ClassElement) -> Bool {
        append(node.justName)
        return true
    }

    func postClassElem(nodeId: Int, node: ClassElement) {}

    func preForInit(nodeId: Int, node: ForInit) -> Bool {
        append(node.justName)
        return true
    }

    func postForInit(nodeId: Int, node: ForInit) {}

    func preForEachLeft(nodeId: Int, node: ForEachLeft) -> Bool {
        append(node.justName)
        return true
    }

    func postForEachLeft(nodeId: Int, node: ForEachLeft) {}

    func prePattern(nodeId: Int, node: Pattern) -> Bool {
        append(node.justName)
        return true
    }

    func postPattern(nodeId: Int, node: Pattern) {}

    func preAssignmentTarget(nodeId: Int, node: AssignmentTarget) -> Bool {
        append(node.justName)
        return true
    }

    func postAssignmentTarget(nodeId: Int, node: AssignmentTarget) {}

    func prePropKey(nodeId: Int, node: PropertyKey) -> Bool {
        append(node.justName)
        return true
    }

    func postPropKey(nodeId: Int, node: PropertyKey) {}

    func preClassElemKey(nodeId: Int, node: ClassElementKey) -> Bool {
        append(node.justName)
        return true
    }

    func postClassElemKey(nodeId: Int, node: ClassElementKey) {}

    func preDestructuringPattern(nodeId: Int, node: DestructuringPattern) -> Bool {
        append(node.justName)
        return true
    }

    func postDestructuringPattern(nodeId: Int, node: DestructuringPattern) {}

    func preDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) -> Bool {
        append(node.justName)
        return true
    }

    func postDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) {}

    func preObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) -> Bool {
        append(node.justName)
        return true
    }

    func postObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) {}

    func preObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) -> Bool {
        append(node.justName)
        return true
    }

    func postObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) {}

    func preVariableDeclarator(nodeId: Int, node: VariableDeclarator) -> Bool {
        append(node.justName)
        return true
    }

    func postVariableDeclarator(nodeId: Int, node: VariableDeclarator) {}

    func preArrayElement(nodeId: Int, node: ArrayElement) -> Bool {
        append(node.justName)
        return true
    }

    func postArrayElement(nodeId: Int, node: ArrayElement) {}

    func preArrayPatternElement(nodeId: Int, node: ArrayPatternElement) -> Bool {
        append(node.justName)
        return true
    }

    func postArrayPatternElement(nodeId: Int, node: ArrayPatternElement) {}

    func preDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) -> Bool {
        append(node.justName)
        return true
    }

    func postDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) {}

    func handlePrimary(nodeId: Int, node: Expression) {
        // Primary expressions are already recorded in preExpr.
    }

    func handleIdentifier(nodeId: Int, name: String, isDecl: Bool) {
        append(Identifier.identifier(name).justName)
    }

    func specializedParamVisit(nodeId: Int, phase: PreOrPost, mode: CatchOrParam) -> Bool {
        return true
    }
}