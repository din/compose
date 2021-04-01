import Foundation

public struct ValidationField : ValidationNode {
    
    let rules : [ValidationRule]
    let keyPath : AnyKeyPath
    
    public init(for keyPath : AnyKeyPath, @ValidationNodeBuilder rules : () -> [ValidationNode]) {
        guard let rules = rules() as? [ValidationRule] else {
            fatalError("ValidationField must only contain ValidatorRule instances.")
        }
        
        self.rules = rules
        self.keyPath = keyPath
    }
    
    func validate(object : Any) -> [ValidationRule] {
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
