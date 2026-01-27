

public struct CompilationUnit {

    public let ast: ASTNode

    public var bindings: [Binding] = []
    public var resolved: [ResolvedRef?] = []
    //public var funcCaptures: [[BindingId]] = []

    //public var layout: LayoutInfo? = nil

    public init(ast: ASTNode, bindings: [Binding], resolved: [ResolvedRef?]) {
        self.ast = ast
        self.bindings = bindings
        self.resolved = resolved
    }
}

extension CompilationUnit : CustomStringConvertible {
    public var description: String {
        return "CompilationUnit(ast: \(ast), bindings: \(bindings), resolved: \(resolved))"
    }
}

struct SemanticAnalyzer {
    public var syntaxTree: ASTNode
    var compilationUnit: CompilationUnit

    var idWrapper: WalkerImpl<IdWrapper>
    var scopeBuilder: WalkerImpl<ScopeBuilder>
    var binder: WalkerImpl<Binder>
    var resolver: WalkerImpl<Resolver>  
}

extension SemanticAnalyzer {

    public init (syntaxTree: ASTNode) {
        self.syntaxTree = syntaxTree

        self.compilationUnit = CompilationUnit(ast: syntaxTree , bindings: [], resolved: [])
        self.idWrapper = WalkerImpl(walker: IdWrapper())
        self.scopeBuilder = WalkerImpl(walker: ScopeBuilder())
        self.binder = WalkerImpl(walker: Binder())
        self.resolver = WalkerImpl(walker: Resolver())
    }

    mutating func analyze(){
        idWrapper.walk(node: syntaxTree)
        
    }

    func ExtractCompilationUnit() -> CompilationUnit {
        return compilationUnit
    }

    func description() {
        print("SemanticAnalyzer")
    }
}



    


    