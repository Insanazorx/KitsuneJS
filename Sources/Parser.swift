import Foundation

public enum ParserError: Error {
    case unexpectedToken(Int)
    case endOfInput
    case invalidSyntax(Int)
}


protocol Parsers {
    
    // Declarations
    
    func parseDeclarationStatement(isAsync: Bool) throws -> Statement?
    func parseFunctionDeclaration(isAsync: Bool) throws -> Declaration?
    func parseVariableDeclaration() throws -> Declaration?
    func parseLexicalDeclaration() throws -> Declaration?
    func parseImportDeclaration() throws -> Declaration?
    func parseExportDeclaration() throws -> Declaration?
    func parseClassDeclaration() throws -> Declaration?

    // Statements

    func parseExpressionStatement() throws -> Statement?
    func parseBlockStatement() throws -> Statement?
    func parseAsyncStatement() throws -> Statement?

    func parseIfStatement() throws -> Statement?
    func parseWhileStatement() throws -> Statement?
    func parseDoWhileStatement() throws -> Statement?

    func parseForStatement() throws -> Statement?
    func parseForInStatement() throws -> Statement?
    func parseForOfStatement() throws -> Statement?

    func parseReturnStatement() throws -> Statement?
    func parseBreakStatement() throws -> Statement?
    func parseContinueStatement() throws -> Statement?

    func parseThrowStatement() throws -> Statement?
    func parseTryStatement() throws -> Statement?
    func parseSwitchStatement() throws -> Statement?
    func parseLabelledStatement() throws -> Statement?

    func parseEmptyStatement() throws -> Statement?
    
    // Expressions
    /*  
        Parsing precedence climbing order:

        PrimaryExpression
                ↓
        MemberExpression
                ↓
        CallExpression
                ↓
        UnaryExpression
                ↓
        BinaryExpression
                ↓
        AssignmentExpression
    */

    func parseAssignmentExpression() throws -> Expression?  //implement

    func parseBinaryExpression() throws -> Expression?      //implement
    func parseUnaryExpression() throws -> Expression?
    
    func parseCallExpression() throws -> Expression?
    func parseMemberExpression() throws -> Expression?
    
    func parsePrimaryExpression() throws -> Expression?     //implement
    
    func parseFunctionExpression(isAsync: Bool) throws -> Expression?
    func classExpression() throws -> Expression?
    func parseArrayLiteral() throws -> Expression?
    func parseObjectLiteral() throws -> Expression?
    func parseArrowFunction() throws -> Expression?
    
    func parseParenthesizedExpression() throws -> Expression?

}


protocol ParserCore {
    func parse() throws -> ASTNode 
    func parseExpression() throws -> Expression?
    func parseStatement(isAsync: Bool) throws -> Statement?
    func advance()-> Void
    func currentToken() -> Token?
    func peekToken(aheadBy n: Int) -> Token?
}

public class Parser {
    let tokens: [Token];
    var currentTokenIndex: Int = 0;

    public init(_ input: [Token]) {
        self.tokens = input;
        print ("Tokens:");
        for token in tokens {
            print (token.description);
        }
    }
}

extension Parser {
    func expect(tokenType: TokenType) throws -> Void {
        guard let token = currentToken() else {
            throw ParserError.endOfInput
        }
        if token.tokenType == tokenType {
            advance()
        } else {
            throw ParserError.unexpectedToken(currentTokenIndex)
        }
    }

