// AST.swift

public enum AnyNode {
    case program(Program)
    case statement(Statement)
    case expression(Expression)
    case declaration(Declaration)
    case objectProperty(ObjectProperty)
    case classElement(ClassElement)
    case forInit(ForInit)
    case forEachLeft(ForEachLeft)
    case pattern(Pattern)
    case assignmentTarget(AssignmentTarget)
    case propKey(PropertyKey)
    case classElemKey(ClassElementKey)
    case destructuringPattern(DestructuringPattern)
    case destructuringObjectProperty(DestructuringObjectProperty)
    case objectPatternProperty(ObjectPatternProperty)
    case variableDeclarator(VariableDeclarator)
    case arrayElement(ArrayElement)
    case arrayPatternElement(ArrayPatternElement)
    case destructuringArrayPatternElement(DestructuringArrayPatternElement)
}

// Top-level node wrapper
public indirect enum ASTNode {
    case expression(Expression)
    case statement(Statement)
    case declaration(Declaration)
    case program(Program)
}

// Program
public indirect enum Program {
    case program(body: [Statement])
}
// For func names, class names 

//---------------------------o-----------------------------
public indirect enum AssignmentTarget {
    case identifier(String)
    case member(object: Expression, property: Expression)
    case computedMember(object: Expression, property: Expression)
    case destructuring(DestructuringPattern)
}

public indirect enum DestructuringPattern {
    case object(properties: [DestructuringObjectProperty])
    case array(elements: [DestructuringArrayPatternElement])           // elision için nil
    case rest(AssignmentTarget)                             // ...target
    case assignment(target: AssignmentTarget, defaultValue: Expression) // target = expr
    case target(AssignmentTarget)                           // leaf target (identifier/member/...) 
}

public enum DestructuringObjectProperty {
    case property(key: PropertyKey, value: DestructuringPattern) // {a: target}
    case shorthand(String)                                       // {a}
    case rest(AssignmentTarget)                                  // {...target}
}

public indirect enum Pattern {
    case bindingIdentifier(String)
    case object(properties: [ObjectPatternProperty])
    case array(elements: [ArrayPatternElement])           // elision için nil
    case rest(Pattern)                         // ...x
    case assignment(left: Pattern, defaultValue: Expression)  // x = expr
}

public enum DestructuringArrayPatternElement {
    case pattern(DestructuringPattern)
    case elision
}

public enum ObjectPatternProperty {
    case property(key: PropertyKey, value: Pattern)  // {a: x}
    case shorthand(String)                             // {a}
    case rest(Pattern)                                 // {...rest}
}


// Expressions
public indirect enum Expression {
    case literal(Literal)
    case identifier(String)
    case privateIdentifier(String)
    case this

    case binary(left: Expression, operator_: TokenType, right: Expression)
    case unary(operator_: TokenType, argument: Expression, isPrefix: Bool)

    case assignment(left: AssignmentTarget, operator_: TokenType, right: Expression)

    case call(callee: Expression, arguments: [Expression])
    case member(object: Expression, property: Expression)
    case computedMember(object: Expression, property: Expression)
    case sequence (expressions: [Expression])
    case new(callee: Expression, arguments: [Expression?])
    case yield(argument: Expression?)
    case await(argument: Expression)

    case arrayLiteral(elements: [ArrayElement])  
    case functionExpression(
        name: String?,
        params: [Pattern]?,
        body: Statement,
        isAsync: Bool,
        isGenerator: Bool
    )

    case classExpression(
        name: String?,
        superClass: Expression?,
        body: [ClassElement]
    )


    case arrowFunction(params: [Pattern]?, body: Statement, isAsync: Bool)

    case parenthesized(Expression?)
    case objectLiteral(properties: [ObjectProperty])

}


public enum ArrayPatternElement {
    case pattern(Pattern)
    case elision
}

public enum ArrayElement {
  case element(Expression)     // normal
  case spread(Expression)      // ...expr
  case elision                 // ,,
}

    public enum ObjectProperty {
        case property(key: PropertyKey, value: Expression)     // a: expr
        case shorthand(String)                            // {a}
        case method(key: PropertyKey, args: [Pattern]?, body: Statement, isAsync: Bool, isGenerator: Bool)      // {a(){}}
        case getter(key: PropertyKey, body: Statement)      // {get x(){}}
        case setter(key: PropertyKey, arg: Pattern, body: Statement)      // {set x(v){}}
        case spread(argument: Expression)                       // {...obj}
    }

    public enum PropertyKey {
        case identifier(String)
        case literal(Literal)
        case computed(Expression)  // {[expr]: ...}
    }

