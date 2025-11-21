enum ExpectedRule {
    case expression
    case statement
    case declaration
    case blockStatement
    case variableDeclaration
}

struct RuleError: Swift.Error {
    let message: String
}

enum Result {
    case success
    case failure(RuleError)
}

protocol RuleAssignable {
    func applyRule(context p: Parser) -> Result
    func doesFit(context p: Parser) -> Bool
}

extension Program : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
    //    try p.expect(rule: );
    //    return .success
    };
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension BinaryExpression : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension Literal : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension UnaryExpression : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension AssignmentExpression : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension CallExpression : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension MemberExpression : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension ArrayLiteral : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension ObjectLiteral : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension ArrowFunction : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension Parenthesized : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension DeclarationStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension ExpressionStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension BlockStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension IfStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension SwitchStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension WhileStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension DoWhileStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension ForStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension ForInStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension ForOfStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension ReturnStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension BreakStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension ContinueStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}
extension ThrowStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension TryStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension CaseStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}


extension LabelledStatement : RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension FunctionDeclaration: RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension ClassDeclaration: RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension LexicalDeclaration: RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension VariableDeclaration: RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension ImportDeclaration: RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}

extension ExportDeclaration: RuleAssignable {
    func applyRule(context p: Parser) -> Result {
        return .success
    }
    func doesFit(context p: Parser) -> Bool {
        return false
    }
}







