/* 
 * This parser should implement this semantics analyzer functionalities:
 *	•	Scope tree (Global / Function / Block / Catch / Class / Module)
 *	•	Binding kayıtları: var/let/const/function/class/param/import
 *	•	Hoisting planı (var + function decl)
 *	•	TDZ kapsamı (let/const/class)
 *	•	Label çözümü (break/continue hedefi)
 *	•	“early error” kuralları (syntax değil ama runtime’dan önce patlayanlar)
 *	•	Identifier resolution → slot index / environment depth üret
 *	•	Closure capture analizi (hangi değişken outer’dan yakalanıyor?)
 *  
 * And some other features must be implemented in runtime which fits this parser:
 *  •	Environment chain (Declarative/Object env)
 *	•	TDZ enforcement (uninitialized binding read → throw)
 *	•	this binding, arguments, new.target, super
 *	•	Property access (obj[prop], prototype chain)
 *	•	Call/Construct ayrımı
 *	•	Exception unwinding / finally
 *	•	Promises / event loop (ileride)
 *	•	eval/with gibi dinamik özellikler yüzünden “slow path” name lookup
 */






import Foundation

public enum ParserError: Error {
    case unexpectedToken(Int)
    case endOfInput
    case invalidSyntax(Int)
}


protocol Parsers {
    
    // Declarations
    
    func parseDeclarationStatement(isAsync: Bool) throws -> Statement?                          // done
    func parseFunctionDeclaration(isAsync: Bool) throws -> Declaration?                         // done 
    func parseVariableDeclaration() throws -> Declaration?                                      // done
    func parseLexicalDeclaration() throws -> Declaration?                                       // done       
    func parseImportDeclaration() throws -> Declaration?                                          
    func parseExportDeclaration() throws -> Declaration?
    func parseClassDeclaration() throws -> Declaration? //helpers are declared below near parseClassExpression()

    // Statements

    func parseExpressionStatement() throws -> Statement?                                        // done 
    func parseBlockStatement() throws -> Statement?                                             // done    
    func parseAsyncStatement() throws -> Statement?                                             // done --> TODO: async must be able to recognized identifier depending context

    func parseIfStatement() throws -> Statement?                                                // done --> TODO: dangling else
    func parseWhileStatement() throws -> Statement?                                             // done
    func parseDoWhileStatement() throws -> Statement?                                           // done 

    func parseForStatement() throws -> Statement?                                               // done   
    func parseForInStatement() throws -> Statement?                                             // done   
    func parseForOfStatement() throws -> Statement?                                             // done 
    func parseForAwaitStatement() throws -> Statement?                                          // done

    func parseReturnStatement() throws -> Statement?                                            // done
    func parseBreakStatement() throws -> Statement?                                             // done   
    func parseContinueStatement() throws -> Statement?                                          // done    

    func parseThrowStatement() throws -> Statement?                                             // done --> TODO:  implement lexer to ensure parser gives error for line break after throw
    func parseTryStatement() throws -> Statement?                                               // done     
    func parseSwitchStatement() throws -> Statement?
    func parseLabelledStatement() throws -> Statement?

    func parseEmptyStatement() throws -> Statement?
    
    
    // Expressions

    func parseNudExpression() throws -> Expression?                                             // done
    
    func parseAssignmentExpression() throws -> Expression?                                      
   
    func parseUnaryExpression() throws -> Expression?                                           // done    
    
    func parseCallExpression(callee lhs: Expression) throws -> Expression?                      // done
    func parseMemberExpression(object lhs: Expression) throws -> Expression?                    // done   
    func parseComputedMemberExpression(object lhs: Expression) throws -> Expression?            // done
    
    func parseNewExpression() throws -> Expression?                                             // done
    func parseYieldExpression() throws -> Expression?                                   
    func parseAwaitExpression() throws -> Expression?                                           // done 

    func parseFunctionExpression(isAsync: Bool) throws -> Expression?
    func parseArrayLiteral() throws -> Expression?                                              // done  
    
    func parseClassExpression() throws -> Expression?

    //dispatcher for class element parsing
    func parseClassElement() throws -> ClassElement?
    func parseClassElementKey() throws -> ClassElementKey?
    
    //helpers for parseClassElement
    func parseClassConstructorDefinition() throws -> ClassElement?                                 // done
    func parseClassGetterDefinition(isStatic: Bool) throws -> ClassElement?
    func parseClassSetterDefinition(isStatic: Bool) throws -> ClassElement?
    func parseClassMethodDefinition(parsedKey: ClassElementKey?, isStatic: Bool) throws -> ClassElement?                      
    func parseClassFieldDefinition(isStatic: Bool) throws -> ClassElement?
    func parseStaticBlockDefinition() throws -> ClassElement?                       // done

    func parseObjectLiteral() throws -> Expression?                                             // done

    //dispatcher for object property parsing
    func parseObjectProperty() throws -> ObjectProperty?                                        // done
    func parsePropertyKey() throws -> PropertyKey?                                              // done