// Literals
    public indirect enum Literal {
        case int(Int)
        case float(Double)
        case string(String)
        case bool(Bool)
        case null
        case undefined
    }


// Statements
public indirect enum Statement {
    case block(statements: [Statement?])

    // These replace DeclarationStatement / ExpressionStatement structs
    case declarationStatement(Declaration)
    case expressionStatement(Expression)

    case ifStatement(test: Expression, consequent: Statement, alternate: Statement?)
    case whileStatement(test: Expression, body: Statement)
    case doWhileStatement(body: Statement, test: Expression)

    case forStatement(
        init: ForInit?,
        test: Expression?,
        update: Expression?,
        body: Statement
    )

    case forInStatement(left: ForEachLeft, right: Expression, body: Statement)
    case forOfStatement(left: ForEachLeft, right: Expression, body: Statement)
    case forAwaitOfStatement(left: ForEachLeft, right: Expression, body: Statement)

    case returnStatement(argument: Expression?)
    case breakStatement (label: Expression?)
    case continueStatement (label: Expression?)

    case throwStatement(argument: Expression)

    case tryStatement(
        block: Statement,
        catchDeclarations: [Pattern]?,
        handler: Statement?,
        finalizer: Statement?
    )

    case switchStatement(discriminant: Expression, cases: [CaseStatement])

    case labelledStatement(label: Expression, body: Statement)

    case empty
}

public enum ForInit {
    case declaration(Declaration)   // var/let/const ...
    case expression(Expression)     // i = 0, foo(), ...
}

public enum ForEachLeft {
    case declaration(Declaration) // var/let/const + TEK declarator (init yasak)
    case target(AssignmentTarget) // identifier/member/destructuring target
}



// Case statements for switch
public indirect enum CaseStatement {
    case `case`(test: Expression?, consequent: [Statement])
}

// Declarations
public indirect enum Declaration {
    case function(
        name: String,
        params: [Pattern]?,
        body: Statement, // typically .block
        isAsync: Bool,
        isGenerator: Bool
    )

    case `class`(
        name: String,
        superClass: Expression?,
        body: [ClassElement]
    )

    // let / const
    case lexical(kind: LexicalKind, declarators: [VariableDeclarator])

    // var
    case variable(declarators: [VariableDeclarator])

    case importDecl(module: Expression, specifiers: [Expression])
    case exportDecl(specifiers: [Expression], source: Expression?)
}

public enum LexicalKind {
    case `let`
    case `const`
}

public struct VariableDeclarator {

    public init (id: Pattern, init_: Expression?) {
        self.id = id
        self.init_ = init_
    }

    public let id: Pattern
    public let init_: Expression?   // nil => `let c;`
}



public enum ClassElementKey {
    case publicKey(PropertyKey)    // identifier/literal/computed
    case privateName(Expression)       // #name  (computed OLAMAZ)
}

public indirect enum ClassElement {
    case constructor(params: [Pattern]?, body: Statement)

    case getter(key: ClassElementKey, body: Statement, isStatic: Bool)
    case setter(key: ClassElementKey, param: Pattern, body: Statement, isStatic: Bool)

    case member(
        key: ClassElementKey,
        params: [Pattern]?,
        body: Statement,
        isStatic: Bool,
        isAsync: Bool,
        isGenerator: Bool
    )

    case field(
        key: ClassElementKey,
        initializer: Expression?,   // `x` için nil, `x = 1` için expr
        isStatic: Bool
    )

    case staticBlock(statement: Statement)

    case empty // `;`
}

// Top-level wrapper
extension ASTNode: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .expression(let expr):
            return box("ASTNode.expression", [expr.toTreeBox()])
        case .statement(let stmt):
            return box("ASTNode.statement", [stmt.toTreeBox()])
        case .declaration(let decl):
            return box("ASTNode.declaration", [decl.toTreeBox()])
        case .program(let prog):
            return box("ASTNode.program", [prog.toTreeBox()])
        }
    }
}



