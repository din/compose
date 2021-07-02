import Foundation
import Combine

@propertyWrapper public class RefCollection<T : Codable & Equatable & Identifiable> : Codable, ObservableObject, AnyRef {
    
    enum CodingKeys : CodingKey {
        case value
    }
    
    public var wrappedValue : [T] {
        get {
            value.map { $0.wrappedValue }
        }
        set {
            self.value = newValue.map { Ref(wrappedValue: $0) }
            objectWillChange.send()
            
            updateObservers()
        }
    }
    
    public var projectedValue : [Referred<T>] {
        value.map { Referred(id: $0.wrappedValue.id) }
    }
    
    public var destroyedAction: (() -> Void)?
    
    fileprivate var value : [Ref<T>] = []
    fileprivate var cancellables = Set<AnyCancellable>()
    
    public init() {
        
    }
    
    deinit {
        destroyedAction?()
    }

}

extension RefCollection : Equatable {
    
    public static func == (lhs: RefCollection<T>, rhs: RefCollection<T>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
    
}

extension RefCollection {
    
    fileprivate func updateObservers() {
        cancellables.forEach {
            $0.cancel()
        }
        
        cancellables.removeAll()
        
        for ref in value {
            ref.objectWillChange
                .sink { [weak self] in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }
    
}
