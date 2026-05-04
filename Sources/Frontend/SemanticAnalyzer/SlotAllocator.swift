public class SlotAllocator {
    var compilationUnit: CompilationUnit
    var nextSlot: Int = 0

    public init(compilationUnit: CompilationUnit) {
        self.compilationUnit = compilationUnit
    }

}

extension SlotAllocator {
    public func allocateSlot() -> Int {
        let slot = nextSlot
        nextSlot += 1
        return slot
    }

    public func resetSlotCounter() {
        nextSlot = 0
    }

}

extension SlotAllocator {
    public func analyze() {

        // Start with the global scope

        compilationUnit.scopes[0].bindings.forEach { bindingId in
            compilationUnit.bindings[bindingId].slot = allocateSlot()
        }

        resetSlotCounter()

        
        // Then analyze each scope in order,
        // reset last id when we enter a function scope

        for i in 1..<compilationUnit.scopes.count {
            let scope = compilationUnit.scopes[i]

            if scope.kind == .function {
                resetSlotCounter()
            }

            scope.bindings.forEach { bindingId in
                compilationUnit.bindings[bindingId].slot = allocateSlot()
            }

        }

    }
}