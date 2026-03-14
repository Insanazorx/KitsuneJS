protocol JustName {
    var justName: String { get }
}
extension ASTNode: JustName {
    var justName: String {
        return "ASTNode"
    }
}

extension Program: JustName {
    var justName: String {
        return "Program"
    }
}

extension Statement: JustName {
    var justName: String {
        switch self {
        case .declarationStatement:
            return "DeclarationStatement"
        case .block:
            return "BlockStatement"
        case .expressionStatement:
            return "ExpressionStatement"
        case .ifStatement:
            return "IfStatement"
        case .whileStatement:
            return "WhileStatement"
        case .forStatement:
            return "ForStatement"
        case .returnStatement:
            return "ReturnStatement"
        case .empty:
            return "EmptyStatement"
        case .doWhileStatement:
            return "DoWhileStatement"
        case .forInStatement:
            return "ForInStatement"
        case .forOfStatement:
            return "ForOfStatement"
        case .forAwaitOfStatement:
            return "ForAwaitOfStatement"
        case .breakStatement:
            return "BreakStatement"
        case .continueStatement:
            return "ContinueStatement"
        case .throwStatement:
            return "ThrowStatement"
        case .tryStatement:
            return "TryStatement"
        case .switchStatement:
            return "SwitchStatement"
        case .labelledStatement:
            return "LabelledStatement"
        }
    }
}

extension Expression: JustName {
    var justName: String {
        switch self {
        case .identifier(let name):
            return "Identifier (\"\(name)\")"
        case .literal:
            return "Literal"
        case .binary:
            return "BinaryExpression"
        case .call:
            return "CallExpression"
        case .member:
            return "MemberExpression"
        case .arrayLiteral:
            return "ArrayLiteral"
        case .objectLiteral:
            return "ObjectLiteral"
        case .functionExpression:
            return "FunctionExpression"
        case .arrowFunction:
            return "ArrowFunctionExpression"
        case .privateIdentifier:
            return "PrivateIdentifier"
        case .this:
            return "ThisExpression"
        case .unary:
            return "UnaryExpression"
        case .assignment:
            return "AssignmentExpression"
        case .computedMember:
            return "ComputedMemberExpression"
        case .sequence:
            return "SequenceExpression"
        case .new:
            return "NewExpression"
        case .yield:
            return "YieldExpression"
        case .await:
            return "AwaitExpression"
        case .classExpression:
            return "ClassExpression"
        case .parenthesized:
            return "ParenthesizedExpression"
        }
    }
}

extension Declaration: JustName {
    var justName: String {
        switch self {
        case .variable:
            return "VariableDeclaration"
        case .lexical:
            return "LexicalDeclaration"
        case .function:
            return "FunctionDeclaration"
        case .class:
            return "ClassDeclaration"
        case .importDecl:
            return "ImportDeclaration"
        case .exportDecl:
            return "ExportDeclaration"
        }
    }
}

extension Pattern: JustName {
    var justName: String {
        switch self {
        case .bindingIdentifier(let name):
            return "BindingIdentifier (\"\(name)\")"
        case .array:
            return "ArrayPattern"
        case .object:
            return "ObjectPattern"
        case .rest:
            return "RestPattern"
        case .assignment:
            return "AssignmentPattern"
        }
    }
}






extension Identifier: JustName {
    var justName: String {
        switch self {
        case .identifier(let name):
            return "Identifier (\"\(name)\")"
        }
    }
}

extension AssignmentTarget: JustName {
    var justName: String {
        switch self {
        case .identifier(let name):
            return "IdentifierAssignmentTarget (\"\(name)\")"
        case .member:
            return "MemberAssignmentTarget"
        case .computedMember:
            return "ComputedMemberAssignmentTarget"
        case .destructuring:
            return "DestructuringAssignmentTarget"
        }
    }
}

extension DestructuringPattern: JustName {
    var justName: String {
        switch self {
        case .object:
            return "ObjectDestructuringPattern"
        case .array:
            return "ArrayDestructuringPattern"
        case .rest:
            return "RestDestructuringPattern"
        case .assignment:
            return "AssignmentDestructuringPattern"
        case .target:
            return "TargetDestructuringPattern"
        }
    }
}