    // Pratt binding powers (lbp/rbp) for TokenType in Token.swift.
    // Higher number = binds tighter.
    // For left-associative operators we use (p, p+1).
    // For right-associative operators (assignment) we use (p, p-1).
    func BindingPower(for operatorToken: TokenType) -> (left: Int, right: Int)? {
        switch operatorToken {

        // Postfix / Secondary expressions (call, member, index)
        // NOTE: `.leftParen` here means "call" when it appears after an expression.
        case .dot, .leftBracket, .leftParen, .leftBrace:
            return (20, 21)

// Unary operators: new, instanceof
        case .unaryOp(.new), .unaryOp(.instanceof):
            return (19, 20)
            
        // Postfix update (can also be prefix in your nud/unary parser)
        case .unaryOp(.increment), .unaryOp(.decrement):
            return (18, 19)

        // Unary operators (typically handled in nud, but precedence is useful for Pratt plumbing)
        case .unaryOp(.tilde), .unaryOp(.exclamationMark):
            return (17, 18)

        // Unary operators: typeof, delete, void
        case .unaryOp(.typeof), .unaryOp(.delete), .unaryOp(.void):
            return (17, 18)

        // Multiplicative
        case .binaryOp(let op) where op == .multiply || op == .divide || op == .percent:
            return (15, 16)

        // Additive
        case .binaryOp(let op) where op == .plus || op == .minus:
            return (14, 15)

        // Relational
        case .binaryOp(let op) where op == .lessThan || op == .lessThanOrEqual || op == .greaterThan || op == .greaterThanOrEqual:
            return (12, 13)

        case .in:
            return (12, 13)
        // Equality
        case .binaryOp(let op) where op == .equal || op == .notEqual || op == .strictEqual || op == .strictNotEqual:
            return (11, 12)

        // Bitwise
        case .ampersand:
            return (10, 11)
        case .binaryOp (let caret) where caret == .caret:
            return (9, 10)
        case .pipe:
            return (8, 9)

        // Logical
        case .binaryOp(let op) where op == .logicalAnd:
            return (6, 7)
        case .binaryOp(let op) where op == .logicalOr:
            return (5, 6)

        // Assignment (right-associative)
        // NOTE: Token.swift maps '=' to `.assign`.
        case .binaryOp(let op) where op == .assign || op == .plusAssign || op == .minusAssign || op == .multiplyAssign || op == .divideAssign:
            return (3, 2)

        // Comma (lowest)
        case .comma:
            return (1, 2)

        default:
            fatalError("No binding power for token type: \(operatorToken)")
        }
    }
}

extension Parser : ParserCore {
   
    internal func advance() {
        currentTokenIndex += 1;
    }

    func currentToken() -> Token? {
        if currentTokenIndex < tokens.count {
            return tokens[currentTokenIndex]
        }
        return nil
    }

    func peekToken(aheadBy n: Int) -> Token? {
        let peekIndex = currentTokenIndex + n
        if peekIndex < tokens.count {
            return tokens[peekIndex]
        }
        return nil
    }

    public func parse()throws -> ASTNode {
        print("Parsing started...");

        var stmts: [Statement] = [];

        do {
            while let stmt = try parseStatement() {
                stmts.append(stmt);
            }        
            
        } catch {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        let program = Program.program(body: stmts);

       return ASTNode.program(program);
    }

    func parseStatement(isAsync: Bool = false) throws -> Statement? {

        switch currentToken()?.tokenType {
            case .if:
                return try parseIfStatement()
            case .while:
                return try parseWhileStatement()
            case .do:
                return try parseDoWhileStatement()
            case .for:
                return try parseForStatement()
            case .return:
                return try parseReturnStatement()
            case .break:
                return try parseBreakStatement()
            case .continue:
                return try parseContinueStatement()
            case .class, .var, .let, .const, .import, .export: 
                return try parseDeclarationStatement(isAsync: isAsync)
            case .function:
                if case .identifier(_) = peekToken(aheadBy: 1)?.tokenType ,
                   case .identifier(_) = peekToken(aheadBy: 2)?.tokenType {
                    return try parseExpressionStatement();   
                } 
                return try parseDeclarationStatement(isAsync: isAsync)
            case .throw:
                return try parseThrowStatement()
            case .try:
                return try parseTryStatement()
            case .switch:
                return try parseSwitchStatement()
            case .leftBrace:
                return try parseBlockStatement()
            case .async:
                return try parseAsyncStatement()
            case .semicolon:
                return try parseEmptyStatement()
            default:
                break
        }
        return try parseExpressionStatement()
    }

    func parseExpression() throws -> Expression? {
        let nud_expr  = try parsePrimaryExpression();        
        return nil
    }
    
}

extension Parser : Parsers {
    // Expressions
    func parsePrimaryExpression() throws -> Expression? {
        switch currentToken()?.tokenType {
            case .this:
                advance()
                return Expression.this
            case .identifier(let name):     
                advance()
                return Expression.identifier(name)
            case .number(let value):
                advance()
                return Expression.literal(.int(value))
            case .float(let value):
                advance()
                return Expression.literal(.float(value))
            case .string(let value):
                advance()
                return Expression.literal(.string(value))
            case .boolean(let value):
                advance()
                return Expression.literal(.bool(value))
            case .null:
                advance()
                return Expression.literal(.null)
            case .undefined:
                advance()
                return Expression.literal(.undefined)
            case .leftParen:
                return try parseParenthesizedExpression()
            case .leftBracket:
                return try parseArrayLiteral()
            case .leftBrace:
                return try parseObjectLiteral()
            case .function:
                return try parseFunctionExpression(isAsync: false)
            case .class:
                return try classExpression()
            case .async:
                advance()
                return try parseFunctionExpression(isAsync: true)
            default: 
                fatalError("Unexpected token in primary expression: \(String(describing: currentToken()))")
        }
        return nil
    }
    func parseBinaryExpression() throws -> Expression? {
        return nil
    }
    func parseUnaryExpression() throws -> Expression? {
        return nil
    }
    func parseAssignmentExpression() throws -> Expression? {
        return nil
    }
    func parseCallExpression() throws -> Expression? {
        return nil
    }
    func parseMemberExpression() throws -> Expression? {
        return nil
    }

