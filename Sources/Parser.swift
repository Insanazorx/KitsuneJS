import Foundation

public enum ParserError: Error {
    case unexpectedToken(Int)
    case endOfInput
    case invalidSyntax(Int)
}

protocol ParserCore {
    func parse() throws -> ParserError? 
    func advance()-> Void
    func currentToken() -> Token?
    func peekToken(aheadBy n: Int) -> Token?
    func isAtEndOfRule() -> Bool

}

protocol RuleHelper{
    func expect(keyword: KeywordType)throws -> Void
    func expect(operator_: OperatorType)throws -> Void
    func expect(punctuation: punctuationType)throws -> Void
    func expect(token: Token)throws -> Void
    func expect(rule: any RuleAssignable ) throws -> Void
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

    public func parse()throws -> ParserError? {
        
       
    
       return nil
    }

}

extension Parser : RuleHelper {
    func expect(token: Token)throws -> Void{
        if currentTokenIndex < tokens.count {
            if currentToken() == token{
                advance();
            }
        }
        throw ParserError.unexpectedToken(currentTokenIndex);
    }
    func expect(keyword: KeywordType)throws -> Void {
        if currentToken()?.keywordType == keyword {
            advance();
            return;
        }
        throw ParserError.unexpectedToken(currentTokenIndex);
    }
    func expect(operator_: OperatorType)throws -> Void {
        if currentToken()?.operatorType == operator_ {
            advance();
            return;

        }
        throw ParserError.unexpectedToken(currentTokenIndex);
    }
    func expect(rule: Expression) throws -> Void {
        //if rule.doesFit(context: self) == true {
        //    advance();
            return;
        }
        //throw ParserError.unexpectedToken(currentTokenIndex);
    }

    func expect(punctuation: punctuationType)throws -> Void {
        if currentToken()?.punctuationType == punctuation {
            advance();
            return;
        }
        throw ParserError.unexpectedToken(currentTokenIndex);
    }

}







