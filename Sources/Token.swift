public enum TokenType : Equatable {
    case identifier(String)
    case number(Int)
    case string(String)
    case boolean(Bool)
    
    case `if`, `else`, `while`, `for`, `return`, `do` , `throw`, `try`
    case `function`, `var`, `let`, `const`, `of`, `in`, `switch`, `export`
    case `class`, `struct`, `enum`, `import`, `break`, `continue`, `async`

    case equal, notEqual, lessThan, greaterThan
    case lessThanOrEqual, greaterThanOrEqual
    case logicalAnd, logicalOr
    case plus, minus, multiply, divide, assign
    case arrow, increment, decrement
    case plusAssign, minusAssign, multiplyAssign, divideAssign
    case dot, ampersand, pipe
    case caret, percent, tilde
    case strictEqual, strictNotEqual

    case leftParen, rightParen
    case leftBrace, rightBrace
    case leftBracket, rightBracket
    case semicolon, colon, comma
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
            case "if": return .if
            case "else": return .else
            case "while": return .while
            case "do": return .do
            case "for": return .for
            case "return": return .return
            case "function": return .function   
            case "var": return .var
            case "let": return .let
            case "const": return .const
            case "class": return .class
            case "struct": return .struct
            case "enum": return .enum
            case "import": return .import
            case "break": return .break
            case "continue": return .continue
            case "async": return .async
            case "switch": return .switch
            case "throw": return .throw
            case "try": return .try
            case "export": return .export
            
            // operators        
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
