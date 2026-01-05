public enum TokenType : Equatable {
    case identifier(String)
    case number(Int)
    case float(Double)
    case string(String)
    case boolean(Bool)
    case null
    case undefined

    case `async`, `await`, `break`, `case`, `catch`, `class`
    case `const`, `continue`, `default`, `do`, `else`, `enum`
    case `eval`, `export`, `extends`, `false`, `finally`, `for`
    case `function`, `if`, `import`, `let`
    case `new`, `of`, `return`, `super`, `switch`, `this`, `throw`
    case `true`, `try`, `var`, `while`, `yield`

    case binaryOp(BinaryOperation)
    case unaryOp(UnaryOperation)
    case updateOp(UpdateOperation)
    case arrow, dot
    case leftParen, rightParen
    case leftBrace, rightBrace
    case leftBracket, rightBracket
    case semicolon, colon, comma
}

public enum BinaryOperation{
    case equal, notEqual, lessThan, greaterThan
    case lessThanOrEqual, greaterThanOrEqual
    case logicalAnd, logicalOr, instanceof
    case plus, minus, multiply, divide, assign
    case plusAssign, minusAssign, multiplyAssign, divideAssign
    case caret, percent, ampersand, pipe, `in`
    case strictEqual, strictNotEqual
}

public enum UnaryOperation{
    case exclamationMark, tilde
    case typeof, delete
    case void
}  

public enum UpdateOperation {
    case increment, decrement
}

public struct Token: CustomStringConvertible, Equatable {
    public var description: String { "Token(\(lexType), \"\(lexeme)\")" }
    
    public let lexType: Lexer.LexemeType
    public let lexeme: String

    public var tokenType: TokenType? {
        switch lexType {
        case .identifier:
            return .identifier(lexeme)
        case .number:
            return .number(Int(lexeme) ?? 0)
        case .string:
            return .string(lexeme)
        default:
            break;
        }
        switch lexeme {
            //literals
            case "true": return .boolean(true)
            case "false": return .boolean(false)
            //keywords
            case "async": return .async
            case "await": return .await
            case "break": return .break
            case "case": return .case
            case "catch": return .catch
            case "class": return .class
            case "const": return .const
            case "continue": return .continue
            case "default": return .default
            case "delete": return .unaryOp(.delete)
            case "do": return .do
            case "else": return .else
            case "enum": return .enum
            case "eval": return .eval
            case "export": return .export
            case "extends": return .extends
            case "finally": return .finally
            case "for": return .for
            case "function": return .function
            case "if": return .if
            case "import": return .import
            case "in": return .binaryOp(.in)
            case "instanceof": return .binaryOp(.instanceof)
            case "let": return .let
            case "new": return .new
            case "of": return .of
            case "return": return .return
            case "super": return .super
            case "switch": return .switch
            case "this": return .this
            case "throw": return .throw
            case "typeof": return .unaryOp(.typeof)
            case "null": return .null
            case "undefined": return .undefined
            case "try": return .try
            case "var": return .var
            case "void": return .unaryOp(.void)
            case "while": return .while
            case "yield": return .yield
            
            
            // operators        
            case "==": return .binaryOp(.equal)
            case "!=": return .binaryOp(.notEqual)
            case "<": return .binaryOp(.lessThan)
            case ">": return .binaryOp(.greaterThan)
            case "<=": return .binaryOp(.lessThanOrEqual)
            case ">=": return .binaryOp(.greaterThanOrEqual)
            case "&&": return .binaryOp(.logicalAnd)
            case "||": return .binaryOp(.logicalOr)
            case "+": return .binaryOp(.plus)
            case "-": return .binaryOp(.minus)
            case "*": return .binaryOp(.multiply)
            case "/": return .binaryOp(.divide)
            case "=": return .binaryOp(.assign)
            case "=>": return .arrow
            case "++": return .updateOp(.increment)
            case "--": return .updateOp(.decrement)
            case "+=": return .binaryOp(.plusAssign)
            case "-=": return .binaryOp(.minusAssign)
            case "*=": return .binaryOp(.multiplyAssign)
            case "/=": return .binaryOp(.divideAssign)
            case ".": return .dot
            case "&": return .binaryOp(.ampersand)
            case "|": return .binaryOp(.pipe)
            case "^": return .binaryOp(.caret)
            case "%": return .binaryOp(.percent)
            case "~": return .unaryOp(.tilde)
            case "===": return .binaryOp(.strictEqual)
            case "!==": return .binaryOp(.strictNotEqual)
            case "!": return .unaryOp(.exclamationMark)
            // punctuation
            case "(": return .leftParen
            case ")": return .rightParen
            case "{": return .leftBrace
            case "}": return .rightBrace
            case "[": return .leftBracket
            case "]": return .rightBracket
            case ";": return .semicolon
            case ":": return .colon
            case ",": return .comma
            default: fatalError("Unknown token lexeme: \(lexeme)")
        }
    }
    
    }
