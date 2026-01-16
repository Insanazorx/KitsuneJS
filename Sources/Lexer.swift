import Foundation


// define token between apostrophes as a string 
public class Lexer {
    // Lexeme kinds the lexer can recognize
    public enum LexemeType: CaseIterable, Equatable, CustomStringConvertible {
        case keyword
        case identifier
        case number
        case string
        case operatorSymbol
        case punctuation
        case comment
        case whitespace

        public var description: String {
            switch self {
            case .keyword: return "Keyword"
            case .identifier: return "Identifier"
            case .number: return "Number"
            case .string: return "String"
            case .operatorSymbol: return "Operator"
            case .punctuation: return "Punctuation"
            case .comment: return "Comment"
            case .whitespace: return "Whitespace"
            }
        }
    }

    private let keywords: Set<String>
    private let operators: [String]

    // MARK: - Regex Patterns (as Strings)
    private static func escape(_ s: String) -> String {
        // Escape meta characters so they can join safely into alternations
        let pattern = #"[.*+?^${}()|\[\]\\]"#
        return s.replacingOccurrences(of: pattern, with: #"\\$0"#, options: .regularExpression)
    }

    private var keywordAlternation: String {
        let parts = keywords.map(Lexer.escape).sorted { $0.count > $1.count }
        return parts.joined(separator: "|")
    }

    private var operatorAlternation: String {
        let parts = operators.map(Lexer.escape).sorted { $0.count > $1.count }
        return parts.joined(separator: "|")
    }

    private static let identifierPattern = #"^[A-Za-z_][A-Za-z0-9_]*"#
    private static let numberPattern = #"^\d+"#
    private static let stringPattern = #"^\"(?:[^\"\\]|\\.)*\""#
    private static let punctuationPattern = #"^[\(\)\{\}\[\];,\.]"#
    private static let lineCommentPattern = #"^//[^\n]*"#
    private static let blockCommentPattern = #"^/\*[\s\S]*?\*/"# // [\s\S] so dot matches newlines
    private static let whitespacePattern = #"^\s+"#

    private func pattern(for type: LexemeType) -> String {
        switch type {
        case .keyword:
            // identifier shape + boundary, but will be rechecked via set too
            return #"^(?:"# + keywordAlternation + #")\b"#
        case .identifier:
            return Lexer.identifierPattern
        case .number:
            return Lexer.numberPattern
        case .string:
            return Lexer.stringPattern
        case .operatorSymbol:
            return #"^(?:"# + operatorAlternation + #")"#
        case .punctuation:
            return Lexer.punctuationPattern
        case .comment:
            return #"^(?:"# + Lexer.lineCommentPattern.dropFirst(1) + #"|"# + Lexer.blockCommentPattern.dropFirst(1) + #")"#
        case .whitespace:
            return Lexer.whitespacePattern
        }
    }

    struct RegexCache {
        let map: [LexemeType: NSRegularExpression]

        static func build(patternFor: (Lexer.LexemeType) -> String) -> RegexCache {
            var dict: [LexemeType: NSRegularExpression] = [:]
            for kind in LexemeType.allCases {
                let patt = patternFor(kind)
                if let re = try? NSRegularExpression(pattern: patt, options: []) {
                    dict[kind] = re
                } else {
                    fatalError("Invalid regex for kind: \(kind) -> \(patt)")
                }
            }
            return RegexCache(map: dict)
        }

        func regex(for kind: LexemeType) -> NSRegularExpression { map[kind]! }
    }

    private lazy var regexCache: RegexCache = {
        RegexCache.build(patternFor: self.pattern(for:))
    }()
    private let input: String
    private var index: String.Index

    public init(input: String, keywords: Set<String>, operators: [String]) {
        self.input = input
        self.keywords = keywords
        self.operators = operators
        self.index = input.startIndex
    }

    public convenience init(_ input: String) {
        self.init(
            input: input,
            keywords: [
                "if", "else", "while", "for", "return", "do", "throw", "try",
                "function", "var", "let", "const", "of", "in", "switch", "export",
                "class", "enum", "import", "break", "continue", "async", "await",
                "this", "super", "new", "typeof", "void", "delete", "yield", "catch", 
                "finally", "default", "null", "true", "false", "undefined"
            ],
            operators: [
                "==", "!=", "<=", ">=", "&&", "||",
                "+", "-", "*", "/", "=", "<", ">", 
                "=>", "++", "--", "+=", "-=", "*=", "/=",
                "...", "?", ":", "!", ".", "&", "|",
                "^", "%", "~", "===", "!==" , "<<", ">>", ">>>",
                "<<=", ">>=", ">>>="
            ]
        )
    }

    private var isAtEnd: Bool { index >= input.endIndex }
    private var rest: Substring { input[index...] }

    private func advance(by n: Int) { index = input.index(index, offsetBy: n, limitedBy: input.endIndex) ?? input.endIndex }

    private func match(_ kind: LexemeType) -> String? {
        let re = regexCache.regex(for: kind)
        let slice = String(rest)
        let range = NSRange(location: 0, length: slice.utf16.count)
        guard let m = re.firstMatch(in: slice, options: [], range: range) else { return nil }
        guard m.range.location == 0, let r = Range(m.range, in: slice) else { return nil }
        return String(slice[r])
    }

    
    public func tokenize() -> [Token] {
    var tokens: [Token] = []
    var lineTerminatorSeen = false

    func containsLineTerminator(_ s: String) -> Bool {
        return s.contains("\n") || s.contains("\r") || s.contains("\u{2028}") || s.contains("\u{2029}")
    }

    while !isAtEnd {

        if let ws = match(.whitespace) {
            if containsLineTerminator(ws) { lineTerminatorSeen = true }
            advance(by: ws.count)
            continue
        }

        if let com = match(.comment) {
            // line comment match'i newline'ı içermez; block comment newline içerebilir.
            if com.hasPrefix("/*") && containsLineTerminator(com) { lineTerminatorSeen = true }
            advance(by: com.count)
            continue
        }

        if let s = match(.string) {
            tokens.append(Token(lexType: .string, lexeme: s, isPreceededByLineTerminator: lineTerminatorSeen))
            lineTerminatorSeen = false
            advance(by: s.count)
            continue
        }

        if let n = match(.number) {
            tokens.append(Token(lexType: .number, lexeme: n, isPreceededByLineTerminator: lineTerminatorSeen))
            lineTerminatorSeen = false
            advance(by: n.count)
            continue
        }

        if let ident = match(.identifier) {
            let kind: LexemeType = keywords.contains(ident) ? .keyword : .identifier
            tokens.append(Token(lexType: kind, lexeme: ident, isPreceededByLineTerminator: lineTerminatorSeen))
            lineTerminatorSeen = false
            advance(by: ident.count)
            continue
        }

        if let op = match(.operatorSymbol) {
            tokens.append(Token(lexType: .operatorSymbol, lexeme: op, isPreceededByLineTerminator: lineTerminatorSeen))
            lineTerminatorSeen = false
            advance(by: op.count)
            continue
        }

        if let p = match(.punctuation) {
            tokens.append(Token(lexType: .punctuation, lexeme: p, isPreceededByLineTerminator: lineTerminatorSeen))
            lineTerminatorSeen = false
            advance(by: p.count)
            continue
        }

        let ch = String(rest.prefix(1))
        tokens.append(Token(lexType: .punctuation, lexeme: ch, isPreceededByLineTerminator: lineTerminatorSeen))
        lineTerminatorSeen = false
        advance(by: ch.count)
    }

    return tokens
}
}
