public class CaptureAnalyzer {
    var compilationUnit: CompilationUnit

    public init(_ compilationUnit: CompilationUnit) {
        self.compilationUnit = compilationUnit
    }
}

extension CaptureAnalyzer {
    func analyze() {
    
    var currentBoundRefIndex = 0
    boundRefLoop: for var boundRef in compilationUnit.boundRefs {
        if boundRef.bindingId != nil{
            currentBoundRefIndex += 1
            continue
        }
    
        //look up nearest owner function with seeking its parameters first.

        if let maybeBindingId = lookupForFunctionParams(boundRef: boundRef, fromScopeId: boundRef.refScopeId) {
            boundRef.isCaptured = true
            boundRef.bindingId = maybeBindingId
            boundRef.storageKind = .lexical
            compilationUnit.boundRefs[currentBoundRefIndex] = boundRef
            
            currentBoundRefIndex += 1
            continue boundRefLoop
        }

        
        //then if not found, it must be found in ascending scopes.
        var depth = 0

        var currentScope: Scope = findScopeOfNode(nodeId: boundRef.refNodeId)
        
        while currentScope.id != 0 {

            guard let scopeIdToScan = currentScope.parentId else {
                fatalError("Scope with id \(currentScope.id) has no parent scope, but it is not the global scope.")
            }

            // If ownerFunctionId of parent scope differs from current scope's ownerFunctionId, 
            // it means we are crossing function boundary so depth increases.  
            // So we must lookup in params scope of the new function scope as well...

            let oldScopeOwnerFunctionId = currentScope.ownerFunctionId
            currentScope = compilationUnit.scopes[scopeIdToScan]

            if currentScope.ownerFunctionId != oldScopeOwnerFunctionId {
                depth += 1
                if let maybeBindingId = lookupForFunctionParams(boundRef: boundRef, fromScopeId: currentScope.id) {
                    boundRef.isCaptured = true
                    boundRef.bindingId = maybeBindingId
                    boundRef.storageKind = .context
                    boundRef.capturingDepth = depth

                    compilationUnit.boundRefs[currentBoundRefIndex] = boundRef
                    
                    currentBoundRefIndex += 1
                    continue boundRefLoop
                }

            }

            if case .global = currentScope.kind {
                boundRef.bindingId = compilationUnit.getBindingIdByName(name: boundRef.name, scopeId: currentScope.id)
                boundRef.isCaptured = true
                boundRef.storageKind = .global
                boundRef.capturingDepth = depth

                compilationUnit.boundRefs[currentBoundRefIndex] = boundRef

                currentBoundRefIndex += 1
                continue boundRefLoop
            
            }

            if let bindingId = compilationUnit.getBindingIdByName(name: boundRef.name, scopeId: currentScope.id) {
                boundRef.isCaptured = depth > 0
                boundRef.bindingId = bindingId
                boundRef.capturingDepth = depth

                if boundRef.isCaptured {
                    boundRef.storageKind = .context
                } else {
                    boundRef.storageKind = .lexical
                }

                compilationUnit.boundRefs[currentBoundRefIndex] = boundRef
                
                currentBoundRefIndex += 1
                continue boundRefLoop
            
            } else {continue}
        }

        }

        currentBoundRefIndex += 1
    }

    func findScopeOfNode(nodeId: Int) -> Scope {
        return compilationUnit.scopes[compilationUnit.nodeIdToScopeId[nodeId]] 
    }



    func lookupForFunctionParams(boundRef: BoundRef, fromScopeId scopeId: Int) -> Int? {

        guard let funcNodeId = compilationUnit.scopes[scopeId].ownerFunctionId else {
            return nil
        }

        if let paramsScopeId = findFunctionParamsScopeId(funcNodeId: funcNodeId) {
            if let bindingId = compilationUnit.getBindingIdByName(name: boundRef.name, scopeId: paramsScopeId) {
                return bindingId
            }
        }
        return nil
    }

    func findFunctionParamsScopeId(funcNodeId: Int) -> Int? {
        let funcScope = findScopeOfNodeForParams(nodeId: funcNodeId)
        for child in funcScope.childIds {
            if compilationUnit.scopes[child].kind == .param {
                return child
            }
        }
        return nil
    }

    func findScopeOfNodeForParams(nodeId: Int) -> Scope {

        //Little trick here (nodeIdToScopeId[nodeId] + 1):
        //Because owner function itself is not included in its own scope's nodeIdToScopeId mapping,
        //but it is included in the parent scope's nodeIdToScopeId mapping. function scope must have the 
        //successor scopeId of its owner.
        return compilationUnit.scopes[compilationUnit.nodeIdToScopeId[nodeId] + 1] 
    }


}