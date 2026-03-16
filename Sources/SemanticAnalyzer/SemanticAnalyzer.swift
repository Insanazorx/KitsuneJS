

struct SemanticAnalyzer {
    var compilationUnit: CompilationUnit

    
    var scopeBuilder: WalkerImpl<ScopeBuilder>
    var declBinder: WalkerImpl<DeclBinder>
    var refBinder: WalkerImpl<RefBinder>
    var resolver: WalkerImpl<Resolver>
    var captureAnalyzer: CaptureAnalyzer
    
}

extension SemanticAnalyzer {

    public init (syntaxTree: ASTNode) {

        self.compilationUnit = CompilationUnit(ast: syntaxTree)
        self.scopeBuilder = WalkerImpl(ScopeBuilder(self.compilationUnit))
        self.declBinder = WalkerImpl(DeclBinder(self.compilationUnit))
        self.refBinder = WalkerImpl(RefBinder(self.compilationUnit))
        self.resolver = WalkerImpl(Resolver(self.compilationUnit))
        self.captureAnalyzer = CaptureAnalyzer(self.compilationUnit)
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



    


    