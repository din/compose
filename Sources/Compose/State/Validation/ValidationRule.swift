import Foundation

public protocol ValidationRule : ValidationNode {
    
    var errorMessage : String? { get set }
    
    func validate(value : Any, object : Any) -> Bool
    
}

extension ValidationRule {
    
    public func errorMessage(_ message : String) -> ValidationRule {
        var rule = self
        rule.errorMessage = message
        
        return rule
    }
    
}
