

struct ScopeAnalyzer {
    var compilationUnit: CompilationUnit

    var astLineerizer: WalkerImpl<ASTLineerizer>
    var scopeBuilder: WalkerImpl<ScopeBuilder>
    var declBinder: WalkerImpl<DeclBinder>
    var refBinder: WalkerImpl<RefBinder>
    var resolver: WalkerImpl<Resolver>
    var captureAnalyzer: CaptureAnalyzer
    var slotAllocator: SlotAllocator
    
}

extension ScopeAnalyzer {

    public init (syntaxTree: ASTNode) {

        self.compilationUnit = CompilationUnit(ast: syntaxTree)
        self.astLineerizer = WalkerImpl(ASTLineerizer(ast: syntaxTree, compilationUnit: self.compilationUnit))
        self.scopeBuilder = WalkerImpl(ScopeBuilder(self.compilationUnit))
        self.declBinder = WalkerImpl(DeclBinder(self.compilationUnit))
        self.refBinder = WalkerImpl(RefBinder(self.compilationUnit))
        self.resolver = WalkerImpl(Resolver(self.compilationUnit))
        self.captureAnalyzer = CaptureAnalyzer(self.compilationUnit)
        self.slotAllocator = SlotAllocator(compilationUnit: self.compilationUnit)
    }

    mutating func analyze(){
        astLineerizer.walk(node: compilationUnit.ast)
        astLineerizer.walker.pushDescsToCU()

        scopeBuilder.walk(node: compilationUnit.ast)
        declBinder.walk(node: compilationUnit.ast)
        refBinder.walk(node: compilationUnit.ast)
        //resolver.walk(node: compilationUnit.ast)
        captureAnalyzer.analyze()
        slotAllocator.analyze()
        
    }

    func renderDescription(){
        compilationUnit.printLinearizedAST()
        print("-------------------------------------")
        print(compilationUnit.renderDescription())
    }

    func description() {
        print("ScopeAnalyzer")
    }
}



    


    