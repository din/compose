import Foundation

public protocol ValidatorRule : ValidatorNode {
    
    var errorMessage : String? { get set }
    
    func validate(value : Any, object : Any) -> Bool
    
}

extension ValidatorRule {
    
    public func errorMessage(_ message : String) -> ValidatorRule {
        var rule = self
        rule.errorMessage = message
        
        return rule
    }
    
}
