class ASTLineerizer {
    public var descs: [String] = []
    public var compilationUnit: CompilationUnit
    var ast: ASTNode

    init(ast: ASTNode, compilationUnit: CompilationUnit) {
        self.ast = ast
        self.compilationUnit = compilationUnit
    }

    func linearize() -> [String] {
        descs.removeAll(keepingCapacity: true)
        return descs
    }

    func pushDescsToCU() {
        compilationUnit.descs = descs
    }

    func append(nodeId: Int, _ value: AnyNode) {
        
        compilationUnit.nodeIdToNode[nodeId] = value

        while descs.count <= nodeId {
            descs.append("<unmapped>")
        }
        
        let desc: String
        switch value {
        case .program(let node):
            desc = node.justName
        case .statement(let node):
            desc = node.justName
        case .expression(let node):
            desc = node.justName
        case .declaration(let node):
            desc = node.justName
        case .objectProperty(let node):
            desc = node.justName
        case .classElement(let node):
            desc = node.justName
        case .forInit(let node):
            desc = node.justName
        case .forEachLeft(let node):
            desc = node.justName
        case .pattern(let node):
            desc = node.justName
        case .assignmentTarget(let node):
            desc = node.justName
        case .propKey(let node):
            desc = node.justName
        case .classElemKey(let node):
            desc = node.justName
        case .destructuringPattern(let node):
            desc = node.justName
        case .destructuringObjectProperty(let node):
            desc = node.justName
        case .objectPatternProperty(let node):
            desc = node.justName
        case .variableDeclarator(let node):
            desc = node.justName
        case .arrayElement(let node):
            desc = node.justName
        case .arrayPatternElement(let node):
            desc = node.justName
        case .destructuringArrayPatternElement(let node):
            desc = node.justName
        }

        descs[nodeId] = desc
        
    }
}

extension ASTLineerizer: NodeWalker {

    func handleIdentifier(nodeId: Int, name: String, isDecl: Bool) {

    }

    func handleRefIdentifier(nodeId: Int, name: String) {
        
    }

    func handleDeclIdentifier(nodeId: Int, name: String) {
       
    }

    func specializedBindingVisit(nodeId: Int, type: AnyNode) -> Bool {
        return true
    }


    func handleBindingIdentifier(nodeId: Int, name: String) {

    }


    func handleProgram(nodeId: Int, node: Program) {
        append(nodeId: nodeId, .program(node))
    }

    func preStmt(nodeId: Int, node: Statement) -> Bool {
        append(nodeId: nodeId, .statement(node))
        return true
    }

    func postStmt(nodeId: Int, node: Statement) {}

    func preExpr(nodeId: Int, node: Expression) -> Bool {
        append(nodeId: nodeId, .expression(node))
        return true
    }

    func postExpr(nodeId: Int, node: Expression) {}

    func preDecl(nodeId: Int, node: Declaration) -> Bool {
        append(nodeId: nodeId, .declaration(node))
        return true
    }

    func postDecl(nodeId: Int, node: Declaration) {}

    func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool {
        append(nodeId: nodeId, .objectProperty(node))
        return true
    }

    func postObjProp(nodeId: Int, node: ObjectProperty) {}

    func preClassElem(nodeId: Int, node: ClassElement) -> Bool {
        append(nodeId: nodeId, .classElement(node))
        return true
    }

    func postClassElem(nodeId: Int, node: ClassElement) {}

    func preForInit(nodeId: Int, node: ForInit) -> Bool {
        append(nodeId: nodeId, .forInit(node))
        return true
    }

    func postForInit(nodeId: Int, node: ForInit) {}

    func preForEachLeft(nodeId: Int, node: ForEachLeft) -> Bool {
        append(nodeId: nodeId, .forEachLeft(node))
        return true
    }

    func postForEachLeft(nodeId: Int, node: ForEachLeft) {}

    func prePattern(nodeId: Int, node: Pattern) -> Bool {
        append(nodeId: nodeId, .pattern(node))
        return true
    }

    func postPattern(nodeId: Int, node: Pattern) {}

    func preAssignmentTarget(nodeId: Int, node: AssignmentTarget) -> Bool {
        append(nodeId: nodeId, .assignmentTarget(node))
        return true
    }

    func postAssignmentTarget(nodeId: Int, node: AssignmentTarget) {}

    func prePropKey(nodeId: Int, node: PropertyKey) -> Bool {
        append(nodeId: nodeId, .propKey(node))
        return true
    }

    func postPropKey(nodeId: Int, node: PropertyKey) {}

    func preClassElemKey(nodeId: Int, node: ClassElementKey) -> Bool {
        append(nodeId: nodeId, .classElemKey(node))
        return true
    }

    func postClassElemKey(nodeId: Int, node: ClassElementKey) {}

    func preDestructuringPattern(nodeId: Int, node: DestructuringPattern) -> Bool {
        append(nodeId: nodeId, .destructuringPattern(node))
        return true
    }

    func postDestructuringPattern(nodeId: Int, node: DestructuringPattern) {}

    func preDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) -> Bool {
        append(nodeId: nodeId, .destructuringObjectProperty(node))
        return true
    }

    func postDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) {}

    func preObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) -> Bool {
        append(nodeId: nodeId, .objectPatternProperty(node))
        return true
    }

    func postObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) {}

    func preObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) -> Bool {
        append(nodeId: nodeId, .propKey(node))
        return true
    }

    func postObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) {}

    func preVariableDeclarator(nodeId: Int, node: VariableDeclarator) -> Bool {
        append(nodeId: nodeId, .variableDeclarator(node))
        return true
    }

    func postVariableDeclarator(nodeId: Int, node: VariableDeclarator) {}

    func preArrayElement(nodeId: Int, node: ArrayElement) -> Bool {
        append(nodeId: nodeId, .arrayElement(node))
        return true
    }

    func postArrayElement(nodeId: Int, node: ArrayElement) {}

    func preArrayPatternElement(nodeId: Int, node: ArrayPatternElement) -> Bool {
        append(nodeId: nodeId, .arrayPatternElement(node))
        return true
    }

    func postArrayPatternElement(nodeId: Int, node: ArrayPatternElement) {}

    func preDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) -> Bool {
        append(nodeId: nodeId, .destructuringArrayPatternElement(node))
        return true
    }

    func postDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) {}

    func handlePrimary(nodeId: Int, node: Expression) {
        // Primary expressions are already recorded in preExpr.
    }

    func specializedParamVisit(nodeId: Int, phase: PreOrPost, mode: CatchOrParam) -> Bool {
        return true
    }
}
