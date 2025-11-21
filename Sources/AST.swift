enum ASTNode {
    case expression(Expression)
    case statement(Statement)
    case declaration(Declaration)
    case program(Program)
}

struct Program {
    var body: [Statement]
}

indirect enum Expression {
    case literal(Literal)
    case identifier(String)
    case binaryExpression(BinaryExpression)
    case unaryExpression(UnaryExpression)
    case assignmentExpression(AssignmentExpression)
    case callExpression(CallExpression)
    case memberExpression(MemberExpression)
    case arrayLiteral(ArrayLiteral)
    case objectLiteral(ObjectLiteral)
    case arrowFunction(ArrowFunction)
    case parenthesized(Expression)
}

struct Literal {
    enum LiteralType {
        case int(Int)
        case float(Double)
        case string(String)
        case bool(Bool)
        case null
        case undefined
    }
    let type: LiteralType
}


indirect enum Statement {
    case blockStatement(BlockStatement)
    case declarationStatement(DeclarationStatement)
    case expressionsStatement(ExpressionStatement)
    case ifStatement(IfStatement)
    case whileStatement(WhileStatement)
    case doWhileStatement(DoWhileStatement)
    case forStatement(ForStatement)
    case forInStatement(ForInStatement)
    case forOfStatement(ForOfStatement)
    case returnStatement(ReturnStatement)
    case breakStatement(BreakStatement)
    case continueStatement(ContinueStatement)
    case throwStatement(ThrowStatement)
    case tryStatement(TryStatement)
    case switchStatement(SwitchStatement)
    case labelledStatement(LabelledStatement)
    case caseStatement(CaseStatement)
    case empty
}


enum Declaration {
    case function(FunctionDeclaration)
    case `class`(ClassDeclaration)
    case lexical(LexicalDeclaration)    // let / const
    case variableDecl(VariableDeclaration)  // var
    case importDecl(ImportDeclaration)
    case exportDecl(ExportDeclaration)
}

struct BinaryExpression {
    var left: Expression
    var operator_: OperatorType
    var right: Expression
}
struct UnaryExpression {
    var operator_: OperatorType
    var argument: Expression
    var isPrefix: Bool
}

struct AssignmentExpression {
    var left: Expression
    var operator_: OperatorType
    var right: Expression
}

struct CallExpression {
    var callee: Expression
    var arguments: [Expression]
}

struct MemberExpression {
    var object: Expression
    var property: String
}

struct ArrayLiteral {
    var elements: [Expression]
}

struct ObjectLiteral {
    var properties: [String: Expression]
}

struct ArrowFunction {
    var params: [String]
    var body: Expression
}

struct Parenthesized {
    var expression: Expression
}

struct DeclarationStatement {
    var declaration: Declaration
}

struct ExpressionStatement{
    var expression: Expression
}

struct BlockStatement {
    var statements: [Statement]
}

struct IfStatement {
    var test: Expression
    var consequent: Statement
    var alternate: Statement?
}

struct WhileStatement {
    var test: Expression
    var body: Statement
}

struct DoWhileStatement {
    var body: Statement
    var test: Expression
}

struct ForStatement {
    var initDecl: Declaration?
    var initExpr: Expression?
    var test: Expression?
    var update: Expression?
    var body: Statement
}
struct ForInStatement {
    var left: Declaration?
    var leftExpr: Expression?
    var right: Expression
    var body: Statement
}

struct ForOfStatement {
    var left: Declaration?
    var leftExpr: Expression?
    var right: Expression
    var body: Statement
}

struct ReturnStatement {
    var argument: Expression?
}

struct BreakStatement {
    var label: String?
}

struct ContinueStatement {
    var label: String?
}

struct ThrowStatement {
    var argument: Expression
}

struct TryStatement {
    var block: BlockStatement
    var catchDeclaration: VariableDeclaration
    var handler: BlockStatement?
    var finalizer: BlockStatement?
}

struct SwitchStatement {
    var discriminant: Expression
    var cases: [CaseStatement]
}

struct CaseStatement {
    var test: Expression?
    var consequent: [Statement]
}

struct LabelledStatement {
    var label: String
    var body: Statement
}

struct FunctionDeclaration {
    var name: String
    var params: [String]
    var body: BlockStatement
    var isAsync: Bool
    var isGenerator: Bool
}

struct ClassDeclaration {
    var name: String
    var superClass: String?
    var body: [Declaration]
}

struct LexicalDeclaration {
    enum Kind {
        case `let`
        case `const`
    }
    var kind: Kind
    var declarations: [String]
}

struct VariableDeclaration {
    var declarations: [String]
}

struct ImportDeclaration {
    var module: String
    var specifiers: [String]
}

struct ExportDeclaration {
    var specifiers: [String]
    var source: String?
}



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

extension Expression: CustomStringConvertible {
    public var description: String {
        switch self {
            case .literal(let lit):
                return "Literal Expression: \(lit)"
            case .identifier(let name):
                return "Identifier Expression: \(name)"
            case .binaryExpression(let binExpr):
                return "Binary Expression: \(binExpr)"
            case .unaryExpression(let unExpr):
                return "Unary Expression: \(unExpr)"
            case .assignmentExpression(let assignExpr):
                return "Assignment Expression: \(assignExpr)" 
            case .callExpression(let callExpr):
                return "Call Expression: \(callExpr)"
            case .memberExpression(let memberExpr):
                return "Member Expression: \(memberExpr)"
            case .arrayLiteral(let arrayLit):
                return "Array Literal: \(arrayLit)"
            case .objectLiteral(let objLit):
                return "Object Literal: \(objLit)"
            case .arrowFunction(let arrowFunc):
                return "Arrow Function: \(arrowFunc)"
            case .parenthesized(let expr):  
                return "Parenthesized Expression: \(expr)"
        }
    }
}

extension Literal: CustomStringConvertible {
    public var description: String {
        switch type {
            case .int(let value):
                return "Int Literal: \(value)"
            case .float(let value):
                return "Float Literal: \(value)"
            case .string(let value):
                return "String Literal: \"\(value)\""
            case .bool(let value):
                return "Bool Literal: \(value)"
            case .null:
                return "Null Literal"
            case .undefined:
                return "Undefined Literal"
        }
    }
}





