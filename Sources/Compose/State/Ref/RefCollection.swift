import Foundation
import Combine

@propertyWrapper public class RefCollection<T : Codable & Equatable & Identifiable> : Codable, ObservableObject, AnyRef {
    
    public var wrappedValue : [T] {
        get {
            value.map { $0.wrappedValue }
        }
        set {
            self.value = newValue.map { Ref(wrappedValue: $0) }
            objectWillChange.send()
        }
    }
    
    public var projectedValue : [Referred<T>] {
        value.map { Referred(id: $0.wrappedValue.id) }
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
