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
    case member(object: Expression, property: String)

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


    case arrowFunction(params: [Expression?], body: Expression)

    case parenthesized(Expression)
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

    case returnStatement(argument: Expression?)
    case breakStatement(label: String?)
    case continueStatement(label: String?)

    case throwStatement(argument: Expression)


    case tryStatement(
        block: Statement,
        catchDeclarations: [Declaration?],
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
    case variable(declarations: [Expression?])

    case importDecl(module: Expression, specifiers: [Expression])
    case exportDecl(specifiers: [Expression], source: Expression?)
}

public enum LexicalKind {
    case `let`
    case `const`
}

// MARK: - Debug printing

extension ASTNode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .expression(let expr):
            return "Expression: \(expr)"
        case .statement(let stmt):
            return "Statement: \(stmt)"
        case .declaration(let decl):
            return "Declaration: \(decl)"
        case .program(let prog):
            return "Program: \(prog)"
        }
    }
}

extension Program: CustomStringConvertible {
    public var description: String {
        switch self {
        case .program(let body):
            return "Program(body: \(body))"
        }
    }
}

extension Expression: CustomStringConvertible {
    public var description: String {
        switch self {
        case .literal(let lit):
            return "Literal(\(lit))"
        case .identifier(let name):
            return "Identifier(\(name))"
        case .binary(let left, let op, let right):
            return "Binary(left: \(left), op: \(op), right: \(right))"
        case .unary(let op, let arg, let isPrefix):
            return "Unary(op: \(op), arg: \(arg), isPrefix: \(isPrefix))"
        case .assignment(let left, let op, let right):
            return "Assignment(left: \(left), op: \(op), right: \(right))"
        case .call(let callee, let args):
            return "Call(callee: \(callee), args: \(args))"
        case .member(let object, let property):
            return "Member(object: \(object), property: \(property))"
        case .arrayLiteral(let elements):
            return "ArrayLiteral(\(elements))"
        case .objectLiteral(let properties):
            return "ObjectLiteral(\(properties))"
        case .arrowFunction(let params, let body):
            return "ArrowFunction(params: \(params), body: \(body))"
        case .parenthesized(let expr):
            return "Parenthesized(\(expr))"
        case .this:
            return "This"
        case .functionExpression(let name, let params, let body, let isAsync, let isGenerator):
            return "FunctionExpression(name: \(String(describing: name)), params: \(params), body: \(body), async: \(isAsync), generator: \(isGenerator))"
        case .classExpression(let name, let superClass, let body):
            return "ClassExpression(name: \(String(describing: name)), super: \(String(describing: superClass)), body: \(body))"
        }
    }
}

extension Statement: CustomStringConvertible {
    public var description: String {
        switch self {
        case .block(let statements):
            return "Block(\(statements))"
        case .declarationStatement(let decl):
            return "DeclarationStatement(\(decl))"
        case .expressionStatement(let expr):
            return "ExpressionStatement(\(expr))"
        case .ifStatement(let test, let cons, let alt):
            return "If(test: \(test), consequent: \(cons), alternate: \(String(describing: alt)))"
        case .whileStatement(let test, let body):
            return "While(test: \(test), body: \(body))"
        case .doWhileStatement(let body, let test):
            return "DoWhile(body: \(body), test: \(test))"
        case .forStatement(let initDecl, let initExpr, let test, let update, let body):
            return "For(initDecl: \(String(describing: initDecl)), initExpr: \(String(describing: initExpr)), test: \(String(describing: test)), update: \(String(describing: update)), body: \(body))"
        case .forInStatement(let left, let leftExpr, let right, let body):
            return "ForIn(left: \(String(describing: left)), leftExpr: \(String(describing: leftExpr)), right: \(right), body: \(body))"
        case .forOfStatement(let left, let leftExpr, let right, let body):
            return "ForOf(left: \(String(describing: left)), leftExpr: \(String(describing: leftExpr)), right: \(right), body: \(body))"
        case .returnStatement(let arg):
            return "Return(\(String(describing: arg)))"
        case .breakStatement(let label):
            return "Break(\(String(describing: label)))"
        case .continueStatement(let label):
            return "Continue(\(String(describing: label)))"
        case .throwStatement(let arg):
            return "Throw(\(arg))"
        case .tryStatement(let block, let catchDecls, let handler, let finalizer):
            return "Try(block: \(block), catch: \(catchDecls), handler: \(String(describing: handler)), finalizer: \(String(describing: finalizer)))"
        case .switchStatement(let discr, let cases):
            return "Switch(discriminant: \(discr), cases: \(cases))"
        case .labelledStatement(let label, let body):
            return "Labelled(label: \(label), body: \(body))"
        case .empty:
            return "Empty"
        }
    }
}

extension CaseStatement: CustomStringConvertible {
    public var description: String {
        switch self {
        case .case(let test, let consequent):
            return "Case(test: \(String(describing: test)), consequent: \(consequent))"
        }
    }
}

extension Declaration: CustomStringConvertible {
    public var description: String {
        switch self {
        case .function(let name, let params, let body, let isAsync, let isGenerator):
            return "Function(name: \(name), params: \(params), body: \(body), async: \(isAsync), generator: \(isGenerator))"
        case .class(let name, let superClass, let body):
            return "Class(name: \(name), super: \(String(describing: superClass)), body: \(body))"
        case .lexical(let kind, let decls, let assignments):
            return "Lexical(kind: \(kind), decls: \(decls), assignments: \(String(describing: assignments)))"
        case .variable(let decls):
            return "Var(decls: \(decls))"
        case .importDecl(let module, let specifiers):
            return "Import(module: \(module), specifiers: \(specifiers))"
        case .exportDecl(let specifiers, let source):
            return "Export(specifiers: \(specifiers), source: \(String(describing: source)))"
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

extension Literal: CustomStringConvertible {
    public var description: String {
        switch self {
        case .int(let value):
            return "Int(\(value))"
        case .float(let value):
            return "Float(\(value))"
        case .string(let value):
            return "String(\"\(value)\")"
        case .bool(let value):
            return "Bool(\(value))"
        case .null:
            return "Null"
        case .undefined:
            return "Undefined"
        }
    }
}
