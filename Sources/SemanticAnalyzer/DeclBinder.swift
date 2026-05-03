public enum BindingKind: Equatable {
    case function
    case `class`
    case variable
    case lexical(isConst: Bool)
    case `catch`
    case param
    case module
    case with
    case none
}

public struct Binding {
    var kind: BindingKind
    var name: String
    var scopeId: Int
    var declNodeId: Int 
    var declOrder: Int // Şimdilik direk nodeId ye eşit olabilir, çünkü nodeId ler zaten sıralı ve benzersiz. Ancak ileride farklı bir ID sistemi gelirse diye ayrı bir sayaç tutmak mantıklı olabilir!

    var slot: Int? = nil
    

    var mutable: Bool = false 
    var has_tdz: Bool = false
    var is_hoisted: Bool = false 
    var is_global: Bool = false 
    var is_module: Bool = false 
    var is_implicit: Bool = false
}

/// What Binder produces for downstream passes.



public class DeclBinder {
    
    var compilationUnit: CompilationUnit
    
    var bindingContextStack: [BindingKind] = []
    private var currentBindingId: Int = 0

    var scopeCache: Scope? = nil 

    public init(_ compilationUnit: CompilationUnit) {
        self.compilationUnit = compilationUnit
    }

}

extension DeclBinder {
    private func allocBindingId() -> Int {
        let order = currentBindingId
        currentBindingId += 1
        return order
    }

    

    private func enterContext(kind: BindingKind) {
        bindingContextStack.append(kind)
        
    }

    private func exitContext() {
        bindingContextStack.removeLast()
    }


    private func hoistBinding(nodeId: Int) {
        
    }
}

extension DeclBinder {

func handleImportDecl(nodeId: Int, node: Declaration) {
    fatalError("Import declarations are not supported yet")
}

func handleExportDecl(nodeId: Int, node: Declaration) {
    fatalError("Export declarations are not supported yet")

}
}


    

extension DeclBinder: NodeWalker {
    public func specializedBindingVisit(nodeId: Int, type: AnyNode) -> Bool {
        return true
    }

    public func handleDeclIdentifier(nodeId: Int, name: String) {
        // For class and function decl or expr, identifier is handled in its own handler.
        
        let kind: BindingKind = if let currentContext = bindingContextStack.last {
                currentContext
            } else {
                .none // This means the identifier is a ref;
            }
        
        
        if case .none = kind {
            fatalError("TODO: No context for node:\(nodeId) -> Note:Ref identifiers should be handled in RefBinder, but found an identifier with no binding context in DeclBinder. This likely means there's a bug in the AST or the walker implementation.")
        }
        
        let bindingId = allocBindingId()
        let scopeId = compilationUnit.getScopeIdByNodeId(nodeId: nodeId)

        let mutable = kind == .variable || (kind == .lexical(isConst: false))
        let has_tdz = kind == .class || (kind == .lexical(isConst: true))
        let is_hoisted = kind == .variable
        let is_global = scopeId == 0 // global scope has id 0, but we will need to update this later for cases like global eval or global indirect eval where new bindings can be added to the global scope after the initial creation of the global scope.


        let binding = Binding(
            kind: kind,
            name: name,
            scopeId: scopeId,
            declNodeId: nodeId,
            declOrder: bindingId,
            mutable: mutable,
            has_tdz: has_tdz,
            is_hoisted: is_hoisted,
            is_global: is_global, // will be updated later if it's in global scope
            is_module: false, // will be updated later if it's in module scope
            is_implicit: false
        )
        compilationUnit.bindings.append(binding)
        compilationUnit.addBindingToScopeByLookingAstId(nodeId: nodeId, bindingId: bindingId)
    }

    public func handleRefIdentifier(nodeId: Int, name: String) {
        // This will be handled in Resolver, so we can ignore it here.
    }


    public func handleBindingIdentifier(nodeId: Int, name: String) {
         // For class and function decl or expr, identifier is handled in its own handler.
        
        let kind: BindingKind = if let currentContext = bindingContextStack.last {
            currentContext
        } else {    
            fatalError("BindingIdentifier found outside of any binding context. This should not happen, as BindingIdentifiers should only appear in specific patterns that are handled in their respective handlers.")
        }
        
        if case .none = kind {
            return // refs are handled in RefBinder, so we can ignore them here.
        }
        
        let bindingId = allocBindingId()
        let scopeId = compilationUnit.getScopeIdByNodeId(nodeId: nodeId)

        let mutable = kind == .variable || (kind == .lexical(isConst: false))
        let has_tdz = kind == .class || (kind == .lexical(isConst: true))
        let is_hoisted = kind == .variable
        let is_global = scopeId == 0 // global scope has id 0, but we will need to update this later for cases like global eval or global indirect eval where new bindings can be added to the global scope after the initial creation of the global scope.

        let binding = Binding(
            kind: kind,
            name: name,
            scopeId: scopeId,
            declNodeId: nodeId,
            declOrder: bindingId,
            mutable: mutable,
            has_tdz: has_tdz,
            is_hoisted: is_hoisted,
            is_global: is_global, // will be updated later if it's in global scope
            is_module: false, // will be updated later if it's in module scope
            is_implicit: false
        )
        compilationUnit.bindings.append(binding)
        compilationUnit.addBindingToScopeByLookingAstId(nodeId: nodeId, bindingId: bindingId)

    }

    public func preDecl(nodeId: Int, node: Declaration) -> Bool { 
        switch node {
            case .function:
                enterContext(kind: .function)
            case .class:
                enterContext (kind: .class)
            case .lexical(let lexicalKind, _):
                enterContext(kind: .lexical(isConst: lexicalKind == .const))
            case .variable:
                enterContext(kind: .variable)
            case .importDecl:
                handleImportDecl(nodeId: nodeId, node: node)
            case .exportDecl:
                handleExportDecl(nodeId: nodeId, node: node)
        }
        return true
    }
    public func postDecl(nodeId: Int, node: Declaration) {
        switch node {
            case .lexical:
                fallthrough
            case .variable:
                fallthrough
            case .importDecl:
                fallthrough // import declarations don't create bindings in the current scope, so no need to exit context
            case .exportDecl:
                exitContext()
            default:
                break
        }
    }


    public func specializedParamVisit(nodeId: Int, 
                                      phase: PreOrPost = .none,
                                      mode: CatchOrParam) -> Bool { 
        switch (phase, mode) {
            case (.pre, .catch):
                enterContext(kind: .catch)
            case (.post, .catch):
                exitContext()
            case (.pre, .param):
                enterContext(kind: .param)
            case (.post, .param):
                exitContext()
            default:
                break
        }
        return true 
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

    public func preExpr(nodeId: Int, node: Expression) -> Bool {
        
        return true
    }
    public func postExpr(nodeId: Int, node: Expression) {
    }

    
    public func preObjProp(nodeId: Int, node: ObjectProperty) -> Bool { return true}
    public func postObjProp(nodeId: Int, node: ObjectProperty) {}
 
    public func preClassElem(nodeId: Int, node: ClassElement) -> Bool { return true}
    public func postClassElem(nodeId: Int, node: ClassElement) {}

    public func handlePrimary(nodeId: Int, node: Expression) {}
    
    


}