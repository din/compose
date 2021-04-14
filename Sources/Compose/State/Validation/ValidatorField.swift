import Foundation

public struct ValidatorField : ValidatorNode {
    
    let rules : [ValidatorRule]
    let keyPath : AnyKeyPath
    
    public init(for keyPath : AnyKeyPath, @ValidatorNodeBuilder rules : () -> [ValidatorNode]) {
        guard let rules = rules() as? [ValidatorRule] else {
            fatalError("ValidationField must only contain ValidatorRule instances.")
        }
        
        self.rules = rules
        self.keyPath = keyPath
    }
    
    func validate(object : Any) -> [ValidatorRule] {
        guard let value = object[keyPath: keyPath] else {
            print("ValidationField warning: cannot find field specified by keypath '\(keyPath)'")
            return []
        }
        
        return rules.filter { rule in
            if let rule = rule as? TriggerRule, rule.isActive == false {
                return false
            }
            
            return rule.validate(value: value, object: object) == false
        }
    }
    
}