extension Pattern: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .bindingIdentifier(let name):
            return box("Pattern.bindingIdentifier(\(name))")
        case .object(let properties):
            return box("Pattern.object", [boxList("properties", properties.map { $0.toTreeBox() })])
        case .array(let elements):
            return box("Pattern.array", [boxOptList("elements", elements.map { $0.toTreeBox() })])
        case .rest(let pattern):
            return box("Pattern.rest", [pattern.toTreeBox()])
        case .assignment(let left, let defaultValue):
            return box("Pattern.assignment", [
                box("left", [left.toTreeBox()]),
                box("defaultValue", [defaultValue.toTreeBox()])
            ])
        }
    }
}

private extension ObjectPatternProperty {
    func toTreeBox() -> TreeBox {
        switch self {
        case .property(let key, let value):
            return box("ObjectPatternProperty.property", [
                box("key", [key.toTreeBox()]),
                box("value", [value.toTreeBox()])
            ])
        case .shorthand(let name):
            return box("ObjectPatternProperty.shorthand(\(name))")
        case .rest(let pattern):
            return box("ObjectPatternProperty.rest", [pattern.toTreeBox()])
        }
    }
}

extension Program: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .program(let body):
            return box("Program", [boxList("body", body.map { $0.toTreeBox() })])
        }
    }
}

extension Expression: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .privateIdentifier(let name):
            return box("Expression.privateIdentifier(\(name))")
        case .literal(let lit):
            return box("Expression.literal", [lit.toTreeBox()])
        case .identifier(let name):
            return box("Expression.identifier(\(name))")
        case .this:
            return box("Expression.this")

        case .binary(let left, let op, let right):
            return box("Expression.binary", [
                box("operator: \(op)"),
                box("left", [left.toTreeBox()]),
                box("right", [right.toTreeBox()])
            ])

        case .unary(let op, let arg, let isPrefix):
            return box("Expression.unary", [
                box("operator: \(op)"),
                box("isPrefix: \(isPrefix)"),
                box("argument", [arg.toTreeBox()])
            ])

        case .assignment(let left, let op, let right):
            return box("Expression.assignment", [
                box("operator: \(op)"),
                box("left", [left.toTreeBox()]),
                box("right", [right.toTreeBox()])
            ])

        case .call(let callee, let arguments):
            return box("Expression.call", [
                box("callee", [callee.toTreeBox()]),
                boxList("arguments", arguments.map { $0.toTreeBox() })
            ])

        case .member(let object, let property):
            return box("Expression.member", [
                box("object", [object.toTreeBox()]),
                box("property", [property.toTreeBox()])
            ])
        case .computedMember(let object, let property):
            return box("Expression.computedMember", [
                box("object", [object.toTreeBox()]),
                box("property", [property.toTreeBox()])
            ])

        case .sequence(let expressions):
            return box("Expression.sequence", [boxList("expressions", expressions.map { $0.toTreeBox() })])

        case .new(let callee, let arguments):
            let args = arguments.map { $0?.toTreeBox() }
            return box("Expression.new", [
                box("callee", [callee.toTreeBox()]),
                boxOptList("arguments", args)
            ])

        case .yield(let argument):
            return box("Expression.yield", [boxOpt("argument", argument?.toTreeBox())])

        case .await(let argument):
            return box("Expression.await", [box("argument", [argument.toTreeBox()])])

        case .arrayLiteral(let elements):
            return box("Expression.arrayLiteral", [boxList("elements", elements.map { $0.toTreeBox() })])

        case .objectLiteral(let properties):
            return box("Expression.objectLiteral", [
                boxList("properties", properties.map { $0.toTreeBox() })
            ])

        case .functionExpression(let name, let params, let body, let isAsync, let isGenerator):
            return box("Expression.functionExpression", [
                box("name: \(name ?? "<no name>")"),
                boxListOpt("params", params?.map { $0.toTreeBox() }),
                box("async: \(isAsync)"),
                box("generator: \(isGenerator)"),
                box("body", [body.toTreeBox()])
            ])

        case .classExpression(let name, let superClass, let body):
            return box("Expression.classExpression", [
                box("name: \(name ?? "<no name>")"),
                boxOpt("superClass", superClass?.toTreeBox()),
                boxList("body", body.map { $0.toTreeBox() })
            ])

        case .arrowFunction(let params, let body, let isAsync):
            return box("Expression.arrowFunction", [
                boxListOpt("params", params?.map { $0.toTreeBox() }),
                box("body", [body.toTreeBox()]),
                box("async: \(isAsync)")
            ])

        case .parenthesized(let expr):
            if let e = expr {
                return box("Expression.parenthesized", [e.toTreeBox()])
            }
            return box("Expression.parenthesized", [box("<nil>")])
        }
    }
}

