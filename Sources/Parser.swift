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

    func parseNudExpression() throws -> Expression?
    
    func parseAssignmentExpression() throws -> Expression?  

    func parseBinaryExpression() throws -> Expression?      
    func parseUnaryExpression() throws -> Expression?
    
    func parseCallExpression(callee lhs: Expression) throws -> Expression?
    func parseMemberExpression(object lhs: Expression) throws -> Expression?
    func parseComputedMemberExpression(object lhs: Expression) throws -> Expression?
    
    func parseNewExpression() throws -> Expression?    
    func parseYieldExpression() throws -> Expression?  
    func parseAwaitExpression() throws -> Expression?  

    func parseFunctionExpression(isAsync: Bool) throws -> Expression?
    func parseClassExpression() throws -> Expression?
    func parseArrayLiteral() throws -> Expression?
    func parseObjectLiteral() throws -> Expression?
    func parseArrowFunction(isAsync: Bool, Args: Expression) throws -> Expression?
    func parseSequenceExpression(lhs: Expression, rhs: Expression) throws -> Expression?

    func parseParenthesizedExpression() throws -> Expression?

}


protocol ParserCore {
    func parse() throws -> ASTNode 
    func parseExpression(precedence currentbp: Int) throws -> Expression?
    func parseStatement(isAsync: Bool) throws -> Statement?
    func advance()-> Void
    func currentToken() -> Token?
    func peekToken(aheadBy n: Int) -> Token?
    func consumeSemicolon() throws
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
        case .dot, .leftBracket, .leftParen:
            return (20, 21)

// Unary operators: new, instanceof
        case .new, .binaryOp(.instanceof):
            return (19, 20)
            
        // Postfix update (can also be prefix in your nud/unary parser)
        case .updateOp(.increment), .updateOp(.decrement):
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
        case .binaryOp(let op) where op == .ampersand:
            return (10, 11)
        case .binaryOp (let caret) where caret == .caret:
            return (9, 10)
        case .binaryOp(let op) where op == .pipe:
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
            return nil
        }
    }
}

extension Parser : ParserCore {

    func consumeSemicolon() throws {
        if currentToken()?.tokenType == .semicolon {
        advance()
            return
        }
        if currentToken() == nil || currentToken()?.tokenType == .rightBrace {
            return // ASI
        }
        throw ParserError.unexpectedToken(currentTokenIndex)
    }
   
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
        let peekIndex = currentTokenIndex + n - 1
        if peekIndex < tokens.count {
            return tokens[peekIndex]
        }
        return nil
    }

    public func parse()throws -> ASTNode {
        print("Parsing started...");

        var stmts: [Statement] = [];

            while let stmt = try parseStatement() {
                stmts.append(stmt);
                if currentToken() == nil {break} 
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
                if case .identifier(_) = peekToken(aheadBy: 1)?.tokenType {
                    return try parseDeclarationStatement(isAsync: isAsync)  
                } else if case .identifier(_) = peekToken(aheadBy: 2)?.tokenType {
                    return try parseDeclarationStatement(isAsync: isAsync)
                }
                return try parseExpressionStatement()
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


    // Pratt parser
    func parseExpression(precedence currentbp: Int) throws -> Expression? {
        guard var lhs = try parseNudExpression() else {
            throw ParserError.invalidSyntax(currentTokenIndex) 
        }
        while let opToken = currentToken()?.tokenType,
              let bp = BindingPower(for: opToken),
              bp.left >= currentbp {
            switch opToken {
                case .leftParen:
                    lhs = try parseCallExpression(callee: lhs)!
                    continue
                case .dot:
                    lhs = try parseMemberExpression(object: lhs)!
                    continue
                case .leftBracket:
                    lhs = try parseComputedMemberExpression(object: lhs)!
                    continue
                case .updateOp(let unOp) where unOp == .increment || unOp == .decrement: 
                    lhs = Expression.unary(
                        operator_: opToken,
                        argument: lhs,
                        isPrefix: false
                    )
                default:
                    break
            }
            advance() // consume operator
            guard let rhs = try parseExpression(precedence: bp.right) else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }
            switch opToken {
                case .binaryOp:
                    lhs = Expression.binary(
                        left: lhs,
                        operator_: opToken,
                        right: rhs
                    )
                case .comma:
                    lhs = try parseSequenceExpression(lhs: lhs, rhs: rhs)!
                    continue

                default:
                    fatalError("Unexpected operator token in parseExpression: \(opToken)")
            }
        }
        return lhs;
    }
    
}

