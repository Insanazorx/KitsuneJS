import Foundation

public enum ParserError: Error {
    case unexpectedToken(Int)
    case endOfInput
    case invalidSyntax(Int)
}

protocol Parsers {
    // Statements
    func parseBlockStatement() throws -> Statement?
    func parseExpressionStatement() throws -> Statement?
    func parseDeclarationStatement(isAsync: Bool) throws -> Statement?
    func parseFunctionDeclaration(isAsync: Bool) throws -> Declaration?
    func parseVariableDeclaration() throws -> Declaration?
    func parseLexicalDeclaration() throws -> Declaration?
    func parseImportDeclaration() throws -> Declaration?
    func parseExportDeclaration() throws -> Declaration?
    func parseClassDeclaration() throws -> Declaration?

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
    func parsePrimaryExpression() throws -> Expression?

    func parseBinaryExpression() throws -> Expression?
    func parseUnaryExpression() throws -> Expression?
    
    func parseAssignmentExpression() throws -> Expression?
    
    func parseCallExpression() throws -> Expression?
    func parseMemberExpression() throws -> Expression?
    
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
    func isAtEndOfRule() -> Bool

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

    func isAtEndOfRule() -> Bool {
        return false
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

    func parseExpression() throws -> Expression? {
        
        return nil
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
            case .function, .class, .var, .let, .const, .import, .export: 
                return try parseDeclarationStatement(isAsync: isAsync)
            case .throw:
                return try parseThrowStatement()
            case .try:
                return try parseTryStatement()
            case .switch:
                return try parseSwitchStatement()
            case .async:
                return try parseAsyncStatement();
            default:
                break
        }
        return try parseExpressionStatement()
    }

    
    
}

extension Parser : Parsers {
    
    func parseAsyncStatement() throws -> Statement? {
        return nil
    }
    
    // Statements
    func parseBlockStatement() throws -> Statement? {
        return nil
    }
    
    func parseExpressionStatement() throws -> Statement? {
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
        if case .multiply = currentToken()?.tokenType { // TODO: change multiply to asterisk
            advance()     // consume '*' for generator function
            isGeneratorPresent = true
        }

        guard case let .identifier(func_name) = currentToken()?.tokenType else { //get function name
            throw ParserError.unexpectedToken(currentTokenIndex)
        }

        advance() // consume function name
    
        try expect(tokenType: .leftParen)   // consume '(' 
    
        guard let args: Statement = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .rightParen)  // consume ')'

        guard let body: Statement = try parseStatement() else { // parse function body as BlockStatement
            throw ParserError.invalidSyntax(currentTokenIndex)
        } 
        return .function(name: func_name, params: args, body: body, isAsync: isAsync, isGenerator: isGeneratorPresent)
    

    //function add(a, b) {
    //    let c = a + b;
    //    return c;
    //}

    }
    
    func parseVariableDeclaration() throws -> Declaration? {
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
    
            var declarations: [String] = []
    
            while case let .identifier(var_name) = currentToken()?.tokenType {
                declarations.append(var_name)
                advance() // consume identifier
    
                if case .comma = currentToken()?.tokenType {
                    advance() // consume ','
                } else {
                    break
                }
            }

            var assignments: [Expression]? = nil

            if case .equal = currentToken()?.tokenType {
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
    // Expressions
    func parsePrimaryExpression() throws -> Expression? {
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


}









