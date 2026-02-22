
public class CompilationUnit {

    public let ast: ASTNode

    public var scopes: [Scope] = []
    public var bindings: [Binding] = []
    public var boundRefs: [BoundRef] = []
    //public var funcCaptures: [[BindingId]] = []

    //public var layout: LayoutInfo? = nil

    public init(ast: ASTNode) {
        self.ast = ast
    }
}

extension CompilationUnit : CustomStringConvertible {
    public var description: String {
        return "CompilationUnit(ast: \(ast), bindings: \(bindings), boundRefs: \(boundRefs))"
    }
}

struct SemanticAnalyzer {
    var compilationUnit: CompilationUnit

    
    var scopeBuilder: WalkerImpl<ScopeBuilder>
    var declBinder: WalkerImpl<DeclBinder>
    var refBinder: WalkerImpl<RefBinder>
    var resolver: WalkerImpl<Resolver>
}

extension SemanticAnalyzer {

    public init (syntaxTree: ASTNode) {

        self.compilationUnit = CompilationUnit(ast: syntaxTree)
        self.scopeBuilder = WalkerImpl(walker: ScopeBuilder())
        self.declBinder = WalkerImpl(walker: DeclBinder())
        self.refBinder = WalkerImpl(walker: RefBinder())
        self.resolver = WalkerImpl(walker: Resolver())
    }

    mutating func analyze(){
        
        
    }

    func ExtractCompilationUnit() -> CompilationUnit {
        return compilationUnit
    }

    func description() {
        print("SemanticAnalyzer")
    }
}



    


    