extension Parser : Parsers {

    func parseNudExpression() throws -> Expression? {
        guard let tok = currentToken()?.tokenType else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        switch tok {
            case .new:
                return try parseNewExpression()
            case .yield:
                return try parseYieldExpression()
            case .await:
                return try parseAwaitExpression()

            case .updateOp(.increment), .updateOp(.decrement):
                return try parseUnaryExpression()

            case .unaryOp:
                return try parseUnaryExpression()

            // binary ops as unary (prefix) operators 
            case .binaryOp(let op) where op == .plus || op == .minus:
                return try parseUnaryExpression()

            // --- Primary / atomic starts ---
            case .this:
                advance()
                return Expression.this
            case .identifier(let name):
                
                if case .arrow = peekToken(aheadBy: 1)?.tokenType {
                    advance(); // consume identifier before entering arrow function parsing
                    return try parseArrowFunction(
                        isAsync: false,
                        Args: Expression.identifier(name)
                    )
                }
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
                let expr = try parseParenthesizedExpression()
                if currentToken()?.tokenType == .arrow {
                    return try parseArrowFunction(
                        isAsync: false, 
                        Args: expr! // TODO: make it safer
                    )
                }
                return expr
            case .leftBracket:
                return try parseArrayLiteral()
            case .leftBrace:
                return try parseObjectLiteral()
            case .function:
                return try parseFunctionExpression(isAsync: false)
            case .class:
                return try parseClassExpression()

            case .async:
                advance()
                if case .identifier(let name) = currentToken()?.tokenType {
                    if case .arrow = peekToken(aheadBy: 1)?.tokenType {
                        return try parseArrowFunction(
                            isAsync: true,
                            Args: Expression.identifier(name)
                        )
                    }
                } else if case .leftParen = currentToken()?.tokenType {
                    if case .arrow = peekToken(aheadBy: 1)?.tokenType {
                        let expr = try parseParenthesizedExpression()
                        return try parseArrowFunction(
                            isAsync: true,
                            Args: expr! //TODO: make it safer
                        )
                    }
                }
                return try parseFunctionExpression(isAsync: true)

        default:
            fatalError("Unexpected token in nud expression: \(String(describing: currentToken()))")
        }
    }




    func parseNewExpression() throws -> Expression? {
        return nil
    }
    func parseYieldExpression() throws -> Expression? {
        return nil
    }
    func parseAwaitExpression() throws -> Expression? {
        return nil
    }

