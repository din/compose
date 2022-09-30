import Foundation
import SwiftUI

@propertyWrapper public struct Bound<T : Equatable> : Equatable {
    
    public static func == (lhs: Bound<T>, rhs: Bound<T>) -> Bool {
        return lhs.wrappedValue == rhs.wrappedValue
    }
    
    public var wrappedValue : T {
        
        didSet {
            self.binding.wrappedValue = wrappedValue
        }
        
    }
    
    public var projectedValue : Binding<T> {
        get {
            self.binding
        }
        set {
            self.binding = newValue
            self.wrappedValue = newValue.wrappedValue
        }
    }
    
    fileprivate var binding : Binding<T>
    
    public init(wrappedValue : T) {
        self.wrappedValue = wrappedValue
        self.binding = .constant(wrappedValue)
    }
    
}