    func parseFunctionExpression(isAsync: Bool) throws -> Expression? {
        return nil
    }

    func classExpression() throws -> Expression? {
        return nil
    }

    func parseArrayLiteral() throws -> Expression? {
        return nil
    }
    func parseObjectLiteral() throws -> Expression? {
        return nil
    }
    func parseArrowFunction() throws -> Expression? {
        return nil
    }

    func parseParenthesizedExpression() throws -> Expression? {
        return nil
    }
    
    // Statements
    func parseAsyncStatement() throws -> Statement? {
        return nil
    }

    func parseBlockStatement() throws -> Statement? {
        
        advance() // consume '{'
        
        var body: [Statement] = []
        while currentToken()?.tokenType != .rightBrace {
            if let stmt = try parseStatement() {
                body.append(stmt)
            } else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }
        }

        advance() // consume '}'

        return Statement.block(statements: body)
    }
    
    func parseExpressionStatement() throws -> Statement? {
        if let expr = try parseExpression() {
            try expect(tokenType: .semicolon) // consume ';'
            return Statement.expressionStatement(expr)
        }
        return nil
    }

    func parseDeclarationStatement(isAsync: Bool) throws -> Statement? {
        switch currentToken()?.tokenType {
            case .function:
                if let decl = try parseFunctionDeclaration(isAsync: isAsync) {
                    return Statement.declarationStatement(decl)
                }
            case .var:
                if let decl = try parseVariableDeclaration() {
                    return Statement.declarationStatement(decl)
                }
            case .let, .const:
                if let decl = try parseLexicalDeclaration() {
                    return Statement.declarationStatement(decl)
                }
            case .import:
                if let decl = try parseImportDeclaration() {
                    return Statement.declarationStatement(decl)
                }
            case .class:
                if let decl = try parseClassDeclaration() {
                    return Statement.declarationStatement(decl)
                }
            case .export:
                if let decl = try parseExportDeclaration() {
                    return Statement.declarationStatement(decl)
                }
            default:
                break
        }
        return nil
    }
    
    func parseFunctionDeclaration(isAsync: Bool) throws -> Declaration? {

        advance()         // consume 'function' keyword

        var isGeneratorPresent = false
        if case let .binaryOp(op) = currentToken()?.tokenType, op == .multiply { // TODO: change multiply to asterisk
            advance()     // consume '*' for generator function
            isGeneratorPresent = true
        }

        guard case let .identifier(func_name) = currentToken()?.tokenType else { //get function name
            throw ParserError.unexpectedToken(currentTokenIndex)
        }
        let name = Expression.identifier(func_name)
    
        advance()         // consume function name

        try expect(tokenType: .leftParen)   // consume '(' 
    
        var args: [Expression?] = []                                                        
        while case let .identifier(param_name) = currentToken()?.tokenType {               
            args.append(.identifier(param_name))
            advance()                                   // consume parameter name
            if case .comma = currentToken()?.tokenType {
                advance()                               // consume ','
            } else {
                break
            }
        }

        try expect(tokenType: .rightParen)  // consume ')'

        guard let body: Statement = try parseBlockStatement() else { // parse function body as BlockStatement
            throw ParserError.invalidSyntax(currentTokenIndex)
        } 

        return .function(
            name: name,
            params: args, 
            body: body, 
            isAsync: isAsync, 
            isGenerator: isGeneratorPresent
        )

    }
    
