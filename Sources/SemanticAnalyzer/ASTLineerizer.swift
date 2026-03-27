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

    func append(_ value: AnyNode) {
        
        compilationUnit.nodeIdToNode.append(value)
        
        switch value {
        case .program(let node):
            descs.append(node.justName)
        case .statement(let node):
            descs.append(node.justName)
        case .expression(let node):
            descs.append(node.justName)
        case .declaration(let node):
            descs.append(node.justName)
        case .objectProperty(let node):
            descs.append(node.justName)
        case .classElement(let node):
            descs.append(node.justName)
        case .forInit(let node):
            descs.append(node.justName)
        case .forEachLeft(let node):
            descs.append(node.justName)
        case .pattern(let node):
            descs.append(node.justName)
        case .assignmentTarget(let node):
            descs.append(node.justName)
        case .propKey(let node):
            descs.append(node.justName)
        case .classElemKey(let node):
            descs.append(node.justName)
        case .destructuringPattern(let node):
            descs.append(node.justName)
        case .destructuringObjectProperty(let node):
            descs.append(node.justName)
        case .objectPatternProperty(let node):
            descs.append(node.justName)
        case .variableDeclarator(let node):
            descs.append(node.justName)
        case .arrayElement(let node):
            descs.append(node.justName)
        case .arrayPatternElement(let node):
            descs.append(node.justName)
        case .destructuringArrayPatternElement(let node):
            descs.append(node.justName)
        }


        
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
        append(.program(node))
    }

    func preStmt(nodeId: Int, node: Statement) -> Bool {
        append(.statement(node))
        return true
    }

    func postStmt(nodeId: Int, node: Statement) {}

    func preExpr(nodeId: Int, node: Expression) -> Bool {
        append(.expression(node))
        return true
    }

    func postExpr(nodeId: Int, node: Expression) {}

    func preDecl(nodeId: Int, node: Declaration) -> Bool {
        append(.declaration(node))
        return true
    }

    func postDecl(nodeId: Int, node: Declaration) {}

    func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool {
        append(.objectProperty(node))
        return true
    }

    func postObjProp(nodeId: Int, node: ObjectProperty) {}

    func preClassElem(nodeId: Int, node: ClassElement) -> Bool {
        append(.classElement(node))
        return true
    }

    func postClassElem(nodeId: Int, node: ClassElement) {}

    func preForInit(nodeId: Int, node: ForInit) -> Bool {
        append(.forInit(node))
        return true
    }

    func postForInit(nodeId: Int, node: ForInit) {}

    func preForEachLeft(nodeId: Int, node: ForEachLeft) -> Bool {
        append(.forEachLeft(node))
        return true
    }

    func postForEachLeft(nodeId: Int, node: ForEachLeft) {}

    func prePattern(nodeId: Int, node: Pattern) -> Bool {
        append(.pattern(node))
        return true
    }

    func postPattern(nodeId: Int, node: Pattern) {}

    func preAssignmentTarget(nodeId: Int, node: AssignmentTarget) -> Bool {
        append(.assignmentTarget(node))
        return true
    }

    func postAssignmentTarget(nodeId: Int, node: AssignmentTarget) {}

    func prePropKey(nodeId: Int, node: PropertyKey) -> Bool {
        append(.propKey(node))
        return true
    }

    func postPropKey(nodeId: Int, node: PropertyKey) {}

    func preClassElemKey(nodeId: Int, node: ClassElementKey) -> Bool {
        append(.classElemKey(node))
        return true
    }

    func postClassElemKey(nodeId: Int, node: ClassElementKey) {}

    func preDestructuringPattern(nodeId: Int, node: DestructuringPattern) -> Bool {
        append(.destructuringPattern(node))
        return true
    }

    func postDestructuringPattern(nodeId: Int, node: DestructuringPattern) {}

    func preDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) -> Bool {
        append(.destructuringObjectProperty(node))
        return true
    }

    func postDestructingObjectProperty(nodeId: Int, node: DestructuringObjectProperty) {}

    func preObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) -> Bool {
        append(.objectPatternProperty(node))
        return true
    }

    func postObjectPatternProperty(nodeId: Int, node: ObjectPatternProperty) {}

    func preObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) -> Bool {
        append(.propKey(node))
        return true
    }

    func postObjectPatternPropertyKey(nodeId: Int, node: PropertyKey) {}

    func preVariableDeclarator(nodeId: Int, node: VariableDeclarator) -> Bool {
        append(.variableDeclarator(node))
        return true
    }

    func postVariableDeclarator(nodeId: Int, node: VariableDeclarator) {}

    func preArrayElement(nodeId: Int, node: ArrayElement) -> Bool {
        append(.arrayElement(node))
        return true
    }

    func postArrayElement(nodeId: Int, node: ArrayElement) {}

    func preArrayPatternElement(nodeId: Int, node: ArrayPatternElement) -> Bool {
        append(.arrayPatternElement(node))
        return true
    }

    func postArrayPatternElement(nodeId: Int, node: ArrayPatternElement) {}

    func preDestructuringArrayPatternElement(nodeId: Int, node: DestructuringArrayPatternElement) -> Bool {
        append(.destructuringArrayPatternElement(node))
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