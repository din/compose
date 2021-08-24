import Foundation
import Combine

fileprivate let RefCollectionUpdateQueue = DispatchQueue(label: "compose.ref-collection-queue")

@propertyWrapper public class RefCollection<T : Codable & Equatable & Identifiable> : Codable, ObservableObject, AnyRef {
    
    enum CodingKeys : CodingKey {
        case wrappedValue
    }
    
    public var wrappedValue : [T] {
        
        didSet {
            if wrappedValue.count != oldValue.count {
                self.refs = wrappedValue.map { Ref(value: $0) }
                objectWillChange.send()
            }
            else {
                updateChanges(oldValues: oldValue, newValues: wrappedValue)
            }
        }

    }
    
    public var projectedValue : [Referred<T>] {
        refs.map { Referred(id: $0.wrappedValue.id) }
    }
    
    public var destroyedAction: (() -> Void)?
    
    fileprivate var refs : [Ref<T>] = [] {
        
        didSet {
            updateObservers()
        }
        
    }
    
    fileprivate var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.wrappedValue = []
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
        
        for (index, ref) in refs.enumerated() {
            ref.objectWillChange
                .sink { [weak self] in
                    if self?.wrappedValue.indices.contains(index) ?? false {
                        self?.wrappedValue[index] = ref.wrappedValue
                    }
                    
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }
    
}

extension RefCollection {
    
    fileprivate func updateChanges(oldValues : [T], newValues : [T]) {
        guard oldValues.count == newValues.count else {
            return
        }
            
        for (index, oldValue) in oldValues.enumerated() {
            guard oldValue != newValues[index] else {
                continue
            }
            
            guard refs.indices.contains(index) == true else {
                continue
            }
            
            refs[index].wrappedValue = newValues[index]
        }
    }
    
}