    // helpers for parseObjectProperty
    func parsePropertyDefinition(computedKey: PropertyKey?) throws -> ObjectProperty?           // done
    func parseMethodDefinition(computedKey: PropertyKey?, isAsync: Bool, isGenerator: Bool) throws -> ObjectProperty? //done
    func parseGetterDefinition() throws -> ObjectProperty?                                      // done  
    func parseSetterDefinition() throws -> ObjectProperty?                                      // done   
    func parseSpreadProperty() throws -> ObjectProperty?


    func parseArrowFunction(isAsync: Bool, Args: Expression) throws -> Expression?              // done
    func parseSequenceExpression(lhs: Expression, rhs: Expression) throws -> Expression?        // done

    func parseParenthesizedExpression() throws -> Expression?                                   // done   

}


protocol ParserCore {

    //TODO: add parseArgs(onlyIdentifiers: Bool)
    func parse() throws -> ASTNode 
    func parseExpression(precedence currentbp: Int, allowComma: Bool) throws -> Expression?
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

        case .binaryOp(let op) where op == .in:
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
        let peekIndex = currentTokenIndex + n
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
            case .identifier where peekToken(aheadBy: 1)?.tokenType == .colon:
                return try parseLabelledStatement()
            default:
                break
        }
        return try parseExpressionStatement()
    }


    // Pratt parser
    func parseExpression(precedence currentbp: Int, allowComma: Bool = true) throws -> Expression? {
        guard var lhs = try parseNudExpression() else {
            throw ParserError.invalidSyntax(currentTokenIndex) 
        }
        while let opToken = currentToken()?.tokenType,
              let bp = BindingPower(for: opToken),
              bp.left >= currentbp {

            if !allowComma && opToken == .comma { // for list separator parsing
                break
            }

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
                    advance();
                    lhs = Expression.unary(
                        operator_: opToken,
                        argument: lhs,
                        isPrefix: false
                    )
                    continue
                default:
                    break
            }
            advance() // consume operator
            guard let rhs = try parseExpression(precedence: bp.right) else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }
            switch opToken {
                case .binaryOp(let op) 
                where op != .assign 
                   && op != .plusAssign 
                   && op != .minusAssign 
                   && op != .multiplyAssign 
                   && op != .divideAssign:
                    lhs = Expression.binary(
                        left: lhs,
                        operator_: opToken,
                        right: rhs
                    )
                case .binaryOp(let op) 
                where op == .assign 
                   || op == .plusAssign 
                   || op == .minusAssign 
                   || op == .multiplyAssign 
                   || op == .divideAssign:
                    lhs = Expression.assignment(
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
            case .privateIdentifier(let string):
                advance()
                return Expression.privateIdentifier(string)

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
                   
                    let expr = try parseParenthesizedExpression()
                        
                        return try parseArrowFunction(
                            isAsync: true,
                            Args: expr! //TODO: make it safer
                        )
                    
                }
                
                guard let expr = try parseFunctionExpression(isAsync: true) else {
                    throw ParserError.invalidSyntax(currentTokenIndex)
                }

                return expr;

        default:
            fatalError("Unexpected token in nud expression: \(String(describing: currentToken()))")
        }
    }


    func parseNewExpression() throws -> Expression? {
        advance() // consume 'new' keyword

        guard var callee = try parseNudExpression() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        while true {
            switch currentToken()?.tokenType {
                case .dot:
                    callee = try parseMemberExpression(object: callee)!
                case .leftBracket:
                    callee = try parseComputedMemberExpression(object: callee)!
                default:
                    break;
            }
            if currentToken()?.tokenType != .dot && currentToken()?.tokenType != .leftBracket {
                break;
            }
        }

        var args: [Expression?] = []
        if case .leftParen = currentToken()?.tokenType {
            
            advance() // consume '('
            
            while currentToken()?.tokenType != .rightParen {
                
                if let arg = try parseExpression(precedence: 0, allowComma: false) {
                    args.append(arg)
                }
                
                if case .comma = currentToken()?.tokenType {
                    advance() // consume ','
                } else {
                    break
                }
            }
            
            try expect(tokenType: .rightParen) // consume ')'
            
            return Expression.new(
                callee: callee,
                arguments: args
            )
        }

        return Expression.new(
            callee: callee,
            arguments: []
        )
    }
    func parseYieldExpression() throws -> Expression? {
        return nil
    }
    func parseAwaitExpression() throws -> Expression? {
        advance(); // consume 'await' keyword

        guard let argument = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return Expression.await(
            argument: argument
        )
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
    func parseCallExpression(callee lhs: Expression) throws -> Expression? { // TODO: BURAYA BAK
        advance(); // consume '('
        
        var args: [Expression] = []

        while currentToken()?.tokenType != .rightParen {
            if let arg = try parseExpression(precedence: 0, allowComma: false) {
                args.append(arg)
            } 
            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }
        
        try expect(tokenType: .rightParen); // consume ')'

        return Expression.call(
            callee: lhs,
            arguments: args
        )
            
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

        advance() // consume 'class' keyword

        //class expression may have optional name
        var name: Expression? = nil
        
        if case .identifier(let className) = currentToken()?.tokenType {
            name = Expression.identifier(className)
            advance() // consume class name
        }
        
        var maybeSuperClassName: Expression? = nil
        
        if case .extends = currentToken()?.tokenType {
            
            advance() // consume 'extends' keyword

            if case .identifier(let superClassName) = currentToken()?.tokenType {
                maybeSuperClassName = Expression.identifier(superClassName)
                advance() // consume super class name
            } else {
                throw ParserError.unexpectedToken(currentTokenIndex)
            }
        
        }

        try expect(tokenType: .leftBrace) // consume '{'

        if case .rightBrace = currentToken()?.tokenType {
            advance() // consume '}'
            return .classExpression(
                name: name,
                superClass: maybeSuperClassName,
                body: []
            )
        }

        var bodyElements: [ClassElement] = []

        while currentToken()?.tokenType != .rightBrace {
            
            if let element = try parseClassElement() {
                bodyElements.append(element)
            } 

            try consumeSemicolon()

        }

        try expect(tokenType: .rightBrace) // consume '}'

        return .classExpression(
            name: name,
            superClass: maybeSuperClassName,
            body: bodyElements
        )
    }
    
    func parseClassElement() throws -> ClassElement? {
        switch currentToken()?.tokenType {

            case .semicolon:
                advance() // consume ';'
                return .empty
            
            case .identifier(let name) where name == "constructor":
                return try parseClassConstructorDefinition()
            
            case .identifier(let name) where name == "get":
                return try parseClassGetterDefinition(isStatic: false)
            
            case .identifier(let name) where name == "set":
                return try parseClassSetterDefinition(isStatic: false)
            
            case .binaryOp(.multiply), .async:
                return try parseClassMethodDefinition(isStatic: false)
            
            case .identifier(let name) where name == "static":
                advance() // consume 'static' keyword
                switch currentToken()?.tokenType {
                    
                    case .identifier(let name) where name == "get":
                        return try parseClassGetterDefinition(isStatic: true)
                    
                    case .identifier(let name) where name == "set":
                        return try parseClassSetterDefinition(isStatic: true)
                    
                    case .leftBrace:
                        return try parseStaticBlockDefinition()
                    
                    case .binaryOp(.multiply), .async:
                        return try parseClassMethodDefinition(isStatic: true)
                    
                    default:
                        
                        guard let parsedKey = try parseClassElementKey() else {
                            throw ParserError.invalidSyntax(currentTokenIndex)
                        }
                        
                        if case .leftParen = currentToken()?.tokenType {
                            return try parseClassMethodDefinition(parsedKey: parsedKey, isStatic: true)
                        } else {
                            return try parseClassFieldDefinition(isStatic: true)
                        } 
                    }
            
            default:
                guard let parsedKey = try parseClassElementKey() else {
                    throw ParserError.invalidSyntax(currentTokenIndex)
                }
                
                if case .leftParen = currentToken()?.tokenType {
                    return try parseClassMethodDefinition(parsedKey: parsedKey, isStatic: false)
                } else {
                    return try parseClassFieldDefinition(isStatic: false)
                }
        }
    }
    func parseClassElementKey() throws -> ClassElementKey?{
        if case .privateIdentifier(let string) = currentToken()?.tokenType {
            advance() // consume private identifier
            return ClassElementKey.privateName(.privateIdentifier(string))
        } else {
            guard let key = try parsePropertyKey() else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }
            return ClassElementKey.publicKey(key)
        }    
    }
    func parseClassConstructorDefinition() throws -> ClassElement? {
        advance() // consume 'constructor' keyword

        try expect(tokenType: .leftParen) // consume '('

        var params: [Expression] = []

        while currentToken()?.tokenType != .rightParen {
            if let param = try parseExpression(precedence: 0, allowComma: false) {
                params.append(param)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return .constructor(
            params: params,
            body: bodyStmt
        )
    }                                
    func parseClassGetterDefinition(isStatic: Bool) throws -> ClassElement?{
        advance() // consume 'get' keyword

        guard let key = try parseClassElementKey() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .leftParen) // consume '('
        try expect(tokenType: .rightParen) // consume ')'

        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return .getter(
            key: key,
            body: bodyStmt,
            isStatic: isStatic
        )

    }
    func parseClassSetterDefinition(isStatic: Bool) throws -> ClassElement?{
        advance() // consume 'set' keyword

        guard let key = try parseClassElementKey() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .leftParen) // consume '('
        guard let param = try parseExpression(precedence: 0, allowComma: false) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        try expect(tokenType: .rightParen) // consume ')'

        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        
        return .setter(
            key: key,
            param: param,
            body: bodyStmt,
            isStatic: isStatic
        )
    }
    func parseClassMethodDefinition(parsedKey: ClassElementKey? = nil, isStatic: Bool) throws -> ClassElement?{
        var isAsync: Bool = false 
        var isGenerator: Bool = false

        if case .async = currentToken()?.tokenType {
            isAsync = true
            advance() // consume 'async' keyword
        }

        if case .binaryOp(.multiply) = currentToken()?.tokenType {
            isGenerator = true
            advance() // consume '*' operator
        }

        guard let key = try parseClassElementKey() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .leftParen) // consume '('

        if case .rightParen = currentToken()?.tokenType {
            advance() // consume ')'
            guard let bodyStmt = try parseBlockStatement() else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }

            return .member(
                key: key,
                params: [],
                body: bodyStmt,
                isStatic: isStatic,
                isAsync: isAsync,
                isGenerator: isGenerator
            )
        }

        var args: [Expression] = []

        while currentToken()?.tokenType != .rightParen {
            
            let arg = try parseExpression(precedence: 0, allowComma: false)
            args.append(arg!)

            try expect(tokenType: .comma) // consume ','
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return .member(
            key: key,
            params: args,
            body: bodyStmt,
            isStatic: isStatic,
            isAsync: isAsync,
            isGenerator: isGenerator
        )
    }                      
    func parseClassFieldDefinition(isStatic: Bool) throws -> ClassElement?{
        guard let key = try parseClassElementKey() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        var initializer: Expression? = nil

        if case .binaryOp(let op) = currentToken()?.tokenType, op == .assign {
            advance() // consume '=' operator

            initializer = try parseExpression(precedence: 0)
        }

        try consumeSemicolon()

        return .field(
            key: key,
            initializer: initializer,
            isStatic: isStatic
        )
    }
    func parseStaticBlockDefinition() throws -> ClassElement?{
        advance() // consume 'static' keyword
        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return .staticBlock(statement: bodyStmt)
    }                      


    func parseArrayLiteral() throws -> Expression? {
        advance() // consume '['
        
        var elements: [Expression] = []

        while currentToken()?.tokenType != .rightBracket {
            
            if case .comma = currentToken()?.tokenType {
                elements.append(.literal(.undefined))
                advance() // consume ','
                continue
            }

            if let expr = try parseExpression(precedence: 0, allowComma: false) {
                elements.append(expr)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }

        if peekToken(aheadBy: -1)?.tokenType == .comma {
            elements.append(.literal(.undefined))
        }
            
        try expect(tokenType: .rightBracket) // consume ']'
                
        return .arrayLiteral(elements: elements)
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

    func parseObjectLiteral() throws -> Expression? {
        advance() // consume '{'

        if case .rightBrace = currentToken()?.tokenType {
            advance() // consume '}'
            return .objectLiteral(properties: [])
        }

        var properties: [ObjectProperty] = []

        while currentToken()?.tokenType != .rightBrace {
            if let prop = try parseObjectProperty() {
                properties.append(prop)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }
        try expect(tokenType: .rightBrace) // consume '}'

        return .objectLiteral(properties: properties)
    }

    func parseObjectProperty() throws -> ObjectProperty? {

   /*
    *   PropertyDefinition:
    *   - 'async' Identifier '(' → AsyncMethod       
    *   - 'async' '[' expr ']' '(' → AsyncComputedMethod
    *
    *   - '*' Identifier '(' → GeneratorMethod
    *   - '*' '[' expr ']' '(' → GeneratorComputedMethod
    *
    *   - Identifier '(' → Method
    *   - '[' expr ']' '(' → ComputedMethod
    *   
    *   - key ':' expr → KeyValueProperty
    *   
    *   - Identifier → Shorthand
    *   - '...' expr → Spread    
    *
    */
        switch currentToken()?.tokenType {
            case .async:

                advance() // consume 'async' keyword
                
                if case .leftBracket = currentToken()?.tokenType {
                    
                    guard let key = try parsePropertyKey() else {
                        throw ParserError.invalidSyntax(currentTokenIndex)
                    }
                    switch currentToken()?.tokenType {
                        case .leftParen:
                            return try parseMethodDefinition(computedKey: key, isAsync: true, isGenerator: false)
                        default:
                            throw ParserError.invalidSyntax(currentTokenIndex)
                    }
                }

                return try parseMethodDefinition(isAsync: true, isGenerator: false)

            case .binaryOp(.multiply):

                advance() // consume 'async' keyword
                
                if case .leftBracket = currentToken()?.tokenType {
                    
                    guard let key = try parsePropertyKey() else {
                        throw ParserError.invalidSyntax(currentTokenIndex)
                    }
                    switch currentToken()?.tokenType {
                        case .leftParen:
                            return try parseMethodDefinition(computedKey: key, isAsync: false, isGenerator: true)
                        default:
                            throw ParserError.invalidSyntax(currentTokenIndex)
                    }
                }

                return try parseMethodDefinition(isAsync: false, isGenerator: true)
            
            case .identifier(let name) where name == "get":
                return try parseGetterDefinition()
            
            case .identifier(let name) where name == "set":
                return try parseSetterDefinition()
            
            case .identifier(_), .string(_), .number(_):
                switch peekToken(aheadBy: 1)?.tokenType {
                    
                    case .leftParen:
                        return try parseMethodDefinition(isAsync: false, isGenerator: false)
                    
                    case .colon:
                        return try parsePropertyDefinition()
                    
                    default:
                        if case .identifier(let name) = peekToken(aheadBy: 0)?.tokenType {
                            advance() // consume identifier
                            return ObjectProperty.shorthand(.identifier(name))
                        } else {
                            throw ParserError.invalidSyntax(currentTokenIndex)
                        } 
                }
            case .leftBracket:
                guard let key = try parsePropertyKey() else {
                    throw ParserError.invalidSyntax(currentTokenIndex)
                }
                switch currentToken()?.tokenType {
                    case .leftParen:
                        return try parseMethodDefinition(computedKey: key, isAsync: false, isGenerator: false)
                    case .colon:
                        return try parsePropertyDefinition(computedKey: key)
                    default:
                        throw ParserError.invalidSyntax(currentTokenIndex)
                }
            //TODO:
            //case .ellipsis:
            //  return try parseSpreadProperty()
            default:
                throw ParserError.invalidSyntax(currentTokenIndex)
        }
        
    }

    func parsePropertyKey() throws -> PropertyKey? {

        switch currentToken()?.tokenType {
            case .identifier(let name):
                advance() // consume identifier
                return PropertyKey.identifier(name)
            
            case .number(let value):
                advance() // consume number
                return PropertyKey.literal(.int(value))

            case .float(let value):
                advance() // consume float
                return PropertyKey.literal(.float(value))

            case .string(let value):
                advance() // consume string
                return PropertyKey.literal(.string(value))

            case .boolean(let value):
                advance() // consume boolean
                return PropertyKey.literal(.bool(value))
            
            case .null:
                advance() // consume null
                return PropertyKey.literal(.null)
            
            case .undefined:
                advance() // consume undefined
                return PropertyKey.literal(.undefined)

            case .leftBracket:
                
                advance() // consume '['

                if case .rightBracket = currentToken()?.tokenType {
                    throw ParserError.unexpectedToken(currentTokenIndex)
                }
                
                guard let expr = try parseExpression(precedence: 0, allowComma: false) else {
                    throw ParserError.invalidSyntax(currentTokenIndex)
                }
                
                try expect(tokenType: .rightBracket) // consume ']'

                return PropertyKey.computed(expr)
            
            default:
                throw ParserError.invalidSyntax(currentTokenIndex)
        }
    }

    func parsePropertyDefinition(computedKey: PropertyKey? = nil) throws -> ObjectProperty? {
        
        if let key = computedKey {
            // already consumed '[' expr ']'
            try expect(tokenType: .colon) // expect ':'

            guard let valueExpr = try parseExpression(precedence: 0, allowComma: false) else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }

            return ObjectProperty.property(
                key: key,
                value: valueExpr
            )
        }

        guard let propKey = try parsePropertyKey() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .colon) // expect ':' 

        guard let valueExpr = try parseExpression(precedence: 0, allowComma: false) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return ObjectProperty.property(
            key: propKey,
            value: valueExpr
        )
    }

    func parseMethodDefinition(computedKey: PropertyKey? = nil, isAsync: Bool, isGenerator: Bool) throws -> ObjectProperty? {
    
        var name: PropertyKey?

        if case .computed = computedKey {
            // already consumed '[' expr ']'
            name = computedKey
        } else {
            name = try parsePropertyKey()
        }

        guard name != nil else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .leftParen) // consume '('

        var args: [Expression?] = []

        while currentToken()?.tokenType != .rightParen {
            if let param = try parseExpression(precedence: 0, allowComma: false) {
                args.append(param)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let body: Statement = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return ObjectProperty.method(
            key: name!,
            args: args,
            body: body,
            isAsync: isAsync,
            isGenerator: isGenerator
        )

        
    }

    func parseGetterDefinition() throws -> ObjectProperty? {
        advance() // consume 'get' keyword

        guard let name = try parsePropertyKey() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .leftParen) // consume '('
        try expect(tokenType: .rightParen) // consume ')'

        guard let body: Statement = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        return ObjectProperty.getter(
            key: name,
            body: body
        )
    }

    func parseSetterDefinition() throws -> ObjectProperty? {
        advance() // consume 'set' keyword

        guard let name = try parsePropertyKey() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .leftParen) // consume '('

        guard let arg = try parseExpression(precedence: 0, allowComma: false) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let body: Statement = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return ObjectProperty.setter(
            key: name,
            arg: arg,
            body: body
        )
    }

    func parseSpreadProperty() throws -> ObjectProperty? {
        return nil
    }
    
    // Statements
    func parseAsyncStatement() throws -> Statement? {
        advance() // consume 'async' keyword
        
        if let stmt = try parseStatement(isAsync: true) {
            switch stmt {
                case Statement.declarationStatement(let funcDecl):
                    guard case .function = funcDecl else {
                        throw ParserError.invalidSyntax(currentTokenIndex)
                    }
                    return .declarationStatement(funcDecl)

                case Statement.expressionStatement(let expr):
                    if case .arrowFunction = expr {
                        return .expressionStatement(expr)
                    } else if case .functionExpression = expr {
                        return .expressionStatement(expr)
                    }

                    return .expressionStatement(expr)
                default:
                    throw ParserError.invalidSyntax(currentTokenIndex)
            }
        }

        return nil // TODO: implement for identifier
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

        try expect(tokenType: .rightBrace) // consume '}'
        

        return Statement.block(statements: body)
    }
    
    func parseExpressionStatement() throws -> Statement? {
        if let expr = try parseExpression(precedence: 0) {
            try consumeSemicolon();
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
        var maybeAssignments: [Expression]? = nil

        if let expr = try parseExpression(precedence: 0){
            switch expr {
                case .identifier(_):
                    declarations.append(expr)

                case .assignment(let left, let op , _):
                    
                    if op != .binaryOp(.assign) {
                        throw ParserError.invalidSyntax(currentTokenIndex)
                    }
                    
                    declarations.append(left)

                    if maybeAssignments == nil {
                        maybeAssignments = []
                    }
                    maybeAssignments?.append(expr)
                
                case .sequence(let exprs): //Parse sequence of expressions for multiple declarations
                    for e in exprs {
                        switch e {
                            case .identifier(_):
                                declarations.append(e)
                            case .assignment(let left, let op , _):
                                
                                if op != .binaryOp(.assign) {
                                    throw ParserError.invalidSyntax(currentTokenIndex)
                                }
                                
                                declarations.append(left)
                                
                                if maybeAssignments == nil {
                                    maybeAssignments = []
                                }
                                maybeAssignments?.append(e)
                            default:
                                throw ParserError.invalidSyntax(currentTokenIndex)
                        }
                    }

                default:
                    throw ParserError.invalidSyntax(currentTokenIndex)
            }   
            
        }
        
    
        try consumeSemicolon()

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
        var maybeAssignments: [Expression]? = nil

        if let expr = try parseExpression(precedence: 0){
            switch expr {
                case .identifier(_):
                    declarations.append(expr)

                case .assignment(let left, let op , _):
                    
                    if op != .binaryOp(.assign) {
                        throw ParserError.invalidSyntax(currentTokenIndex)
                    }
                    
                    declarations.append(left)

                    if maybeAssignments == nil {
                        maybeAssignments = []
                    }
                    maybeAssignments?.append(expr)
                
                case .sequence(let exprs): //Parse sequence of expressions for multiple declarations
                    for e in exprs {
                        switch e {
                            case .identifier(_):
                                declarations.append(e)
                            case .assignment(let left, let op , _):
                                
                                if op != .binaryOp(.assign) {
                                    throw ParserError.invalidSyntax(currentTokenIndex)
                                }
                                
                                declarations.append(left)
                                
                                if maybeAssignments == nil {
                                    maybeAssignments = []
                                }
                                maybeAssignments?.append(e)
                            default:
                                throw ParserError.invalidSyntax(currentTokenIndex)
                        }
                    }

                default:
                    throw ParserError.invalidSyntax(currentTokenIndex)
            }   
            
        }
    
            try consumeSemicolon()
    
            return .lexical(kind: kind, declarations: declarations, assignments: maybeAssignments)
        
    }
    
    func parseImportDeclaration() throws -> Declaration? {
        return nil
    }
    
    func parseExportDeclaration() throws -> Declaration? {
        return nil
    }
    
    func parseClassDeclaration() throws -> Declaration? {
        advance() // consume 'class' keyword

        //in case of class declaration, name must be declared
        guard case .identifier(let class_name) = currentToken()?.tokenType else { 
            throw ParserError.unexpectedToken(currentTokenIndex)
        }

        let name = Expression.identifier(class_name)

        advance() // consume class name
        
        var maybeSuperClassName: Expression? = nil
        
        if case .extends = currentToken()?.tokenType {
            
            advance() // consume 'extends' keyword

            if case .identifier(let superClassName) = currentToken()?.tokenType {
                maybeSuperClassName = Expression.identifier(superClassName)
                advance() // consume super class name
            } else {
                throw ParserError.unexpectedToken(currentTokenIndex)
            }
        
        }

        try expect(tokenType: .leftBrace) // consume '{'

        if case .rightBrace = currentToken()?.tokenType {
            advance() // consume '}'
            return .class(
                name: name,
                superClass: maybeSuperClassName,
                body: []
            )
        }

        var bodyElements: [ClassElement] = []

        while currentToken()?.tokenType != .rightBrace {
            
            if let element = try parseClassElement() {
                bodyElements.append(element)
            } 

            try consumeSemicolon()

        }

        try expect(tokenType: .rightBrace) // consume '}'

        return .class(
            name: name,
            superClass: maybeSuperClassName,
            body: bodyElements
        )
    }

    func parseIfStatement() throws -> Statement? {
        advance() // consume 'if' keyword
        
        try expect(tokenType: .leftParen) // consume '('
        guard let testExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        try expect(tokenType: .rightParen) // consume ')'

        guard let consequentStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        if case .else = currentToken()?.tokenType {
            advance() // consume 'else' keyword
            guard let alternateStmt = try parseStatement() else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }
            return Statement.ifStatement(
                test: testExpr,
                consequent: consequentStmt,
                alternate: alternateStmt
            )
        }
        return Statement.ifStatement(
            test: testExpr,
            consequent: consequentStmt,
            alternate: nil
        )
    }

    func parseWhileStatement() throws -> Statement? {
        advance(); // consume 'while' keyword

        try expect(tokenType: .leftParen); // consume '('
        guard let testExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        try expect(tokenType: .rightParen); // consume ')'

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return Statement.whileStatement(
            test: testExpr,
            body: bodyStmt
        )
    }

    func parseDoWhileStatement() throws -> Statement? {
        advance() // consume 'do' keyword

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        try expect(tokenType: .while) // consume 'while' keyword
        try expect(tokenType: .leftParen); // consume '('
        guard let testExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        try expect(tokenType: .rightParen); // consume ')'

        try consumeSemicolon(); // consume optional semicolon after do-while

        return Statement.doWhileStatement(
            body: bodyStmt,
            test: testExpr
        )
    }

    func parseForStatement() throws -> Statement? {
        
        advance()

        if case .await = currentToken()?.tokenType {
            return try parseForAwaitStatement()
        }
        
        try expect(tokenType: .leftParen)

        for n in [1,2] {
            switch peekToken(aheadBy: n)?.tokenType {
                case .of:
                    return try parseForOfStatement()
                case .binaryOp(.in):
                    return try parseForInStatement()
                default:
                    break
            }
        }


        var maybeDecl: Declaration? = nil
        var maybeExpr: Expression? = nil

        switch currentToken()?.tokenType {
            case .semicolon:
                break;
            case .var:
                maybeDecl = try parseVariableDeclaration()
            case .let, .const:
                maybeDecl = try parseLexicalDeclaration()
            case .identifier:
                maybeExpr = try parseExpression(precedence: 0)
                switch maybeExpr {
                    case .assignment:
                        break;
                    case .identifier:
                        break;
                    default:
                        throw ParserError.invalidSyntax(currentTokenIndex)
                }
            default:
                break
        } 
        try consumeSemicolon()
        
        var maybeTest: Expression? = nil

        switch currentToken()?.tokenType {
            case .semicolon:
                break;
            default:
                maybeTest = try parseExpression(precedence: 0)
            }   

        try consumeSemicolon()

        var maybeUpdate: Expression? = nil

        switch currentToken()?.tokenType {
            case .rightParen:
                break;
            case .semicolon:
                throw ParserError.unexpectedToken(currentTokenIndex);
            default:
                maybeUpdate = try parseExpression(precedence: 0)
            }

        try expect(tokenType: .rightParen)

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return Statement.forStatement(
            initDecl: maybeDecl,
            initExpr: maybeExpr,
            test: maybeTest,
            update: maybeUpdate,
            body: bodyStmt
        )
    }

    func parseForInStatement() throws -> Statement? {

        //leftParen already consumed by parseForStatement()--> caller function

        var maybeDecl: Declaration? = nil
        var maybeExpr: Expression? = nil
        
        switch currentToken()?.tokenType {
            case .var:
                advance() // consume 'var' keyword
                guard case .identifier (let var_name) = currentToken()?.tokenType else {
                    throw ParserError.unexpectedToken(currentTokenIndex)
                }
                let id = Expression.identifier(var_name)
                advance() // consume identifier
                maybeDecl = .variable(
                    declarations: [id],
                    assignments: nil
                )
            case .let, .const:
                advance() // consume 'let' or 'const' keyword
                guard case .identifier (let var_name) = currentToken()?.tokenType else {
                    throw ParserError.unexpectedToken(currentTokenIndex)
                }
                let id = Expression.identifier(var_name)
                
                advance() // consume identifier
                
                let kind: LexicalKind = (currentToken()?.tokenType == .let) ? .let : .const
                
                maybeDecl = .lexical(
                    kind: kind,
                    declarations: [id],
                    assignments: nil
                )
            case .identifier (let only_name):
                let id = Expression.identifier(only_name)
                
                maybeExpr = id
                
                advance() // consume identifier
        
            default:
                break
        }

        try expect(tokenType: .binaryOp(.in))

        guard let Expression = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .rightParen)

        guard let Statement = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return .forInStatement(
            left: maybeDecl, 
            leftExpr: maybeExpr,
            right: Expression, 
            body: Statement
        )
        
    }
    func parseForOfStatement() throws -> Statement? {
        
        //leftParen already consumed by parseForStatement()->caller function

        var maybeDecl: Declaration? = nil
        var maybeExpr: Expression? = nil
        
        switch currentToken()?.tokenType {
            case .var:
                advance() // consume 'var' keyword
                guard case .identifier (let var_name) = currentToken()?.tokenType else {
                    throw ParserError.unexpectedToken(currentTokenIndex)
                }
                let id = Expression.identifier(var_name)
                advance() // consume identifier
                maybeDecl = .variable(
                    declarations: [id],
                    assignments: nil
                )
            case .let, .const:
                advance() // consume 'let' or 'const' keyword
                guard case .identifier (let var_name) = currentToken()?.tokenType else {
                    throw ParserError.unexpectedToken(currentTokenIndex)
                }
                let id = Expression.identifier(var_name)
                
                advance() // consume identifier
                
                let kind: LexicalKind = (currentToken()?.tokenType == .let) ? .let : .const
                
                maybeDecl = .lexical(
                    kind: kind,
                    declarations: [id],
                    assignments: nil
                )
            case .identifier (let only_name):
                let id = Expression.identifier(only_name)
                
                maybeExpr = id
                
                advance() // consume identifier
        
            default:
                break
        }

        try expect(tokenType: .of)

        guard let Expression = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .rightParen)

        guard let Statement = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return .forOfStatement(
            left: maybeDecl, 
            leftExpr: maybeExpr,
            right: Expression, 
            body: Statement
        )
    }

    func parseForAwaitStatement() throws -> Statement? {

        advance() // consume 'await' keyword

        try expect(tokenType: .leftParen)

        var maybeDecl: Declaration? = nil
        var maybeExpr: Expression? = nil
        
        switch currentToken()?.tokenType {
            case .var:
                advance() // consume 'var' keyword
                guard case .identifier (let var_name) = currentToken()?.tokenType else {
                    throw ParserError.unexpectedToken(currentTokenIndex)
                }
                let id = Expression.identifier(var_name)
                advance() // consume identifier
                maybeDecl = .variable(
                    declarations: [id],
                    assignments: nil
                )
            case .let, .const:
                advance() // consume 'let' or 'const' keyword
                guard case .identifier (let var_name) = currentToken()?.tokenType else {
                    throw ParserError.unexpectedToken(currentTokenIndex)
                }
                let id = Expression.identifier(var_name)
                
                advance() // consume identifier
                
                let kind: LexicalKind = (currentToken()?.tokenType == .let) ? .let : .const
                
                maybeDecl = .lexical(
                    kind: kind,
                    declarations: [id],
                    assignments: nil
                )
            case .identifier (let only_name):
                let id = Expression.identifier(only_name)
                
                maybeExpr = id
                
                advance() // consume identifier
        
            default:
                break
        }

        try expect(tokenType: .of)

        guard let Expression = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        try expect(tokenType: .rightParen)

        guard let Statement = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        
        return .forAwaitOfStatement(
            left: maybeDecl, 
            leftExpr: maybeExpr,
            right: Expression, 
            body: Statement
        )
    
    }


    func parseReturnStatement() throws -> Statement? {
        
        advance() // consume 'return' keyword

        if let expr = try parseExpression(precedence: 0) {
            try consumeSemicolon();
            return .returnStatement(argument: expr)
        } else {
            try consumeSemicolon();
            return .returnStatement(argument: nil)
        }
    }
    func parseBreakStatement() throws -> Statement? {
        advance() // consume 'break' keyword
        
        if case .identifier (let name) = currentToken()?.tokenType {
            let label = Expression.identifier(name)
            
            advance()
            try consumeSemicolon();
            
            return .breakStatement(label: label)
        }
        
        try consumeSemicolon();
        return .breakStatement(label: nil)
    }

    func parseContinueStatement() throws -> Statement? {
        advance()
        if case .identifier (let name) = currentToken()?.tokenType {
            let label = Expression.identifier(name)

            advance()
            try consumeSemicolon();
            
            return .continueStatement(label: label)
        }
        
        try consumeSemicolon();
        return .continueStatement(label: nil)
    }

    func parseThrowStatement() throws -> Statement? {
        advance() // consume 'throw' keyword
        guard let expr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }
        try consumeSemicolon();
        return .throwStatement(argument: expr)
    }

    func parseTryStatement() throws -> Statement? {
        
        advance();
        
        guard let block = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        var catchOrFinallyCount = 0

        var catchDeclarations: [Expression?] = []
        var handler: Statement? = nil

        if case .catch = currentToken()?.tokenType {
            catchOrFinallyCount += 1
            advance();
            try expect (tokenType: .leftParen)

            while case .identifier (let paramName) = currentToken()?.tokenType {
                let param = Expression.identifier(paramName)
                advance(); // consume identifier
                catchDeclarations.append(param)

                if case .comma = currentToken()?.tokenType {
                    advance(); // consume ','
                } else {
                    break
                }
            } // put parseArgs here

            try expect (tokenType: .rightParen)

            if let handlerStmt = try parseBlockStatement() {
                handler = handlerStmt
            } else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }
        } 

        var finalizer: Statement? = nil
        if case .finally = currentToken()?.tokenType {
            catchOrFinallyCount += 1
            advance(); // consume 'finally' keyword

            if let finalizerStmt = try parseBlockStatement() {
                finalizer = finalizerStmt
            } else {
                throw ParserError.invalidSyntax(currentTokenIndex)
            }
        }

        if catchOrFinallyCount == 0 { // neither catch nor finally present
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return .tryStatement(
            block: block, 
            catchDeclarations: catchDeclarations,
            handler: handler, 
            finalizer: finalizer
        )
    }
    func parseSwitchStatement() throws -> Statement? {
        return nil
    }
    func parseLabelledStatement() throws -> Statement? {
        guard case .identifier (let labelName) = currentToken()?.tokenType else {
            throw ParserError.unexpectedToken(currentTokenIndex)
        }
        let label = Expression.identifier(labelName)
        
        advance() // consume label identifier
        try expect(tokenType: .colon) // consume ':'

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(currentTokenIndex)
        }

        return Statement.labelledStatement(
            label: label,
            body: bodyStmt
        )
    }
    func parseEmptyStatement() throws -> Statement? {
        advance() // consume ';'
        return .empty
    }


}









