import Foundation
import SwiftUI

public class Validator {
    
    public var isEnabled = true
    public var isValid = false
    
    public var invalidFields = [AnyKeyPath]()
    public var errors = [String]()
    
    let fields : [ValidatorField]
    
    public init(@ValidatorNodeBuilder fields : () -> [ValidatorNode]) {
        guard let fields = fields() as? [ValidatorField] else {
            fatalError("Validator must only contain ValidatorField instances.")
        }
        
        self.fields = fields
    }
    
    public func activateTrigger(for keyPath : AnyKeyPath, tag : String) {
        guard let field = fields.filter({ $0.keyPath == keyPath }).first else {
            return
        }
        
        guard let rule = field.rules.compactMap({ $0 as? TriggerRule }).filter({ $0.tag == tag }).first else {
            return
        }
        
        rule.activate()
    }
    
    func validate(object : Any) {
        var areFieldsValid = true
        var invalidFields = [AnyKeyPath]()
        var errors = [String]()
        
        for field in fields {
            let invalidRules = field.validate(object: object)
            
            if invalidRules.count > 0 {
                areFieldsValid = false
                invalidFields.append(field.keyPath)
                
                errors.append(contentsOf: invalidRules.compactMap { $0.errorMessage })
            }
        }

        self.invalidFields = invalidFields
        self.isValid = areFieldsValid
        self.errors = errors
    }
    
}

extension Validator {
    
    public static func ~=(lhs : Validator, rhs : AnyKeyPath) -> Bool {
        return lhs.invalidFields.contains(rhs) == true
    }
    
    public static func !~=(lhs : Validator, rhs : AnyKeyPath) -> Bool {
        return lhs.invalidFields.contains(rhs) == false
    }
    
}
