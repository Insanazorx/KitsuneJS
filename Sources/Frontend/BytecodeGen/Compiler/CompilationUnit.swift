public class CompilationUnit {

    public let ast: ASTNode

    public var scopes: [Scope] = []
    public var bindings: [Binding] = []
    public var boundRefs: [BoundRef] = []

    public var scopeCache: Scope? = nil
    public var bindingCache: Binding? = nil
    public var boundRefCache: BoundRef? = nil

    public var nodeIdToScopeId: [Int] = []
    public var nodeIdToNode: [Int: AnyNode] = [:]
    public var descs: [String] = []
    

    public init(ast: ASTNode) {
        self.ast = ast
    }
}

extension CompilationUnit {

    func getBindingByNodeId(nodeId: Int) -> Binding {
        
        let scopeId = nodeIdToScopeId[nodeId] 
        
        let scope = scopes[scopeId]
        
        if let bindingId = scope.bindings.first(where: { bindings[$0].declNodeId == nodeId }) {
            return bindings[bindingId]
        }
        
        fatalError("There must have been a binding for this nodeId, but none was found. NodeId: \(nodeId), ScopeId: \(scopeId)")
    }

    func getBoundRefByNodeId(nodeId: Int) -> BoundRef {
        let scopeId = nodeIdToScopeId[nodeId]
        let scope = scopes[scopeId]

        guard scope.boundRefs.contains(nodeId) else {
            fatalError("There must have been a bound reference for this nodeId, but none was found in its scope. NodeId: \(nodeId), ScopeId: \(scopeId)")
        }

        if let boundRef = boundRefs.first(where: { $0.refNodeId == nodeId }) {
            return boundRef
        }

        fatalError("Scope contains this bound reference nodeId, but the BoundRef table does not. NodeId: \(nodeId), ScopeId: \(scopeId)")
    }

    public func findScopeById(_ id: Int) -> Scope? {
        return scopes.first(where: { $0.id == id } )
    }

    public func findBindingById(_ id: Int) -> Binding? {
        return bindings.first(where: { $0.declOrder == id } )
    }

    public func findBoundRefById(_ id: Int) -> BoundRef? {
        return boundRefs.first(where: { $0.refNodeId == id } )
    }

    func getScopeIdByNodeId(nodeId: Int) -> Int {
        return nodeIdToScopeId[nodeId]    
    }

    func addBindingToScopeByLookingAstId(nodeId: Int, bindingId: Int) {
        scopes[nodeIdToScopeId[nodeId]].bindings.append(bindingId)
    }

    func addRefToScopeByLookingAstId(nodeId: Int) { // refId
        scopes[nodeIdToScopeId[nodeId]].boundRefs.append(nodeId)
    }

    func getBindingIdByName(name: String, scopeId: Int) -> Int? {
        
        //First check cache
        if let cachedBinding = bindingCache, cachedBinding.name == name, cachedBinding.scopeId == scopeId {
            return cachedBinding.declOrder
        } 

        // If cache miss, look up in 
        else if let cachedScope = scopeCache, cachedScope.id == scopeId {
            if let bindingId = cachedScope.bindings.first(where: { bindingId in
                if let binding = bindings.first(where: { $0.declOrder == bindingId }) {
                    return binding.name == name && binding.scopeId == scopeId
                }
                return false
            }) {
                bindingCache = bindings.first(where: { $0.declOrder == bindingId })
                return bindingId
            }
        }

        // If in same function scope, look up in params scope as well
        // because both params and body bindings are visible in the entire function body.
        
        /*...*/

        else if let bindingIndex = bindings.firstIndex(where: { $0.name == name && $0.scopeId == scopeId }) {
            bindingCache = bindings[bindingIndex]
            return bindings[bindingIndex].declOrder
        } 
        else {
            return nil
        }
        fatalError("VERIFY NOT REACHED: getBindingIdByName should have returned by now")
    } 
}

extension CompilationUnit{
    public func printLinearizedAST() {
        var nodeIdForCounting = 0
        nodeIdToScopeId.forEach {scopeId in
            print("Node ID: \(nodeIdForCounting)-> \(descs[nodeIdForCounting]) -> Scope ID: \(scopeId)")
            nodeIdForCounting += 1
        }
    }

    public func renderDescription() -> String {
        return scopes[0].renderDescription(self, simplified: true)
    } 
}

extension Scope {
    
    // Since scope tree is meaningful only in the context of the entire scope builder, 
    // we need to pass the builder as it is not designed as a tree node structure but id based table.

