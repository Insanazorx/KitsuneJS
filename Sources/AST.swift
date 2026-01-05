// AST.swift

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

// Expressions
public indirect enum Expression {
    case literal(Literal)
    case identifier(String)
    case this

    case binary(left: Expression, operator_: TokenType, right: Expression)
    case unary(operator_: TokenType, argument: Expression, isPrefix: Bool)

    case assignment(left: Expression, operator_: TokenType, right: Expression)

    case call(callee: Expression, arguments: [Expression])
    case member(object: Expression, property: Expression)
    case computedMember(object: Expression, property: Expression)
    case sequence (expressions: [Expression])
    case new(callee: Expression, arguments: [Expression?])
    case yield(argument: Expression?)
    case await(argument: Expression)

    case arrayLiteral(elements: [Expression])
    case objectLiteral(properties: [String: Expression])
    case functionExpression(
        name: Expression?,
        params: [Expression?],
        body: Statement,
        isAsync: Bool,
        isGenerator: Bool
    )

    case classExpression(
        name: Expression?,
        superClass: Expression?,
        body: [Declaration]
    )


    case arrowFunction(params: [Expression?], body: Statement, isAsync: Bool)

    case parenthesized(Expression?)
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
        initDecl: Declaration?,
        initExpr: Expression?,
        test: Expression?,
        update: Expression?,
        body: Statement
    )

    case forInStatement(left: Declaration?, leftExpr: Expression?, right: Expression, body: Statement)
    case forOfStatement(left: Declaration?, leftExpr: Expression?, right: Expression, body: Statement)
    case forAwaitOfStatement(left: Declaration?, leftExpr: Expression?, right: Expression, body: Statement)

    case returnStatement(argument: Expression?)
    case breakStatement
    case continueStatement

    case throwStatement(argument: Expression)

    case tryStatement(
        block: Statement,
        catchDeclarations: [Expression?],
        handler: Statement?,
        finalizer: Statement?
    )

    case switchStatement(discriminant: Expression, cases: [CaseStatement])

    case labelledStatement(label: String, body: Statement)

    case empty
}

// Case statements for switch
public indirect enum CaseStatement {
    case `case`(test: Expression?, consequent: [Statement])
}

// Declarations
public indirect enum Declaration {
    case function(
        name: Expression?,
        params: [Expression?],
        body: Statement, // typically .block
        isAsync: Bool,
        isGenerator: Bool
    )

    case `class`(
        name: Expression?,
        superClass: Expression?,
        body: [Declaration]
    )

    // let / const
    case lexical(kind: LexicalKind, declarations: [Expression?], assignments: [Expression]?)

    // var
    case variable(declarations: [Expression?], assignments: [Expression]?)

    case importDecl(module: Expression, specifiers: [Expression])
    case exportDecl(specifiers: [Expression], source: Expression?)
}

public enum LexicalKind {
    case `let`
    case `const`
}

// MARK: - Debug printing (Tree View)

private struct TreeBox {
    let label: String
    var children: [TreeBox] = []
}

private func renderTree(_ node: TreeBox) -> String {
    var lines: [String] = [node.label]

    func walk(_ n: TreeBox, _ prefix: String, _ isLast: Bool) {
        let connector = isLast ? "└─ " : "├─ "
        lines.append(prefix + connector + n.label)

        let nextPrefix = prefix + (isLast ? "   " : "│  ")
        for (i, child) in n.children.enumerated() {
            walk(child, nextPrefix, i == n.children.count - 1)
        }
    }

    for (i, child) in node.children.enumerated() {
        walk(child, "", i == node.children.count - 1)
    }

    return lines.joined(separator: "\n")
}

private func box(_ label: String, _ children: [TreeBox] = []) -> TreeBox {
    TreeBox(label: label, children: children)
}

private func boxOpt(_ name: String, _ value: TreeBox?) -> TreeBox {
    box(name, [value ?? box("<nil>")])
}

private func boxList(_ name: String, _ values: [TreeBox]) -> TreeBox {
    box(name, values.isEmpty ? [box("<empty>")] : values)
}

