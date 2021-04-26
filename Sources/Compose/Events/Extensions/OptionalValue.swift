import Foundation

public protocol OptionalValue {
    associatedtype Wrapped
    
    func map<U>(_ transform : (Wrapped) throws -> U) rethrows -> U?
}

extension Optional : OptionalValue {
    
}
