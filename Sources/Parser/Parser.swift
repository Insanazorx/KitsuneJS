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
    case unexpectedToken(String)
    case endOfInput
    case invalidSyntax(String)
}

extension ParserError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unexpectedToken(let message):
            return "Unexpected token: \(message)"
        case .endOfInput:
            return "Unexpected end of input"
        case .invalidSyntax(let message):
            return "Invalid syntax: \(message)"
        }
    }
}

protocol Parsers {
    // Patterns
    func parsePattern(isCallerVariableDeclarator: Bool) throws -> Pattern?
    func parseObjectPattern() throws -> Pattern?
    func parseArrayPattern() throws -> Pattern?
    func parseRestPattern() throws -> Pattern?

    // Assignment targets (LHS)
    func parseAssignmentTarget() throws -> AssignmentTarget?
    func parseDestructuringPattern() throws -> DestructuringPattern?

    func parseVariableDeclarator(isInitAllowed: Bool) throws -> VariableDeclarator?



    // Declarations
    
    func parseDeclarationStatement(isAsync: Bool) throws -> Statement?                          // done
    func parseFunctionDeclaration(isAsync: Bool) throws -> Declaration?                         // done 
    func parseVariableDeclaration(isInitAllowed: Bool) throws -> Declaration?                                      // done
    func parseLexicalDeclaration(isInitAllowed: Bool) throws -> Declaration?                                       // done       
    func parseImportDeclaration() throws -> Declaration?                                          
    func parseExportDeclaration() throws -> Declaration?
    func parseClassDeclaration() throws -> Declaration?                                         //done
    //helpers are declared below near parseClassExpression()

    // Statements

    func parseExpressionStatement() throws -> Statement?                                        // done 
    func parseBlockStatement() throws -> Statement?                                             // done    
    func parseAsyncStatement() throws -> Statement?                                             // done --> TODO: async must be able to recognized identifier depending context

    func parseIfStatement() throws -> Statement?                                                // done --> TODO: dangling else
    func parseWhileStatement() throws -> Statement?                                             // done
    func parseDoWhileStatement() throws -> Statement?                                           // done 

    func parseForStatement() throws -> Statement?                                               // done   
    func parseForInStatement(left: ForEachLeft) throws -> Statement?                                             // done   
    func parseForOfStatement(left: ForEachLeft) throws -> Statement?                                             // done 
    func parseForAwaitOfStatement() throws -> Statement?                                          // done

    func parseReturnStatement() throws -> Statement?                                            // done
    func parseBreakStatement() throws -> Statement?                                             // done   
    func parseContinueStatement() throws -> Statement?                                          // done    

    func parseThrowStatement() throws -> Statement?                                             // done --> TODO:  implement lexer to ensure parser gives error for line break after throw
    func parseTryStatement() throws -> Statement?                                               // done     
    func parseSwitchStatement() throws -> Statement?
    func parseLabelledStatement() throws -> Statement?                                          // done 

    func parseEmptyStatement() throws -> Statement?                                             // done
    
    
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
    
    func parseClassExpression() throws -> Expression?                                           // done

    //dispatcher for class element parsing
    func parseClassElement() throws -> ClassElement?                                            // done    
    func parseClassElementKey() throws -> ClassElementKey?                                      // done    
    
    //helpers for parseClassElement
    func parseClassConstructorDefinition() throws -> ClassElement?                              // done
    func parseClassGetterDefinition(isStatic: Bool) throws -> ClassElement?                     // done
    func parseClassSetterDefinition(isStatic: Bool) throws -> ClassElement?                     // done
    func parseClassMethodDefinition(parsedKey: ClassElementKey?, isStatic: Bool) throws -> ClassElement?    // done
    func parseClassFieldDefinition(parsedKey: ClassElementKey, isStatic: Bool) throws -> ClassElement?      // done 
    func parseStaticBlockDefinition() throws -> ClassElement?                                   // done

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


    func parseArrowFunction(isAsync: Bool, Args:[Pattern] ) throws -> Expression?              // done
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
    func putErrorOutput(_ index: Int) -> String
}

public class Parser {
    let tokens: [Token];
    var currentTokenIndex: Int = 0;
    
