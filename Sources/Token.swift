public enum KeywordType {
    case `if`, `else`, `while`, `for`, `return`
    case `func`, `var`, `let`, `const`
    case `class`, `struct`, `enum`, `import`
} 

public enum OperatorType {
    case equal, notEqual, lessThan, greaterThan
    case lessThanOrEqual, greaterThanOrEqual
    case logicalAnd, logicalOr
    case plus, minus, multiply, divide, assign
    case arrow, increment, decrement
    case plusAssign, minusAssign, multiplyAssign, divideAssign
    case dot, ampersand, pipe
    case caret, percent, tilde
    case strictEqual, strictNotEqual
}

public enum punctuationType {
    case leftParen, rightParen
    case leftBrace, rightBrace
    case leftBracket, rightBracket
    case semicolon, colon, comma
}

public struct Token: CustomStringConvertible, Equatable {
    
    public let lexType: Lexer.LexemeType
    public let lexeme: String

    public var keywordType: KeywordType? {
        guard lexType == .keyword else { return nil }
        switch lexeme {
            case "if": return .if
            case "else": return .else
            case "while": return .while
            case "for": return .for
            case "return": return .return
            case "func": return .func
            case "var": return .var
            case "let": return .let
            case "const": return .const
            case "class": return .class
            case "struct": return .struct
            case "enum": return .enum
            case "import": return .import
            default: return nil
        }
    }
    public var operatorType: OperatorType? {
        guard lexType == .operatorSymbol else { return nil }
        switch lexeme {
            case "==": return .equal
            case "!=": return .notEqual
            case "<": return .lessThan
            case ">": return .greaterThan
            case "<=": return .lessThanOrEqual
            case ">=": return .greaterThanOrEqual
            case "&&": return .logicalAnd
            case "||": return .logicalOr
            case "+": return .plus
            case "-": return .minus
            case "*": return .multiply
            case "/": return .divide
            case "=": return .assign
            case "=>": return .arrow
            case "++": return .increment
            case "--": return .decrement
            case "+=": return .plusAssign
            case "-=": return .minusAssign
            case "*=": return .multiplyAssign
            case "/=": return .divideAssign
            case ".": return .dot
            case "&": return .ampersand
            case "|": return .pipe
            case "^": return .caret
            case "%": return .percent
            case "~": return .tilde
            case "===": return .strictEqual
            case "!==": return .strictNotEqual
            default: return nil
        }
    }
    public var punctuationType: punctuationType? {
        guard lexType == .punctuation else { return nil }
        switch lexeme {
            case "(": return .leftParen
            case ")": return .rightParen
            case "{": return .leftBrace
            case "}": return .rightBrace
            case "[": return .leftBracket
            case "]": return .rightBracket
            case ";": return .semicolon
            case ":": return .colon
            case ",": return .comma
            default: return nil
        }
    }
    public var description: String { "Token(\(lexType), \"\(lexeme)\")" }
}

extension Token {
    
}
