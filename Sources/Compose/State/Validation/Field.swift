import Foundation

public protocol AnyField {
    
    var errors : [String] { get }
    var isValid : Bool { get }
    
}

public struct Field<T> : AnyField {
    
    public let isValid : Bool
    public let errors : [String]
    
    public init(_ value : T, rules : Rule<T>...) {
        isValid = rules.allSatisfy { $0.validate(value) }
        errors = []
    }
    
    public init(_ value : T, rules : [Rule<T> : String]) {
        var isValid = true
        var errors = [String]()
        
        rules.forEach { (rule, error) in
            if rule.validate(value) == false {
                errors.append(error)
                isValid = false
            }
        }
        
        self.isValid = isValid
        self.errors = errors
    }
    
}

public struct ArrayField<T> : AnyField {
    
    public let isValid : Bool
    public let errors : [String]
    
    public init<O>(_ objects : [O],
                validIfEmpty : Bool = true,
                path : KeyPath<O, T>,
                rules : Rule<T>...) {
        guard objects.count > 0 else {
            isValid = validIfEmpty
            errors = []
            return
        }
        
        isValid = objects.allSatisfy { object in
            let value = object[keyPath: path]
            return rules.allSatisfy { $0.validate(value) }
        }
        
        errors = []
    }
    
}
