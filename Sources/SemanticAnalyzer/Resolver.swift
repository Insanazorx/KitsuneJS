public enum ResolvedRef {}

struct Resolver {

}

extension Resolver: NodeWalker {
    func handleProgram(node: Program) {
        // Implementation goes here
    }

    func preStmt(node: Statement) -> Bool {
        return true
    }
    func postStmt(node: Statement) {
        // Implementation goes here
    }

    func preExpr(node: Expression) -> Bool {
        return true
    }
    func postExpr(node: Expression) {
        // Implementation goes here
    }

    func preDecl(node: Declaration) -> Bool {
        return true
    }
    func postDecl(node: Declaration) {
        // Implementation goes here
    }

    func preObjProp(node: ObjectProperty) -> Bool {
        return true
    }
    func postObjProp(node: ObjectProperty) {
        // Implementation goes here
    }

    func preClassElem(node: ClassElement) -> Bool {
        return true
    }
    func postClassElem(node: ClassElement) {
        // Implementation goes here
    }
    func handlePrimary(node: Expression) {
        // Implementation goes here
    }

    typealias CompilationComponent = [ResolvedRef?]
    func extract() -> CompilationComponent {
        return []
    }

    func printDescription() {
      
    }

}