import Foundation
import Combine

@propertyWrapper public class RefCollection<T : Codable & Equatable & Identifiable> : Codable, ObservableObject, AnyRef {
    
    public var wrappedValue : [T] {
        get {
            return value.map { $0.wrappedValue }
        }
        set {
            self.value = newValue.map { Ref(wrappedValue: $0) }
        }
    }
    
    fileprivate var value : [Ref<T>] = []
    
    public init(wrappedValue : [T]) {
        self.value = wrappedValue.map { Ref(wrappedValue: $0) }
    }
    
}

extension RefCollection : Equatable {
    
    public static func == (lhs: RefCollection<T>, rhs: RefCollection<T>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
    
}
