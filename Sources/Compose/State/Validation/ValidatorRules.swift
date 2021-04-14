import Foundation

public struct EmailRule : ValidatorRule {
    
    public var errorMessage: String? = nil
    
    private static let Format =
        "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
    
    public init() {
        
    }
    
    public func validate(value : Any, object : Any) -> Bool {
        guard let value = value as? String else {
            return false
        }
        
        return NSPredicate(format: "SELF MATCHES %@", EmailRule.Format).evaluate(with: value)
    }

}

public struct LengthRule : ValidatorRule {
    
    public var errorMessage: String? = nil
    
    public let range : ClosedRange<Int>
    
    public init(in range : ClosedRange<Int>) {
        self.range = range
    }
    
    public func validate(value : Any, object : Any) -> Bool {
        guard let value = value as? String else {
            return false
        }
        
        return value.count >= range.min() ?? 0 && value.count <= range.max() ?? Int.max
    }
 
}

public struct EqualityRule : ValidatorRule {
    
    public var errorMessage: String? = nil
    
    public let equalKeyPath : AnyKeyPath
    
    public init(with keyPath : AnyKeyPath) {
        self.equalKeyPath = keyPath
    }
    
    public func validate(value : Any, object : Any) -> Bool {
        guard let value = value as? String else {
            return false
        }
        
        guard let comparedValue = object[keyPath: equalKeyPath] as? String else {
            return false
        }
        
        return value == comparedValue
    }
    
}

public struct ConstantRule<T : Equatable> : ValidatorRule {
    
    public var errorMessage: String? = nil
    
    public let expectedValue : T
    
    public init(value : T) {
        self.expectedValue = value
    }
    
    public func validate(value: Any, object: Any) -> Bool {
        return value as? T == expectedValue
    }
    
}

public struct NonEmptyRule : ValidatorRule {
    
    public var errorMessage: String? = nil
    
    public init() {
        
    }
    
    public func validate(value: Any, object: Any) -> Bool {
        guard let value = value as? String else {
            return false
        }
        return value.isEmpty == false
    }
    
}

public struct TriggerRule : ValidatorRule {
    
    private class Storage {
        var isActive = false
    }
    
    public var errorMessage: String? = nil
    
    public let tag : String
    
    var isActive : Bool {
        return storage.isActive
    }
    
    private var storage = Storage()
    
    public init(tag : String) {
        self.tag = tag
    }
    
    public func validate(value: Any, object: Any) -> Bool {
        storage.isActive = false
        return false
    }
    
    func activate() {
        storage.isActive = true
    }
    
}

public struct ArrayRule : ValidatorRule {
    
    public var errorMessage: String? = "Invalid set of entries."
    
    let rules : [ValidatorRule]
    let validIfEmpty : Bool
    let path : AnyKeyPath?
    
    public init(validIfEmpty : Bool, path : AnyKeyPath? = nil, @ValidatorNodeBuilder rules : () -> [ValidatorNode]) {
        guard let rules = rules() as? [ValidatorRule] else {
            fatalError("ValidationField must only contain ValidatorRule instances.")
        }
        
        self.rules = rules
        self.validIfEmpty = validIfEmpty
        self.path = path
    }
    
    public func validate(value: Any, object: Any) -> Bool {
        guard let values = value as? [Any] else {
            return validIfEmpty
        }
        
        return values.allSatisfy { value in
            var value = value
            
            if let path = path, let objectValue = value[keyPath: path] {
                value = objectValue
            }
            
            return rules.allSatisfy { rule in
                if let rule = rule as? TriggerRule, rule.isActive == false {
                    return true
                }
                
                return rule.validate(value: value, object: object)
            }
        }
    }
    
}
