import Foundation

public protocol AnyOptionalValue {
    
}

public protocol OptionalValue : AnyOptionalValue {
    associatedtype Wrapped
    
    func map<U>(_ transform : (Wrapped) throws -> U) rethrows -> U?
}

extension Optional : OptionalValue {
    
}
