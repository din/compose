import Foundation

private let ValidationEmailFormat =
    "(?:[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[\\p{L}0-9!#$%\\&'*+/=?\\^_`{|}" + "~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\" + "x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[\\p{L}0-9](?:[a-" + "z0-9-]*[\\p{L}0-9])?\\.)+[\\p{L}0-9](?:[\\p{L}0-9-]*[\\p{L}0-9])?|\\[(?:(?:25[0-5" + "]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-" + "9][0-9]?|[\\p{L}0-9-]*[\\p{L}0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21" + "-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"

extension Rule where T == String {
    
    public static var email : Rule {
        .init { value in
            NSPredicate(format: "SELF MATCHES %@", ValidationEmailFormat).evaluate(with: value)
        }
    }
    
}

extension Rule where T == String {
 
    public static func length(_ range : ClosedRange<Int>) -> Rule {
        .init { value in
            value.count >= range.min() ?? 0 && value.count <= range.max() ?? Int.max
        }
    }
    
}

extension Rule where T : Collection {
    
    public static var nonEmpty : Rule {
        .init { value in
            value.isEmpty == false
        }
    }
    
}

extension Rule where T : Equatable {
    
    public static func equal(to otherValue : T) -> Rule {
        .init { value in
            value == otherValue
        }
    }
    
}