extension DestructuringObjectProperty: JustName {
    var justName: String {
        switch self {
        case .property:
            return "DestructuringObjectProperty"
        case .shorthand:
            return "DestructuringObjectShorthandProperty"
        case .rest:
            return "DestructuringObjectRestProperty"
        }
    }
}

extension DestructuringArrayPatternElement: JustName {
    var justName: String {
        switch self {
        case .pattern:
            return "DestructuringArrayPatternElement"
        case .elision:
            return "DestructuringArrayElision"
        }
    }
}

extension ObjectPatternProperty: JustName {
    var justName: String {
        switch self {
        case .property:
            return "ObjectPatternProperty"
        case .shorthand:
            return "ObjectPatternShorthandProperty"
        case .rest:
            return "ObjectPatternRestProperty"
        }
    }
}

extension ArrayPatternElement: JustName {
    var justName: String {
        switch self {
        case .pattern:
            return "ArrayPatternElement"
        case .elision:
            return "ArrayPatternElision"
        }
    }
}

extension ArrayElement: JustName {
    var justName: String {
        switch self {
        case .element:
            return "ArrayElement"
        case .spread:
            return "SpreadElement"
        case .elision:
            return "ArrayElision"
        }
    }
}

extension ObjectProperty: JustName {
    var justName: String {
        switch self {
        case .property:
            return "ObjectProperty"
        case .shorthand:
            return "ObjectShorthandProperty"
        case .method:
            return "ObjectMethod"
        case .getter:
            return "ObjectGetter"
        case .setter:
            return "ObjectSetter"
        case .spread:
            return "ObjectSpreadProperty"
        }
    }
}

extension PropertyKey: JustName {
    var justName: String {
        switch self {
        case .identifier(let name):
            return "IdentifierPropertyKey (\"\(name)\")"
        case .literal:
            return "LiteralPropertyKey"
        case .computed:
            return "ComputedPropertyKey"
        }
    }
}

extension Literal: JustName {
    var justName: String {
        switch self {
        case .int(let value):
            return "IntLiteral (\"\(value)\")"
        case .float(let value):
            return "FloatLiteral (\"\(value)\")"
        case .string(let value):
            return "StringLiteral (\"\(value)\")"
        case .bool(let value):
            return "BoolLiteral (\"\(value)\")"
        case .null:
            return "NullLiteral"
        case .undefined:
            return "UndefinedLiteral"
        }
    }
}

extension ForInit: JustName {
    var justName: String {
        switch self {
        case .declaration:
            return "DeclarationForInit"
        case .expression:
            return "ExpressionForInit"
        }
    }
}

extension ForEachLeft: JustName {
    var justName: String {
        switch self {
        case .declaration:
            return "DeclarationForEachLeft"
        case .target:
            return "TargetForEachLeft"
        }
    }
}

extension CaseStatement: JustName {
    var justName: String {
        switch self {
        case .case:
            return "CaseStatement"
        }
    }
}

extension LexicalKind: JustName {
    var justName: String {
        switch self {
        case .let:
            return "Let"
        case .const:
            return "Const"
        }
    }
}

extension ClassElementKey: JustName {
    var justName: String {
        switch self {
        case .publicKey:
            return "PublicClassElementKey"
        case .privateName:
            return "PrivateClassElementKey"
        }
    }
}

extension ClassElement: JustName {
    var justName: String {
        switch self {
        case .constructor:
            return "ConstructorElement"
        case .getter:
            return "GetterElement"
        case .setter:
            return "SetterElement"
        case .member:
            return "MemberElement"
        case .field:
            return "FieldElement"
        case .staticBlock:
            return "StaticBlockElement"
        case .empty:
            return "EmptyClassElement"
        }
    }
}

extension VariableDeclarator: JustName {
    var justName: String {
        return "VariableDeclarator"
    }
}