    func parseVariableDeclaration() throws -> Declaration? {
        advance() // consume 'var' keyword

        var declarations: [Expression?] = []
        while case let .identifier(var_name) = currentToken()?.tokenType {
            
            declarations.append(.identifier(var_name))
            advance() // consume identifier
            
            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
            } else {
                break
            }
        }

        var maybeAssignments: [Expression]? = nil

        if case .binaryOp(let op) = currentToken()?.tokenType, op == .assign     {
            advance()
            for _ in declarations {
                if let expr = try parseExpression() {
                    maybeAssignments?.append(expr)
                } else {
                    throw ParserError.invalidSyntax(currentTokenIndex)
                }
                if case .comma = currentToken()?.tokenType {
                    advance() // consume ','
                } else {
                    break
                }
            }
        }
    
    //function add(a, b) {
    //    var c = a + b;
    //    return c;
    //}
        return nil
    }
    
    func parseLexicalDeclaration() throws -> Declaration? {
        
        var kind : LexicalKind
        switch currentToken()?.tokenType {
            case .let:
                kind = .let
            case .const:
                kind = .const
            default:
                throw ParserError.unexpectedToken(currentTokenIndex)
        }

            advance() // consume 'let' or 'const' keyword
    
            var declarations: [Expression?] = []
    
            while case let .identifier(var_name) = currentToken()?.tokenType {
                declarations.append(.identifier(var_name))
                advance() // consume identifier
    
                if case .comma = currentToken()?.tokenType {
                    advance() // consume ','
                } else {
                    break
                }
            }

            var assignments: [Expression]? = nil

            if case .binaryOp(let op) = currentToken()?.tokenType, op == .assign     {
                advance() // consume '='
                for _ in declarations {
                    if let expr = try parseExpression() {
                        assignments?.append(expr)
                    } else {
                        throw ParserError.invalidSyntax(currentTokenIndex)
                    }
                    if case .comma = currentToken()?.tokenType {
                        advance() // consume ','
                    } else {
                        break
                    }
                }
            }
    
            try expect(tokenType: .semicolon) // consume ';'
    
            return .lexical(kind: kind, declarations: declarations, assignments: assignments)
        
    }
    
    func parseImportDeclaration() throws -> Declaration? {
        return nil
    }
    
    func parseExportDeclaration() throws -> Declaration? {
        return nil
    }
    
    func parseClassDeclaration() throws -> Declaration? {
        return nil
    }

    func parseIfStatement() throws -> Statement? {
        return nil
    }

    func parseWhileStatement() throws -> Statement? {
        return nil
    }

    func parseDoWhileStatement() throws -> Statement? {
        return nil
    }

    func parseForStatement() throws -> Statement? {
        return nil
    }

    func parseForInStatement() throws -> Statement? {
        return nil
    }
    func parseForOfStatement() throws -> Statement? {
        return nil  
    }
    func parseReturnStatement() throws -> Statement? {
        print("Parsing return statement...")
        
        advance() // consume 'return' keyword

        if let expr = try parseExpression() {
            return .returnStatement(argument: expr)
        } else {
            return .returnStatement(argument: nil)
        }
    }
    func parseBreakStatement() throws -> Statement? {
        return nil
    }

    func parseContinueStatement() throws -> Statement? {
        return nil
    }

    func parseThrowStatement() throws -> Statement? {
        return nil
    }

    func parseTryStatement() throws -> Statement? {
        return nil
    }
    func parseSwitchStatement() throws -> Statement? {
        return nil
    }
    func parseLabelledStatement() throws -> Statement? {
        return nil
    }
    func parseEmptyStatement() throws -> Statement? {
        return nil
    }


}