    func parseBinaryExpression() throws -> Expression? {
        return nil
    }
    func parseUnaryExpression() throws -> Expression? {
        
        guard case .unaryOp (let op) = currentToken()?.tokenType else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        advance() // consume operator
        
        guard let argument = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return Expression.unary(
            operator_: .unaryOp(op),
            argument: argument,
            isPrefix: true
        )
    }
    func parseAssignmentExpression() throws -> Expression? {
        return nil
    }
    func parseCallExpression(callee lhs: Expression) throws -> Expression? {
        advance(); // consume '('
        if case .rightParen = currentToken()?.tokenType { 
            try expect(tokenType: .rightParen) // consume ')'
            return Expression.call(
                callee: lhs,
                arguments: []
            )
        } else if let arg = try parseExpression(precedence: 0) {
            try expect(tokenType: .rightParen) // consume ')'
            return Expression.call(
                callee: lhs,
                arguments: [arg]
            )
        } else if case .sequence (let exprs) = try parseExpression(precedence: 0) {
            try expect(tokenType: .rightParen) // consume ')'
            
            return Expression.call(
                callee: lhs,
                arguments: exprs
            )
        } else {
            throw ParserError.invalidSyntax(currentTokenIndex)
            
        } 
            
    }
    func parseMemberExpression(object lhs: Expression) throws -> Expression? {
        
            advance() // consume '.'
            
            guard case let .identifier(propertyName) = currentToken()?.tokenType else {
                throw ParserError.unexpectedToken(currentTokenIndex)
            }
            advance() // consume property identifier

            return Expression.member(
                object: lhs,
                property: .identifier(propertyName)
            )
        
    
    }
    func parseComputedMemberExpression(object lhs: Expression) throws -> Expression? {
        
        advance() // consume '['

        if case .rightBracket = currentToken()?.tokenType {
            throw ParserError.unexpectedToken(currentTokenIndex)
        } 

        guard let propertyExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        try expect(tokenType: .rightBracket) // consume ']'
        
        return Expression.computedMember(
            object: lhs,
            property: propertyExpr
        )
    }


    // Do not use directly, use with parseExpression
    internal func parseSequenceExpression(lhs: Expression, rhs: Expression) throws -> Expression? { 
        if case .sequence(let exprs) = lhs {
            var newExprs = exprs
            newExprs.append(rhs)
            return Expression.sequence(expressions: newExprs)
        } else {
            return Expression.sequence(expressions: [lhs, rhs])
        }
    
    }

    func parseFunctionExpression(isAsync: Bool) throws -> Expression? {
        return nil
    }

    func parseArrowFunction(isAsync: Bool, Args: Expression) throws -> Expression? {
        // ( ) => {}
        // arg => {}
        // ~~~ shown parts are already consumed
        if case .parenthesized(let params) = Args {
            advance()

            if let bodyStmt = try parseStatement() {
                
                return Expression.arrowFunction(
                    params: [params], //TODO: fix later for multiple params 
                    body: bodyStmt,
                    isAsync: isAsync
                )
            } else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }


        } else if case .identifier(let name) = Args {
            advance() // consume '=>'
            if let bodyStmt = try parseStatement() {
    
                return Expression.arrowFunction(
                    params: [Expression.identifier(name)],
                    body: bodyStmt,
                    isAsync: isAsync
                )
            } else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }

        }
        
        return nil   
    }

    func parseClassExpression() throws -> Expression? {
        return nil
    }

    func parseArrayLiteral() throws -> Expression? {
        return nil
    }
    func parseObjectLiteral() throws -> Expression? {
        return nil
    }

    func parseParenthesizedExpression() throws -> Expression? {
        advance() // consume '('
        
        if case .rightParen = currentToken()?.tokenType {
            advance() // consume ')'
            return Expression.parenthesized(nil)
        }

        let expr = try parseExpression(precedence: 0) // parse inner expression

        try expect(tokenType: .rightParen) // consume ')' 
        return .parenthesized(expr)
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
            try consumeSemicolon();
        }

        advance() // consume '}'

        return Statement.block(statements: body)
    }
    
    func parseExpressionStatement() throws -> Statement? {
        if let expr = try parseExpression(precedence: 0) {
            try expect(tokenType: .semicolon) // consume ';'
            return Statement.expressionStatement(expr)
        }
        return nil
    }

    func parseDeclarationStatement(isAsync: Bool) throws -> Statement? {
        switch  currentToken()?.tokenType {
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

        var maybeAssignments: [Expression] = []

        if case .binaryOp(let op) = currentToken()?.tokenType, 
                op == .assign {
            advance()
            for _ in declarations {
                if let expr = try parseExpression(precedence: 0) {
                    maybeAssignments.append(expr)
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
        return .variable(
            declarations: declarations,
            assignments: maybeAssignments
        )
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
                    if let expr = try parseExpression(precedence: 0) {
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
        
        advance() // consume 'return' keyword

        if let expr = try parseExpression(precedence: 0) {
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