    public func renderDescription(_ compilation: CompilationUnit, simplified: Bool = false) -> String {
        return renderTree(simplified ? 
                          toTreeBoxSimplified(CompilationUnit: compilation) : 
                          toTreeBox(CompilationUnit: compilation)
                          )
    }

    public func toTreeBoxSimplified(CompilationUnit: CompilationUnit) -> TreeBox {
        
        box("Scope \(id)", [
            box("kind: \(kind)"),
            box("ownerFunction: " + (ownerFunctionId.map(String.init) ?? "nil")),
            boxList("bindings", 
                bindings.map {bindingId in 
                    CompilationUnit
                        .findBindingById(bindingId)?
                        .toTreeBoxSimplified(compilation: CompilationUnit) 
                        ?? box("Binding \(bindingId) not found")
                }
            ),

            boxList("boundRefs", 
                boundRefs.map {refId in 
                    CompilationUnit
                        .findBoundRefById(refId)?
                        .toTreeBoxSimplified(compilation: CompilationUnit) 
                        ?? box("BoundRef \(refId) not found")
                }
            ),
            boxList("children", 
                childIds.map {childId in 
                    CompilationUnit.findScopeById(childId)?
                        .toTreeBoxSimplified(CompilationUnit: CompilationUnit) 
                        ?? box("Scope \(childId) not found")
                }
            )
        ])
    }
        

    public func toTreeBox(CompilationUnit: CompilationUnit) -> TreeBox {
        box("Scope \(id)", [
            box("nodeId: \(nodeId)"),
            box("kind: \(kind)"),
            box("ownerFunctionId: \(ownerFunctionId.map(String.init) ?? "nil")"),
            box("parentId: \(parentId.map(String.init) ?? "nil")"),
            boxList("bindings", 
                bindings.map {bindingId in 
                    CompilationUnit
                        .findBindingById(bindingId)?
                        .toTreeBox(compilation: CompilationUnit) 
                        ?? box("Binding \(bindingId) not found")
                }
            ),
            boxList("boundRefs", 
                boundRefs.map {refId in 
                    CompilationUnit
                        .findBoundRefById(refId)?
                        .toTreeBox(compilation: CompilationUnit) 
                        ?? box("BoundRef \(refId) not found")
                }
            ),
            boxList("children", 
                childIds.map {childId in 
                    CompilationUnit
                        .findScopeById(childId)?
                        .toTreeBox(CompilationUnit: CompilationUnit) 
                        ?? box("Scope \(childId) not found")
                }
            )
        ])
    }
}

extension Binding {
    public func renderDescription(_ compilation: CompilationUnit) -> String {
        return renderTree(toTreeBox(compilation: compilation))
    }

    public func toTreeBoxSimplified(compilation: CompilationUnit) -> TreeBox {
        box("Binding \(declOrder)", [
            box("name: \(name)"),
            box("kind: \(kind)"),
    
        ])
    }


    public func toTreeBox(compilation: CompilationUnit) -> TreeBox {
        box("Binding \(declOrder)", [
            box("name: \(name)"),
            box("kind: \(kind)"),
            box("slot: \(slot.map(String.init) ?? "nil")"),
            box("scopeId: \(scopeId)"),
            box("declNodeId: \(declNodeId)"),
            box("declOrder: \(declOrder)"),
            box("mutable: \(mutable)"),
            box("has_tdz: \(has_tdz)"),
            box("is_hoisted: \(is_hoisted)")
        ])
    }
}

extension BoundRef {
    public func renderDescription(_ compilation: CompilationUnit) -> String {
        return renderTree(toTreeBox(compilation: compilation))
    }

        public func toTreeBoxSimplified(compilation: CompilationUnit) -> TreeBox {
            box("BoundRef \(refNodeId)", [
                box("name: \(name)"),
                box("kind: \(kind)"),
                box("bindingId: \(bindingId.map(String.init) ?? "nil")"),
                box("captureDepth: \(capturingDepth)"),
                box("storageKind: \(storageKind)"),

            ])
        }

    public func toTreeBox(compilation: CompilationUnit) -> TreeBox {
        box("BoundRef \(refNodeId)", [
            box("name: \(name)"),
            box("kind: \(kind)"),
            box("bindingId: \(bindingId.map(String.init) ?? "nil")"),
            box("refScopeId: \(refScopeId)"),
            box("isCaptured: \(isCaptured)"),
            box("captureDepth: \(capturingDepth)"),
            box("storageKind: \(storageKind)"),
            box("resolution: \(resolution)"),
            box("diagnostics: [\(diagnostics.map { $0.description }.joined(separator: ", "))]")
        ])
    }
    }