private func boxOptList(_ name: String, _ values: [TreeBox?]) -> TreeBox {
    let rendered = values.map { $0 ?? box("<nil>") }
    return boxList(name, rendered)
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
            let props = properties
                .sorted(by: { $0.key < $1.key })
                .map { key, value in box("\(key)", [value.toTreeBox()]) }
            return box("Expression.objectLiteral", [boxList("properties", props)])

        case .functionExpression(let name, let params, let body, let isAsync, let isGenerator):
            return box("Expression.functionExpression", [
                boxOpt("name", name?.toTreeBox()),
                boxOptList("params", params.map { $0?.toTreeBox() }),
                box("async: \(isAsync)"),
                box("generator: \(isGenerator)"),
                box("body", [body.toTreeBox()])
            ])

        case .classExpression(let name, let superClass, let body):
            return box("Expression.classExpression", [
                boxOpt("name", name?.toTreeBox()),
                boxOpt("superClass", superClass?.toTreeBox()),
                boxList("body", body.map { $0.toTreeBox() })
            ])

        case .arrowFunction(let params, let body, let isAsync):
            return box("Expression.arrowFunction", [
                boxOptList("params", params.map { $0?.toTreeBox() }),
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

        case .forStatement(let initDecl, let initExpr, let test, let update, let body):
            return box("Statement.for", [
                boxOpt("initDecl", initDecl?.toTreeBox()),
                boxOpt("initExpr", initExpr?.toTreeBox()),
                boxOpt("test", test?.toTreeBox()),
                boxOpt("update", update?.toTreeBox()),
                box("body", [body.toTreeBox()])
            ])

        case .forInStatement(let left, let leftExpr, let right, let body):
            return box("Statement.forIn", [
                boxOpt("leftDecl", left?.toTreeBox()),
                boxOpt("leftExpr", leftExpr?.toTreeBox()),
                box("right", [right.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .forOfStatement(let left, let leftExpr, let right, let body):
            return box("Statement.forOf", [
                boxOpt("leftDecl", left?.toTreeBox()),
                boxOpt("leftExpr", leftExpr?.toTreeBox()),
                box("right", [right.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .forAwaitOfStatement(let left, let leftExpr, let right, let body):
            return box("Statement.forAwaitOf", [
                boxOpt("leftDecl", left?.toTreeBox()),
                boxOpt("leftExpr", leftExpr?.toTreeBox()),
                box("right", [right.toTreeBox()]),
                box("body", [body.toTreeBox()])
            ])

        case .returnStatement(let argument):
            return box("Statement.return", [boxOpt("argument", argument?.toTreeBox())])

        case .breakStatement:
            return box("Statement.break")

        case .continueStatement:
            return box("Statement.continue")

        case .throwStatement(let argument):
            return box("Statement.throw", [box("argument", [argument.toTreeBox()])])

        case .tryStatement(let block, let catchDeclarations, let handler, let finalizer):
            return box("Statement.try", [
                box("block", [block.toTreeBox()]),
                boxOptList("catchDeclarations", catchDeclarations.map { $0?.toTreeBox() }),
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
                box("label: \(label)"),
                box("body", [body.toTreeBox()])
            ])

        case .empty:
            return box("Statement.empty")
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
                boxOpt("name", name?.toTreeBox()),
                boxOptList("params", params.map { $0?.toTreeBox() }),
                box("async: \(isAsync)"),
                box("generator: \(isGenerator)"),
                box("body", [body.toTreeBox()])
            ])

        case .class(let name, let superClass, let body):
            return box("Declaration.class", [
                boxOpt("name", name?.toTreeBox()),
                boxOpt("superClass", superClass?.toTreeBox()),
                boxList("body", body.map { $0.toTreeBox() })
            ])

        case .lexical(let kind, let declarations, let assignments):
            return box("Declaration.lexical(\(kind))", [
                boxOptList("declarations", declarations.map { $0?.toTreeBox() }),
                boxList("assignments", (assignments ?? []).map { $0.toTreeBox() })
            ])

        case .variable(let declarations, let assignments):
            return box("Declaration.variable", [
                boxOptList("declarations", declarations.map { $0?.toTreeBox() }),
                boxList("assignments", (assignments ?? []).map { $0.toTreeBox() })
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