    public init(_ input: [Token]) {
        self.tokens = input;
        print ("Tokens:");
        var i = 0
        for token in tokens {
            print ("\(i): \(token.description)");
            i += 1
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
            throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
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

    func putErrorOutput(_ index: Int) -> String {
        var output = "Error at token index \(index). Current token stream:\n"

        var line1 = ""
        var line2 = ""

        let start = max(0, index - 5)
        let end   = min(tokens.count - 1, index + 5)

        for i in start...end {
            let text = tokens[i].lexemeAndSpace
            line1 += text + " "

            if i == index {
                line2 += String(repeating: "~", count: text.count - 1) + "  "
            } else {
                line2 += String(repeating: " ", count: text.count) + " "
            }
        }

        output += line1 + "\n" + line2
        return output
    }

    func consumeSemicolon() throws {
        if currentToken()?.tokenType == .semicolon {
        advance()
            return
        }
        if currentToken() == nil || currentToken()?.tokenType == .rightBrace {
            return // ASI
        }
        if currentToken()?.isPreceededByLineTerminator == true {
            return
        }
        throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
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
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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

                    // NOTE: just a trick for checking whether the lhs is valid for update ops.
                    guard asAssignmentTarget(lhs) != nil else {
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }

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
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
                    guard let target = asAssignmentTarget(lhs) else {
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }
                    lhs = Expression.assignment(
                        left: target,
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

private extension AssignmentTarget {
    func asExpression() -> Expression {
        switch self {
        case .identifier(let name):
            return .identifier(name)
        case .member(let object, let property):
            return .member(object: object, property: property)
        case .computedMember(let object, let property):
            return .computedMember(object: object, property: property)
        case .destructuring:
            return .parenthesized(nil)
        }
    }
}
    


extension Parser : Parsers {

    // MARK: - Assignment Targets (LHS)

    // Convert an already-parsed Expression into an AssignmentTarget, for assignment operator handling.
    private func asAssignmentTarget(_ expr: Expression) -> AssignmentTarget? {
        switch expr {
        case .identifier(let name):
            return .identifier(name)
        case .member(let object, let property):
            return .member(object: object, property: property)
        case .computedMember(let object, let property):
            return .computedMember(object: object, property: property)
        case .parenthesized(let inner):
            switch inner {
            case .objectLiteral:
                return .destructuring(ConvertExprToDestructingPattern(inner!)!)
            case .arrayLiteral:
                return .destructuring(ConvertExprToDestructingPattern(inner!)!)
            default:
                if let inner { return asAssignmentTarget(inner) }
                return nil
            }
        default:
            return nil
        }
    }

    func ConvertExprToDestructingPattern(_ expr: Expression) -> DestructuringPattern? {
        switch expr {
        case .objectLiteral(let objPat):
            let destPattern: DestructuringPattern
            do {
                destPattern = .object(properties: try objPat.map {
                switch $0 {
                    case ObjectProperty.shorthand(let name):
                        return DestructuringObjectProperty.shorthand(name)
                    
                    case ObjectProperty.spread(let expr):
                        let prop = asAssignmentTarget(expr)
                        return DestructuringObjectProperty.rest(prop!)
                    
                    case ObjectProperty.property(let key, let value):
                        let dpValue: DestructuringPattern
                        switch value {
                            case .assignment(let left,let op, let right ) where op == .binaryOp(.assign):
                                dpValue = .assignment(
                                    target: left,
                                    defaultValue: right
                                )
                            case .objectLiteral, .arrayLiteral:
                                dpValue = ConvertExprToDestructingPattern(value)!
                            
                            default:
                                dpValue = .target(asAssignmentTarget(value)!)
                        }

                        return DestructuringObjectProperty.property(
                            key: key,
                            value: dpValue
                        )
                        
                    default:
                        fatalError("Unexpected object property type in ConvertExprToDestructingPattern: \($0)")
                }
                
            })} catch {
                fatalError("Will be fixed later with proper error handling: \(error)")
            }

            return destPattern 

        case .arrayLiteral(let arrPat):
            
            let destPattern: DestructuringPattern = .array(elements: arrPat.map {
                switch $0 {
                    case .element(let value):
                        fallthrough
                    case .spread(let value):
                        let dpValue: DestructuringPattern
                        switch value {
                            case .assignment(let left,let op, let right ) where op == .binaryOp(.assign):
                                dpValue = .assignment(
                                    target: left,
                                    defaultValue: right
                                )

                            case .objectLiteral, .arrayLiteral:
                                dpValue = ConvertExprToDestructingPattern(value)!
                            
                            default:
                                dpValue = .target(asAssignmentTarget(value)!)
                        }
                        return .pattern(dpValue)
                    case .elision:
                        return .elision

                }
                })
            return destPattern
        
        default:
            fatalError("will be fixed later with proper error handling: unexpected expression type in ConvertExprToDestructingPattern: \(expr)")
        }
    }

    func parseAssignmentTarget() throws -> AssignmentTarget? {
        switch currentToken()?.tokenType {
            case .leftBrace:
                // IMPORTANT: In an assignment target position, `{...}` is the LHS shape.
                // Do NOT call `parseDestructuringPattern()` here because that function is allowed
                // to consume a trailing `= <expr>` as a *default initializer* for nested patterns.
                // At the top-level LHS, the `=` belongs to the *assignment expression*.
                let objPat = try parseDestructuringObjectPattern()
                return .destructuring(objPat)

            case .leftBracket:
                // Same reasoning as `{}` above.
                let arrPat = try parseDestructuringArrayPattern()
                return .destructuring(arrPat)

            case .identifier, .this, .new:
                switch peekToken(aheadBy: 1)?.tokenType {
                    case .dot, .leftBracket, .leftParen: // "super" will be added later.
                        return try parseMemberCascade()
                    default:
                        break
                }
                if case .identifier(let name) = currentToken()?.tokenType {
                    advance() // consume identifier
                    return .identifier(name)
                }
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            default:
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
    }

    func parseMemberCascade() throws -> AssignmentTarget? {
       guard let lhs: Expression = try parseExpression(precedence: 19, allowComma: false) else {
           throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
       }

        switch lhs {
            case .member, .computedMember:
                return asAssignmentTarget(lhs)
            default:
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
    }

    func parseDestructuringPattern() throws -> DestructuringPattern? {
        switch currentToken()?.tokenType {

        case .leftBrace:
            
            let pat: DestructuringPattern = try parseDestructuringObjectPattern()

            if case .binaryOp(.assign) = currentToken()?.tokenType {
                advance() // consume '='
                guard let defaultValue = try parseExpression(precedence: 0, allowComma: false) else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                return .assignment(
                    target: .destructuring(pat),
                    defaultValue: defaultValue
                )
            }

            return pat

        case .leftBracket:
            
            let pat: DestructuringPattern = try parseDestructuringArrayPattern()

            if case .binaryOp(.assign) = currentToken()?.tokenType {
                advance() // consume '='
                guard let defaultValue = try parseExpression(precedence: 0, allowComma: false) else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                return .assignment(
                    target: .destructuring(pat),
                    defaultValue: defaultValue
                )
            }

            return pat

        case .spread:
            
            return try parseDestructuringRestPattern()

        default:
            guard let target = try parseAssignmentTarget() else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }

            if case .binaryOp(.assign) = currentToken()?.tokenType {
                advance() // consume '='
                guard let defaultValue = try parseExpression(precedence: 0, allowComma: false) else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                return .assignment(
                    target: target,
                    defaultValue: defaultValue
                )
            }

            return .target(target)
        }
    }


    func parseDestructuringRestPattern() throws -> DestructuringPattern? {
        advance() // consume '...'

        guard let target = try parseAssignmentTarget() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return .rest(target)
    }


    func parseDestructuringObjectPattern() throws -> DestructuringPattern {
        advance() // consume '{'
        var properties: [DestructuringObjectProperty] = []
        while currentToken()?.tokenType != .rightBrace {
            if let prop = try parseDestructuringObjectProperty() {
                properties.append(prop)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }
        advance() // consume '}'
        return .object(properties: properties)
    }

    func parseDestructuringObjectProperty() throws -> DestructuringObjectProperty? {
        switch currentToken()?.tokenType {
            case .spread:
                advance() // consume '...'
                guard let target = try parseAssignmentTarget() else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                return .rest(target)

            case .number, .string, .boolean, .null, .undefined, .this, .leftBracket:
                guard let key = try parsePropertyKey() else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                try expect(tokenType: .colon)
                guard let valueTarget = try parseDestructuringPattern() else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                
                return .property(
                    key: key,
                    value: valueTarget
                )
            case .identifier(let name):

                if case .colon = peekToken(aheadBy: 1)?.tokenType {
                    let key: PropertyKey = .identifier(name)
                    advance() // consume identifier

                    try expect(tokenType: .colon) // consume ':'
                    guard let valueDestPattern = try parseDestructuringPattern() else {
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }
                    return .property(key: key, value: valueDestPattern)
                }

                
                if case .binaryOp(.assign) = peekToken(aheadBy: 1)?.tokenType {
                    let key: PropertyKey = .identifier(name)
                    advance() // consume identifier

                    advance() // consume '='
                    guard let defaultValue = try parseExpression(precedence: 0, allowComma: false) else {
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }

                    let left: AssignmentTarget = .identifier(name)
                    let assigned: DestructuringPattern = .assignment(target: left, defaultValue: defaultValue)
                    return .property(key: key, value: assigned)
                }

                
                advance() // consume identifier
                return .shorthand(name)
            default:
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))    
        }
        
    }

    func parseDestructuringArrayPattern() throws -> DestructuringPattern {
        advance() // consume '['
        
        var elements: [DestructuringArrayPatternElement] = []
        while currentToken()?.tokenType != .rightBracket {
            
            if case .comma = currentToken()?.tokenType {
                elements.append(.elision)
                advance() // consume ','
                continue
            }    
            
            if let element = try parseDestructuringPattern() { 
                elements.append(.pattern(element))
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }
        advance() // consume ']'
        return .array(elements: elements)
       
    }

    func parseNudExpression() throws -> Expression? {
        guard let tok = currentToken()?.tokenType else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        let simulateWhetherParentesizedExpressionIsArrowFunctionArg: (_ currentIdx: Int, _ tokens: [Token]) -> Bool
                 = { currentIdx, tokens in
                    var tempIndex = currentIdx
                    var parenCount = 1
                    while parenCount > 0 && tempIndex < tokens.count {
                        tempIndex += 1
                        if tempIndex >= tokens.count {
                            return false
                        }
                        switch tokens[tempIndex].tokenType {
                            case .leftParen:
                                parenCount += 1
                            case .rightParen:
                                parenCount -= 1
                            default:
                                continue
                        }
                    }
                    
                    tempIndex += 1

                    if case .arrow = tokens[tempIndex].tokenType {
                        return true
                    }
                    
                    return false

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
                        Args: [.bindingIdentifier(name)]
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
                advance()

                let simulationResult = simulateWhetherParentesizedExpressionIsArrowFunctionArg(currentTokenIndex, tokens)

                if simulationResult {
                    var patterns: [Pattern] = []
                    while currentToken()?.tokenType != .rightParen {
                        if let param = try parsePattern() {
                            patterns.append(param)
                        }

                        if case .comma = currentToken()?.tokenType {
                            advance() // consume ','
                            continue
                        }
                    }
                    advance(); // consume ')'
                    return try parseArrowFunction(
                        isAsync: false,
                        Args: patterns
                    )
                } else {
                    return try parseParenthesizedExpression()
                }
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
                            Args: [.bindingIdentifier(name)]
                        )

                    }

                } else if case .leftParen = currentToken()?.tokenType {
                    advance() // consume '(' before simulating for async arrow function with parenthesized args
                    let simulationResult = simulateWhetherParentesizedExpressionIsArrowFunctionArg(currentTokenIndex, tokens)
                    if simulationResult {
                        var patterns: [Pattern] = []
                        while currentToken()?.tokenType != .rightParen {
                            if let param = try parsePattern() {
                                patterns.append(param)
                            }

                            if case .comma = currentToken()?.tokenType {
                                advance() // consume ','
                                continue
                            }
                        }
                        advance(); // consume ')'
                        return try parseArrowFunction(
                            isAsync: true,
                            Args: patterns
                        )
                    }
                    
                }
                
                guard let expr = try parseFunctionExpression(isAsync: true) else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }

                return expr;

        default:
            fatalError("Unexpected token in nud expression: id: \(currentTokenIndex) \(String(describing: currentToken()))")
        }
    }


    func parseNewExpression() throws -> Expression? {
        advance() // consume 'new' keyword

        guard var callee = try parseNudExpression() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return Expression.await(
            argument: argument
        )
    }

    
    func parseUnaryExpression() throws -> Expression? {
        
        var op: TokenType

        if case .unaryOp (let unaryOp) = currentToken()?.tokenType {
            op = .unaryOp(unaryOp)
        }else if case .updateOp (let updateOp) = currentToken()?.tokenType {
            op = .updateOp(updateOp)
        }else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        advance() // consume operator
        
        guard let argument = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        if case .updateOp(let updateOp) = op, (updateOp == .increment || updateOp == .decrement) {
            
            // same trick used in parseExpression for checking whether the argument is valid for update ops.
            guard asAssignmentTarget(argument) != nil else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }
            return Expression.unary(
                operator_: op,
                argument: argument,
                isPrefix: true
            )
        }

        return Expression.unary(
            operator_: op,
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
            
            var identifier: Expression

            if case .identifier(let propertyName) = currentToken()?.tokenType {
                identifier = Expression.identifier(propertyName)

            } else if case .privateIdentifier(let privateName) = currentToken()?.tokenType {
                identifier = Expression.privateIdentifier(privateName)

            } else {
                throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
            }
            advance() // consume property identifier

            return .member(
                object: lhs,
                property: identifier
            )
        
    
    }
    func parseComputedMemberExpression(object lhs: Expression) throws -> Expression? {
        
        advance() // consume '['

        if case .rightBracket = currentToken()?.tokenType {
            throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
        } 

        guard let propertyExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
        advance() // consume 'function' keyword
        
        var isGenerator = false
        if case .binaryOp(.multiply) = currentToken()?.tokenType {
            isGenerator = true
            advance() // consume '*'
        }

        var name: Identifier? = nil

        if case .identifier(let functionName) = currentToken()?.tokenType {
            name = Identifier.identifier(functionName)
            advance() // consume function name
        }

        try expect(tokenType: .leftParen) // consume '('

        var params: [Pattern] = []

        while currentToken()?.tokenType != .rightParen {
            if let param = try parsePattern() {
                params.append(param)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let body = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return Expression.functionExpression(
            name: name,
            params: params,
            body: body,
            isAsync: isAsync,
            isGenerator: isGenerator
        )


    }

    func parseArrowFunction(isAsync: Bool, Args: [Pattern]) throws -> Expression? {
        // ( ) => {}
        // arg => {}
        // ~~~ shown parts are already consumed
        try expect(tokenType: .arrow) // consume '=>'

        guard let body = try parseStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        
        return Expression.arrowFunction(
            params: Args,
            body: body,
            isAsync: isAsync
        )
    }

    func parseClassExpression() throws -> Expression? {

        advance() // consume 'class' keyword

        //class expression may have optional name
        var name: Identifier? = nil
        
        if case .identifier(let className) = currentToken()?.tokenType {
            name = Identifier.identifier(className)
            advance() // consume class name
        }
        
        var maybeSuperClassName: Expression? = nil
        
        if case .extends = currentToken()?.tokenType {
            
            advance() // consume 'extends' keyword

            guard let superClassName = try parseExpression(precedence: 0) else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }
            maybeSuperClassName = superClassName
        
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
            // NOTE: Do NOT call consumeSemicolon() here.
            // - Methods/getters/setters/constructor end with `}` (no semicolon).
            // - Fields and private fields consume their own terminator (see parseClassFieldDefinition).
            // - Empty class element consumes `;` inside parseClassElement.
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
            
            case .async, .binaryOp(.multiply):
                return try parseClassMethodDefinition(isStatic: false)
            
            case .static:
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
                            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                        }
                        
                        if case .leftParen = currentToken()?.tokenType {
                            return try parseClassMethodDefinition(parsedKey: parsedKey, isStatic: true)
                        } else {
                            return try parseClassFieldDefinition(parsedKey: parsedKey, isStatic: true)
                        } 
                    }
            
            default:
                guard let parsedKey = try parseClassElementKey() else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                
                if case .leftParen = currentToken()?.tokenType {
                    return try parseClassMethodDefinition(parsedKey: parsedKey, isStatic: false)
                } else {
                    return try parseClassFieldDefinition(parsedKey: parsedKey, isStatic: false)
                }
        }
    }
    func parseClassElementKey() throws -> ClassElementKey?{
        if case .privateIdentifier(let string) = currentToken()?.tokenType {
            advance() // consume private identifier
            return ClassElementKey.privateName(.privateIdentifier(string))
        } else {
            guard let key = try parsePropertyKey() else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }
            return ClassElementKey.publicKey(key)
        }    
    }
    func parseClassConstructorDefinition() throws -> ClassElement? {
        advance() // consume 'constructor' keyword

        try expect(tokenType: .leftParen) // consume '('

        var params: [Pattern]? = []

        while currentToken()?.tokenType != .rightParen {
            if let param = try parsePattern() {
                params?.append(param)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return .constructor(
            params: params,
            body: bodyStmt
        )
    }                                
    func parseClassGetterDefinition(isStatic: Bool) throws -> ClassElement?{
        advance() // consume 'get' keyword

        guard let key = try parseClassElementKey() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        try expect(tokenType: .leftParen) // consume '('
        try expect(tokenType: .rightParen) // consume ')'

        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        try expect(tokenType: .leftParen) // consume '('
        guard let param = try parsePattern() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        try expect(tokenType: .rightParen) // consume ')'

        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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

        var resultKey: ClassElementKey
        if let key = parsedKey {
            resultKey = key
        } else {
            resultKey = try parseClassElementKey()!
        }

        try expect(tokenType: .leftParen) // consume '('

        if case .rightParen = currentToken()?.tokenType {
            advance() // consume ')'
            guard let bodyStmt = try parseBlockStatement() else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }

            return .member(
                key: resultKey,
                params: [],
                body: bodyStmt,
                isStatic: isStatic,
                isAsync: isAsync,
                isGenerator: isGenerator
            )
        }

        var args: [Pattern]? = []

        while currentToken()?.tokenType != .rightParen {
            
            if let arg = try parsePattern() {
                args?.append(arg)
            }

            if case .comma = currentToken()?.tokenType {
                advance()                               // consume ','
            } else {
                break
            }
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return .member(
            key: resultKey,
            params: args,
            body: bodyStmt,
            isStatic: isStatic,
            isAsync: isAsync,
            isGenerator: isGenerator
        )
    }                      
    func parseClassFieldDefinition(parsedKey: ClassElementKey, isStatic: Bool) throws -> ClassElement?{
        
        // key already consumed

        var initializer: Expression? = nil

        if case .binaryOp(let op) = currentToken()?.tokenType, op == .assign {
            advance() // consume '=' operator

            initializer = try parseExpression(precedence: 0)
        }

        try consumeSemicolon()

        return .field(
            key: parsedKey,
            initializer: initializer,
            isStatic: isStatic
        )
    }
    func parseStaticBlockDefinition() throws -> ClassElement?{
        // static keyword is already consumed
        guard let bodyStmt = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return .staticBlock(statement: bodyStmt)
    }                      


    func parseArrayLiteral() throws -> Expression? {
        advance() // consume '['
        
        var elements: [ArrayElement] = []

        while currentToken()?.tokenType != .rightBracket {
            
            if case .comma = currentToken()?.tokenType {
                elements.append(.elision)
                advance() // consume ','
                continue
            }

            if case .spread = currentToken()?.tokenType {
                advance() // consume '...'
                guard let spreadExpr = try parseExpression(precedence: 0, allowComma: false) else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                elements.append(.spread(spreadExpr))
            } else {
                if let expr = try parseExpression(precedence: 0, allowComma: false) {
                    elements.append(.element(expr))
                }
            }
            
            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }

            
        try expect(tokenType: .rightBracket) // consume ']'
                
        return .arrayLiteral(elements: elements)
    }

    func parseParenthesizedExpression() throws -> Expression? {
        // '(' already consumed
        
        if case .rightParen = currentToken()?.tokenType {
            advance() // consume ')'
            return Expression.parenthesized(nil)
        }

        let simulateWhetherInnerIsDestructingPattern: (_ currentIdx: Int, _ tokens: [Token], _ bracketOrBrace: TokenType?) -> Bool
                 = { currentIdx, tokens, bracketOrBrace in
                    
                    var tempIndex = currentIdx
                    var parenCount = 1
                    var isBracket = false

                    switch bracketOrBrace {
                        case .leftBrace:
                            isBracket = false
                        case .leftBracket:
                            isBracket = true
                        default:
                            return false
                    }

                    tempIndex += 1 // consume the first bracket or brace

                    while parenCount > 0 && tempIndex < tokens.count {
                        tempIndex += 1
                        if tempIndex >= tokens.count {
                            return false
                        }

                        if isBracket {
                            switch tokens[tempIndex].tokenType {
                                case .leftBracket:
                                    parenCount += 1
                                case .rightBracket:
                                    parenCount -= 1
                                default:
                                    continue
                            }
                        } else {
                            switch tokens[tempIndex].tokenType {
                                case .leftBrace:
                                    parenCount += 1
                                case .rightBrace:
                                    parenCount -= 1
                                default:
                                    continue
                            }
                        }
                    }

                    tempIndex += 1
                    
                    if tempIndex >= tokens.count {
                        return false
                    }

                    switch tokens[tempIndex].tokenType {
                        case .binaryOp(.assign):
                            return true
                        default:
                            return false
                    }

                }

        if simulateWhetherInnerIsDestructingPattern(currentTokenIndex, tokens, currentToken()?.tokenType) {
            
            guard let lhsTarget = try parseAssignmentTarget() else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }

            
            guard case .binaryOp(.assign) = currentToken()?.tokenType else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }
            let op = currentToken()!.tokenType
            advance() // consume '='

            guard let rhs = try parseExpression(precedence: 0) else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }

            try expect(tokenType: .rightParen) // consume ')'

            let assignExpr = Expression.assignment(
                left: lhsTarget,
                operator_: op!,
                right: rhs
            )
            return .parenthesized(assignExpr)
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
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }
                    switch currentToken()?.tokenType {
                        case .leftParen:
                            return try parseMethodDefinition(computedKey: key, isAsync: true, isGenerator: false)
                        default:
                            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }
                }

                return try parseMethodDefinition(isAsync: true, isGenerator: false)

            case .binaryOp(.multiply):

                advance() // consume 'async' keyword
                
                if case .leftBracket = currentToken()?.tokenType {
                    
                    guard let key = try parsePropertyKey() else {
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }
                    switch currentToken()?.tokenType {
                        case .leftParen:
                            return try parseMethodDefinition(computedKey: key, isAsync: false, isGenerator: true)
                        default:
                            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
                            return ObjectProperty.shorthand(name)
                        } else {
                            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                        } 
                }
            case .leftBracket:
                guard let key = try parsePropertyKey() else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                switch currentToken()?.tokenType {
                    case .leftParen:
                        return try parseMethodDefinition(computedKey: key, isAsync: false, isGenerator: false)
                    case .colon:
                        return try parsePropertyDefinition(computedKey: key)
                    default:
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
            //TODO:
            //case .ellipsis:
            //  return try parseSpreadProperty()
            default:
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        
    }

    func parsePropertyKey() throws -> PropertyKey? {

        switch currentToken()?.tokenType {
            case .this:
                advance() // consume 'this'
                return PropertyKey.identifier("this")
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
                    throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
                }
                
                guard let expr = try parseExpression(precedence: 0, allowComma: false) else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                
                try expect(tokenType: .rightBracket) // consume ']'

                return PropertyKey.computed(expr)
            
            default:
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
    }

    func parsePropertyDefinition(computedKey: PropertyKey? = nil) throws -> ObjectProperty? {
        
        if let key = computedKey {
            // already consumed '[' expr ']'
            try expect(tokenType: .colon) // expect ':'

            guard let valueExpr = try parseExpression(precedence: 0, allowComma: false) else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }

            return ObjectProperty.property(
                key: key,
                value: valueExpr
            )
        }

        guard let propKey = try parsePropertyKey() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        try expect(tokenType: .colon) // expect ':' 

        guard let valueExpr = try parseExpression(precedence: 0, allowComma: false) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        try expect(tokenType: .leftParen) // consume '('

        var args: [Pattern]? = []

        while currentToken()?.tokenType != .rightParen {
            if let param = try parsePattern() {
                args?.append(param)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            }
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let body: Statement = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        try expect(tokenType: .leftParen) // consume '('
        try expect(tokenType: .rightParen) // consume ')'

        guard let body: Statement = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        return ObjectProperty.getter(
            key: name,
            body: body
        )
    }

    func parseSetterDefinition() throws -> ObjectProperty? {
        advance() // consume 'set' keyword

        guard let name = try parsePropertyKey() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        try expect(tokenType: .leftParen) // consume '('

        guard let arg = try parsePattern() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        try expect(tokenType: .rightParen) // consume ')'

        guard let body: Statement = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return ObjectProperty.setter(
            key: name,
            arg: arg,
            body: body
        )
    }

    func parseSpreadProperty() throws -> ObjectProperty? {
        advance() // consume '...'

        guard let argumentPattern = try parseExpression(precedence: 0, allowComma: false) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return .spread(argument: argumentPattern)
    }
    
    // Statements
    func parseAsyncStatement() throws -> Statement? {
        advance() // consume 'async' keyword
        
        if let stmt = try parseStatement(isAsync: true) {
            switch stmt {
                case Statement.declarationStatement(let funcDecl):
                    guard case .function = funcDecl else {
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
        switch currentToken()?.tokenType {
        case .function:
            if let decl = try parseFunctionDeclaration(isAsync: isAsync) {
                // FunctionDeclaration is a statement form; no semicolon required.
                return .declarationStatement(decl)
            }

        case .class:
            if let decl = try parseClassDeclaration() {
                // ClassDeclaration is a statement form; no semicolon required.
                return .declarationStatement(decl)
            }

        case .var:
            if let decl = try parseVariableDeclaration() {
                // VariableStatement has an ASI point.
                try consumeSemicolon()
                return .declarationStatement(decl)
            }

        case .let, .const:
            if let decl = try parseLexicalDeclaration() {
                // LexicalDeclaration in statement position has an ASI point.
                try consumeSemicolon()
                return .declarationStatement(decl)
            }

        case .import:
            if let decl = try parseImportDeclaration() {
                // ImportDeclaration (module item) is terminated by `;` or ASI.
                try consumeSemicolon()
                return .declarationStatement(decl)
            }

        case .export:
            if let decl = try parseExportDeclaration() {
                // Many export forms end with `;` or ASI (except `export function/class ...`).
                // Keep it simple: treat export statements as having an ASI point.
                try consumeSemicolon()
                return .declarationStatement(decl)
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
            throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
        }
        let name = Identifier.identifier(func_name)
    
        advance()         // consume function name

        try expect(tokenType: .leftParen)   // consume '('

        if case .rightParen = currentToken()?.tokenType {
            advance() // consume ')'
            guard let body: Statement = try parseBlockStatement() else { // parse function body as BlockStatement
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            } 
            return .function(
                name: name,
                params: [], 
                body: body, 
                isAsync: isAsync, 
                isGenerator: isGeneratorPresent
            )
        }
    
        var args: [Pattern] = []                                                        
        while let param_name = try parsePattern() { // parse parameters            
            args.append(param_name)
                                               
            if case .comma = currentToken()?.tokenType {
                advance()                               // consume ','
            } else {
                break
            }
        }

        try expect(tokenType: .rightParen)  // consume ')'

        guard let body: Statement = try parseBlockStatement() else { // parse function body as BlockStatement
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        } 

        return .function(
            name: name,
            params: args, 
            body: body, 
            isAsync: isAsync, 
            isGenerator: isGeneratorPresent
        )

    }
    
    func parseVariableDeclaration(isInitAllowed: Bool = true) throws -> Declaration? {
        
        advance() // consume 'var' keyword
        var declarations: [VariableDeclarator] = []

        while let declarator = try parseVariableDeclarator(isInitAllowed: isInitAllowed) {
            declarations.append(declarator)

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
            } else {
                break
            }
        }

        return .variable(
            declarators: declarations
        )
    }
    
    func parseLexicalDeclaration(isInitAllowed: Bool = true) throws -> Declaration? {
        
        var kind : LexicalKind
        switch currentToken()?.tokenType {
            case .let:
                kind = .let
            case .const:
                kind = .const
            default:
                throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
        }

        advance() // consume 'let' or 'const' keyword
    
        var declarations: [VariableDeclarator] = []

        while let declarator = try parseVariableDeclarator(isInitAllowed: isInitAllowed) {
            
            declarations.append(declarator)

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
            } else {
                break
            }
        }
    
            return .lexical(kind: kind, declarators: declarations)
        
    }

    func parseVariableDeclarator(isInitAllowed: Bool) throws -> VariableDeclarator? {

        guard let id = try parsePattern(isCallerVariableDeclarator: true) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        var initializer: Expression? = nil

        if case .binaryOp(.assign) = currentToken()?.tokenType {
            advance() // consume '='
            initializer = try parseExpression(precedence: 0, allowComma: false)
        }

        return VariableDeclarator(id: id, init_: initializer)
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
            throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
        }

        let name = Identifier.identifier(class_name)

        advance() // consume class name
        
        var maybeSuperClassName: Expression? = nil
        
        if case .extends = currentToken()?.tokenType {
            
            advance() // consume 'extends' keyword

           guard let superClassName = try parseExpression(precedence: 0) else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }
            maybeSuperClassName = superClassName
        
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
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        try expect(tokenType: .rightParen) // consume ')'

        guard let consequentStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        if case .else = currentToken()?.tokenType {
            advance() // consume 'else' keyword
            guard let alternateStmt = try parseStatement() else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        try expect(tokenType: .rightParen); // consume ')'

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return Statement.whileStatement(
            test: testExpr,
            body: bodyStmt
        )
    }

    func parseDoWhileStatement() throws -> Statement? {
        advance() // consume 'do' keyword

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        try expect(tokenType: .while) // consume 'while' keyword
        try expect(tokenType: .leftParen); // consume '('
        guard let testExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
            return try parseForAwaitOfStatement()
        }
        
        try expect(tokenType: .leftParen)

        // Things get complicated here since we need to 
        // lookahead and check whether we are parsing a 
        // for classic, for in or for of statement.

        let parseForInOfLeft = { () throws -> ForEachLeft? in
            switch self.currentToken()?.tokenType {
                case .var:
                    if let decl = try self.parseVariableDeclaration(isInitAllowed: false) {
                        return .declaration(decl)
                    }
                case .let, .const:
                    if let decl = try self.parseLexicalDeclaration(isInitAllowed: false) {
                        return .declaration(decl)
                    }
                default:
                    if let target = try self.parseAssignmentTarget() {
                        return .target(target)
                    }
            }
            return nil
        }

        let parseInitPart = { () throws -> ForInit? in
                    if case .semicolon = self.currentToken()?.tokenType {
                        return nil // for(;;) case
                    }
                    if let decl = try self.parseVariableDeclaration(isInitAllowed: true) {
                        return .declaration(decl)
                    }

                    if let decl = try self.parseLexicalDeclaration(isInitAllowed: true) {
                        return .declaration(decl)
                    }

                    if let expr = try self.parseExpression(precedence: 0, allowComma: false) {
                        return .expression(expr)
                    }
                    return nil
                }

        enum ForClassicOrInOrOf {
            case forClassic
            case forIn
            case forOf
        }

        let simulateNestingLevel: ForClassicOrInOrOf = { parser in 
            var ParenNestingLevel: Int = 0
            var BracketNestingLevel: Int = 0
            var BraceNestingLevel: Int = 0
            
            var virtualIndexState = parser.currentTokenIndex
            let currentIdx = parser.currentTokenIndex
                while parser.peekToken(aheadBy: virtualIndexState - currentIdx)?.tokenType != .of && parser.peekToken(aheadBy: virtualIndexState - currentIdx)?.tokenType != .binaryOp(.in) {
                    virtualIndexState += 1

                    switch parser.peekToken(aheadBy: virtualIndexState - currentIdx)?.tokenType {
                        case .leftParen:
                            ParenNestingLevel += 1
                        case .rightParen:
                            ParenNestingLevel -= 1
                        case .leftBracket:
                            BracketNestingLevel += 1
                        case .rightBracket:
                            BracketNestingLevel -= 1
                        case .leftBrace:
                            BraceNestingLevel += 1
                        case .rightBrace:
                            BraceNestingLevel -= 1
                        default:
                            break
                    }
                    if ParenNestingLevel == 0 && BracketNestingLevel == 0 && BraceNestingLevel == 0 {
                        virtualIndexState += 1 
                        switch parser.peekToken(aheadBy: virtualIndexState - currentIdx)?.tokenType {
                            case .of:
                                return .forOf
                            case .binaryOp(.in):
                                return .forIn
                            case .semicolon:
                                return .forClassic
                            default:
                                break;
                        }
                    }
                    

                }
                fatalError("Should not reach here")
            }(self)

        
        
        switch simulateNestingLevel {
            case .forOf:
                if let left = try parseForInOfLeft() {
                    return try parseForOfStatement(left: left)
                }
            case .forIn:
                if let left = try parseForInOfLeft() {
                    return try parseForInStatement(left: left)
                }
            case .forClassic:

                var initPart: ForInit? = nil
                var testExpr: Expression? = nil
                var updateExpr: Expression? = nil

                if case .semicolon = currentToken()?.tokenType {
                    initPart = nil
                } else {
                    initPart = try parseInitPart()!
                }
                
                try expect(tokenType: .semicolon)

                if case .semicolon = currentToken()?.tokenType {
                    testExpr = nil
                } else {
                    testExpr = try parseExpression(precedence: 0, allowComma: false)
                }

                try expect(tokenType: .semicolon)
                
                if case .rightParen = currentToken()?.tokenType {
                    updateExpr = nil
                } else {
                    updateExpr = try parseExpression(precedence: 0, allowComma: false)
                }

                try expect(tokenType: .rightParen)

                guard let bodyStmt = try parseStatement() else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }

                return Statement.forStatement(
                    init: initPart!,
                    test: testExpr,
                    update: updateExpr,
                    body: bodyStmt
                )
            }
        fatalError("Should not reach here")

    }

    func parseForInStatement(left: ForEachLeft) throws -> Statement? {
        //leftParen already consumed by parseForStatement()->caller function
        
        try expect(tokenType: .binaryOp(.in))
        guard let rightExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        
        try expect(tokenType: .rightParen)

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        return .forInStatement(
            left: left,
            right: rightExpr,
            body: bodyStmt
                
        )
        
    }
    func parseForOfStatement(left: ForEachLeft) throws -> Statement? {
        
        //leftParen already consumed by parseForStatement()->caller function

         try expect(tokenType: .of) 
         
         guard let rightExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
         }  

         try expect(tokenType: .rightParen)

         guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return .forOfStatement(
            left: left,
            right: rightExpr,
            body: bodyStmt
                
        )
    }

    func parseForAwaitOfStatement() throws -> Statement? {

        advance() // consume 'await' keyword
        try expect(tokenType: .leftParen) // consume '('

        let leftPartParser: (Parser) throws -> ForEachLeft = { parser in
            switch parser.currentToken()?.tokenType {
                case .var:
                    if let decl = try parser.parseVariableDeclaration(isInitAllowed: false) {
                        return .declaration(decl)
                    }
                case .let, .const:
                    if let decl = try parser.parseLexicalDeclaration(isInitAllowed: false) {
                        return .declaration(decl)
                    }
                default:
                    if let target = try parser.parseAssignmentTarget() {
                        return .target(target)
                    }
            }
            fatalError ("Should not reach here since leftPartParser is only called when current token can start a pattern or declaration")
        }

        let leftPart = try leftPartParser(self)
        try expect(tokenType: .of) 
        guard let rightExpr = try parseExpression(precedence: 0) else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        try expect(tokenType: .rightParen)

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        return .forAwaitOfStatement(
            left: leftPart,
            right: rightExpr,
            body: bodyStmt
                
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
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        try consumeSemicolon();
        return .throwStatement(argument: expr)
    }

    func parseTryStatement() throws -> Statement? {
        
        advance();
        
        guard let block = try parseBlockStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }

        var catchOrFinallyCount = 0

        var catchDeclarations: [Pattern]? = []
        var handler: Statement? = nil

        if case .catch = currentToken()?.tokenType {
            catchOrFinallyCount += 1
            advance();

            if case .leftParen = currentToken()?.tokenType {
                 
                advance(); // consume '('
            
                while let pat = try parsePattern() {
                    catchDeclarations?.append(pat)

                    if case .comma = currentToken()?.tokenType {
                        advance(); // consume ','
                    } else {
                        break
                    }
                } // put parseArgs here
                try expect (tokenType: .rightParen)
            }

            

            if let handlerStmt = try parseBlockStatement() {
                handler = handlerStmt
            } else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }
        } 

        var finalizer: Statement? = nil
        if case .finally = currentToken()?.tokenType {
            catchOrFinallyCount += 1
            advance(); // consume 'finally' keyword

            if let finalizerStmt = try parseBlockStatement() {
                finalizer = finalizerStmt
            } else {
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
            }
        }

        if catchOrFinallyCount == 0 { // neither catch nor finally present
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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
            throw ParserError.unexpectedToken(putErrorOutput(currentTokenIndex))
        }
        let label = Expression.identifier(labelName)
        
        advance() // consume label identifier
        try expect(tokenType: .colon) // consume ':'

        guard let bodyStmt = try parseStatement() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
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

    func parsePattern(isCallerVariableDeclarator: Bool = false) throws -> Pattern? {
        var pat: Pattern?
        switch currentToken()?.tokenType {
            case .leftBracket:
                pat = try parseArrayPattern()
            case .leftBrace:
                pat = try parseObjectPattern()
            case .spread:
                pat = try parseRestPattern()
            case .identifier(let name):
                advance() // consume identifier
                pat = .bindingIdentifier(name)
            default:
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        if let pattern = pat, !isCallerVariableDeclarator { // if pattern is in caller position of variable declarator, it cannot be an assignment pattern
            if case .binaryOp(.assign) = currentToken()?.tokenType {
                advance() // consume '='
                guard let defaultValue = try parseExpression(precedence: 0, allowComma: false) else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                return .assignment(left: pattern, defaultValue: defaultValue)
            }
        } 
        return pat
    }
    
    func parseObjectPattern() throws -> Pattern? {
        advance() // consume '{'

        var props: [ObjectPatternProperty] = []

        while currentToken()?.tokenType != .rightBrace {
            if let prop = try parseObjectPatternProperty() {
                props.append(prop)
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            } else {
                break
            }
        }

        try expect(tokenType: .rightBrace) // consume '}'

        return .object(properties: props) // TODO: implement object pattern parsing
    }

    func parseObjectPatternProperty() throws -> ObjectPatternProperty? {

        switch currentToken()?.tokenType {

            // Non-identifier keys (literals/this/computed) must be `key : Pattern`
            case .number, .string, .boolean, .null, .undefined, .this, .leftBracket:
                guard let key = try parsePropertyKey() else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                try expect(tokenType: .colon) // consume ':'
                guard let valuePattern = try parsePattern() else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                return .property(key: key, value: valuePattern)

            // Rest property: `{ ...rest }`
            // IMPORTANT:
            // - Do NOT call `parseRestPattern()` here (it would wrap with `Pattern.rest`)
            // - And do NOT `advance()` twice for the spread token.
            case .spread:
                advance() // consume '...'
                // In object binding patterns, the rest target should be a binding identifier.
                guard let arg = try parsePattern(isCallerVariableDeclarator: true) else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                // Optional strictness: reject non-identifier rest targets for object patterns.
                guard case .bindingIdentifier = arg else {
                    throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                }
                return .rest(arg)

            case .identifier(let name):
                
                if case .colon = peekToken(aheadBy: 1)?.tokenType {
                    let key: PropertyKey = .identifier(name)
                    advance() // consume identifier

                    try expect(tokenType: .colon) // consume ':'
                    guard let valuePattern = try parsePattern() else {
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }
                    return .property(key: key, value: valuePattern)
                }

                
                if case .binaryOp(.assign) = peekToken(aheadBy: 1)?.tokenType {
                    let key: PropertyKey = .identifier(name)
                    advance() // consume identifier

                    advance() // consume '='
                    guard let defaultValue = try parseExpression(precedence: 0, allowComma: false) else {
                        throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
                    }

                    let left: Pattern = .bindingIdentifier(name)
                    let assigned: Pattern = .assignment(left: left, defaultValue: defaultValue)
                    return .property(key: key, value: assigned)
                }

                
                advance() // consume identifier
                return .shorthand(name)

            default:
                throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
    }

    func parseArrayPattern() throws -> Pattern? {
        advance() // consume '['

        var elements: [ArrayPatternElement] = []

        while currentToken()?.tokenType != .rightBracket {
            if case .comma = currentToken()?.tokenType {
                // Elision case: `[ , , a]`
                elements.append(.elision)
                advance() // consume ','
                continue
            }
            
            if let element = try parsePattern() {
                elements.append(.pattern(element))
            }

            if case .comma = currentToken()?.tokenType {
                advance() // consume ','
                continue
            } else {
                break
            }
        }

        try expect(tokenType: .rightBracket) // consume ']'

        return .array(elements: elements)
    }

    func parseRestPattern() throws -> Pattern? {
        advance() // consume '...'
        guard let argumentPattern = try parsePattern() else {
            throw ParserError.invalidSyntax(putErrorOutput(currentTokenIndex))
        }
        return .rest(argumentPattern)
    }
}