extension ArrayElement {
    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .element(let expr):
            return box("ArrayElement.element", [expr.toTreeBox()])
        case .spread(let expr):
            return box("ArrayElement.spread", [expr.toTreeBox()])
        case .elision:
            return box("ArrayElement.elision")
        }
    }
}

extension ArrayPatternElement {
    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .pattern(let pattern):
            return box("ArrayPatternElement.pattern", [pattern.toTreeBox()])
        case .elision:
            return box("ArrayPatternElement.elision")
        }
    }
}

extension DestructuringArrayPatternElement {
    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .pattern(let pattern):
            return box("DestructuringArrayPatternElement.pattern", [pattern.toTreeBox()])
        case .elision:
            return box("DestructuringArrayPatternElement.elision")
        }
    }
}



// MARK: - Object literal Tree View

private extension PropertyKey {
    func toTreeBox() -> TreeBox {
        switch self {
        case .identifier(let name):
            return box("PropertyKey.identifier(\(name))")
        case .literal(let lit):
            return box("PropertyKey.literal", [lit.toTreeBox()])
        case .computed(let expr):
            return box("PropertyKey.computed", [expr.toTreeBox()])
        }
    }
}

private extension ObjectProperty {
    func toTreeBox() -> TreeBox {
        switch self {
        case .property(let key, let value):
            return box("ObjectProperty.property", [
                box("key", [key.toTreeBox()]),
                box("value", [value.toTreeBox()])
            ])

        case .shorthand(let name):
            return box("ObjectProperty.shorthand(\(name))")

        case .method(let key, let args, let body, let isAsync, let isGenerator):
            return box("ObjectProperty.method", [
                box("key", [key.toTreeBox()]),
                boxListOpt("args", args?.map { $0.toTreeBox() }),
                box("body", [body.toTreeBox()]),
                box( "isAsync: \(isAsync)"),
                box( "isGenerator: \(isGenerator)")
            ])

        case .getter(let key, let body):
            return box("ObjectProperty.getter", [
                box("key", [key.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .setter(let key, let arg, let body):
            return box("ObjectProperty.setter", [
                box("key", [key.toTreeBox()]),
                box("arg", [arg.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .spread(let argument):
            return box("ObjectProperty.spread", [
                box("argument", [argument.toTreeBox()])
            ])
        }
    }
}

extension Literal: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .int(let v):
            return box("Literal.int(\(v))")
        case .float(let v):
            return box("Literal.float(\(v))")
        case .string(let v):
            return box("Literal.string(\"\(v)\")")
        case .bool(let v):
            return box("Literal.bool(\(v))")
        case .null:
            return box("Literal.null")
        case .undefined:
            return box("Literal.undefined")
        }
    }
}

extension Statement: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .block(let statements):
            return box("Statement.block", [boxOptList("statements", statements.map { $0?.toTreeBox() })])

        case .declarationStatement(let decl):
            return box("Statement.declarationStatement", [decl.toTreeBox()])

        case .expressionStatement(let expr):
            return box("Statement.expressionStatement", [expr.toTreeBox()])

        case .ifStatement(let test, let consequent, let alternate):
            return box("Statement.if", [
                box("test", [test.toTreeBox()]),
                box("consequent", [consequent.toTreeBox()]),
                boxOpt("alternate", alternate?.toTreeBox())
            ])

        case .whileStatement(let test, let body):
            return box("Statement.while", [
                box("test", [test.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .doWhileStatement(let body, let test):
            return box("Statement.doWhile", [
                box("body", [body.toTreeBox()]),
                box("test", [test.toTreeBox()])
            ])

        case .forStatement(let `init`, let test, let update, let body):
            return box("Statement.for", [
                boxOpt("init", `init`?.toTreeBox()),
                boxOpt("test", test?.toTreeBox()),
                boxOpt("update", update?.toTreeBox()),
                box("body", [body.toTreeBox()])
            ])

        case .forInStatement(let left, let right, let body):
            return box("Statement.forIn", [
                boxOpt("left", left.toTreeBox()),
                box("right", [right.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .forOfStatement(let left, let right, let body):
            return box("Statement.forOf", [
                boxOpt("left", left.toTreeBox()),
                box("right", [right.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .forAwaitOfStatement(let left, let right, let body):
            return box("Statement.forAwaitOf", [
                boxOpt("left", left.toTreeBox()),
                box("right", [right.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .returnStatement(let argument):
            return box("Statement.return", [boxOpt("argument", argument?.toTreeBox())])

        case .breakStatement(let label):
            return box("Statement.break", [boxOpt("label", label?.toTreeBox())])

        case .continueStatement(let label):
            return box("Statement.continue", [boxOpt("label", label?.toTreeBox())])

        case .throwStatement(let argument):
            return box("Statement.throw", [box("argument", [argument.toTreeBox()])])

        case .tryStatement(let block, let catchDeclarations, let handler, let finalizer):
            return box("Statement.try", [
                box("block", [block.toTreeBox()]),
                boxListOpt("catchDeclarations", catchDeclarations?.map { $0.toTreeBox() }),
                boxOpt("handler", handler?.toTreeBox()),
                boxOpt("finalizer", finalizer?.toTreeBox())
            ])

        case .switchStatement(let discriminant, let cases):
            return box("Statement.switch", [
                box("discriminant", [discriminant.toTreeBox()]),
                boxList("cases", cases.map { $0.toTreeBox() })
            ])

        case .labelledStatement(let label, let body):
            return box("Statement.labelled", [
                box("label: ", [label.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .empty:
            return box("Statement.empty")
        }
    }
}

extension ForInit: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .declaration(let decl):
            return box("ForInit.declaration", [decl.toTreeBox()])
        case .expression(let expr):
            return box("ForInit.expression", [expr.toTreeBox()])
        }
    }
}

extension ForEachLeft: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .declaration(let decl):
            return box("ForEachLeft.declaration", [decl.toTreeBox()])
        case .target(let target):
            return box("ForEachLeft.target", [target.toTreeBox()])
        }
    }
}

extension CaseStatement: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .case(let test, let consequent):
            return box("Case", [
                boxOpt("test", test?.toTreeBox()),
                boxList("consequent", consequent.map { $0.toTreeBox() })
            ])
        }
    }
}

extension Declaration: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .function(let name, let params, let body, let isAsync, let isGenerator):
            return box("Declaration.function", [
                box("name: \(name)"),
                boxListOpt("params", params?.map { $0.toTreeBox() }),
                box("async: \(isAsync)"),
                box("generator: \(isGenerator)"),
                box("body", [body.toTreeBox()])
            ])

        case .class(let name, let superClass, let body):
            return box("Declaration.class", [
                box("name: \(name)"),
                boxOpt("superClass", superClass?.toTreeBox()),
                boxList("body", body.map { $0.toTreeBox() })
            ])

        case .lexical(let kind, let declarators):
            return box("Declaration.lexical(\(kind))", [
                boxListOpt("declarators", declarators.map { $0.toTreeBox() })
            ])

        case .variable(let declarators):
            return box("Declaration.variable", [
                boxListOpt("declarators", declarators.map { $0.toTreeBox() })
            ])

        case .importDecl(let module, let specifiers):
            return box("Declaration.import", [
                box("module", [module.toTreeBox()]),
                boxList("specifiers", specifiers.map { $0.toTreeBox() })
            ])

        case .exportDecl(let specifiers, let source):
            return box("Declaration.export", [
                boxList("specifiers", specifiers.map { $0.toTreeBox() }),
                boxOpt("source", source?.toTreeBox())
            ])
        }
    }
}



extension LexicalKind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .let:
            return "let"
        case .const:
            return "const"
        }
    }
}

extension VariableDeclarator: CustomStringConvertible {
    public var description: String {
        return renderTree(toTreeBox())
    }

    fileprivate func toTreeBox() -> TreeBox {
        return box("VariableDeclarator", [
            box("id", [id.toTreeBox()]),
            boxOpt("init", init_?.toTreeBox())
        ])
    }
}

extension ClassElementKey: CustomStringConvertible {
    public var description: String {
        switch self {
        case .publicKey(let pk):
            return "publicKey(\(pk))"
        case .privateName(let expr):
            return "privateName(\(expr))"
        }
    }
}
private extension ClassElementKey {
    func toTreeBox() -> TreeBox {
        switch self {
        case .publicKey(let pk):
            return box("ClassElementKey.publicKey", [pk.toTreeBox()])
        case .privateName(let expr):
            return box("ClassElementKey.privateName", [expr.toTreeBox()])
        }
    }
}

extension ClassElement: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .constructor(let params, let body):
            return box("ClassElement.constructor", [
                boxListOpt("params", params?.map { $0.toTreeBox() }),
                box("body", [body.toTreeBox()])
            ])

        case .getter(let key, let body, let isStatic):
            return box("ClassElement.getter", [
                box("key", [key.toTreeBox()]),
                box("body", [body.toTreeBox()]),
                box("isStatic: \(isStatic)")
            ])

        case .setter(let key, let param ,let body, let isStatic):
            return box("ClassElement.setter", [
                box("key", [key.toTreeBox()]),
                boxOpt("param", param.toTreeBox()),
                box("body", [body.toTreeBox()]),
                box("isStatic: \(isStatic)")
            ])

        case .member(let key, let params, let body, let isStatic, let isAsync, let isGenerator):
            return box("ClassElement.member", [
                box("key", [key.toTreeBox()]),
                boxListOpt("params", params?.map { $0.toTreeBox() }),
                box("body", [body.toTreeBox()]),
                box("isStatic: \(isStatic)"),
                box("isAsync: \(isAsync)"),
                box("isGenerator: \(isGenerator)")
            ])

        case .field(let key, let initializer, let isStatic):
            return box("ClassElement.field", [
                box("key", [key.toTreeBox()]),
                boxOpt("initializer", initializer?.toTreeBox()),
                box("isStatic: \(isStatic)")
            ])

        case .staticBlock(let statement):
            return box("ClassElement.staticBlock", [
                box("statements", [statement.toTreeBox()])
            ])

        case .empty:
            return box("ClassElement.empty")
        }
    }
    
}

extension DestructuringPattern: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .object(let properties):
            return box("DestructuringPattern.object", [
                boxList("properties", properties.map { $0.toTreeBox() })
            ])
        case .array(let elements):
            return box("DestructuringPattern.array", [
                boxOptList("elements", elements.map { $0.toTreeBox() })
            ])
        case .rest(let target):
            return box("DestructuringPattern.rest", [target.toTreeBox()])
        case .assignment(let target, let defaultValue):
            return box("DestructuringPattern.assignment", [
                box("target", [target.toTreeBox()]),
                box("defaultValue", [defaultValue.toTreeBox()])
            ])
        case .target(let target):
            return box("DestructuringPattern.target", [target.toTreeBox()])
        }
    }
}

private extension DestructuringObjectProperty {
    func toTreeBox() -> TreeBox {
        switch self {
        case .property(let key, let value):
            return box("DestructuringObjectProperty.property", [
                box("key", [key.toTreeBox()]),
                box("value", [value.toTreeBox()])
            ])
        case .shorthand(let name):
            return box("DestructuringObjectProperty.shorthand(\(name))")
        case .rest(let target):
            return box("DestructuringObjectProperty.rest", [target.toTreeBox()])
        }
    }
}

extension AssignmentTarget: CustomStringConvertible {
    public var description: String { renderTree(toTreeBox()) }

    fileprivate func toTreeBox() -> TreeBox {
        switch self {
        case .identifier(let name):
            return box("AssignmentTarget.identifier(\(name))")
        case .member(let object, let property):
            return box("AssignmentTarget.member", [
                box("object", [object.toTreeBox()]),
                box("property", [property.toTreeBox()])
            ])
        case .computedMember(let object, let property):
            return box("AssignmentTarget.computedMember", [
                box("object", [object.toTreeBox()]),
                box("property", [property.toTreeBox()])
            ])
        case .destructuring(let pattern):
            return box("AssignmentTarget.destructuring", [pattern.toTreeBox()])
        }
    }
}
