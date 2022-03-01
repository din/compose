import Foundation
import Combine

extension Storage {
    
    struct RefKey<T : Codable & Equatable & Identifiable> : Hashable {
        let id : T.ID
        let namespace : String
        let objectId = \Ref<T>.self
    }
    
}

public let RefDefaultNamespace = "."

@propertyWrapper public class Ref<T : Codable & Equatable & Identifiable> : Codable, Identifiable, ObservableObject, AnyRef {
    
    public enum CodingKeys : CodingKey {
        case namespace, value
    }
    
    public var wrappedValue : T {
        get {
            guard let value = value else {
                fatalError("Reference value must always be set beforehand.")
            }
            
            return value
        }
        set {
            value = newValue
            objectWillChange.send()
            
            if let value = value {
                didChange.send(.init(senderId: refId, value: value))
            }
        }
    }
    
    public var projectedValue : Referred<T> {
        get {
            Referred(id: self.wrappedValue.id)
        }
        set {
            if let emitter = Storage.shared.value(at: Storage.RefKey<T>(id: newValue.id, namespace: self.namespace)) as? ValueEmitter<Change>,
                  let change = emitter.lastValue {
                self.value = change.value
            }

            observeChanges()
        }
    }
    
    public var destroyedAction: (() -> Void)?
    
    fileprivate var value : T? = nil

    fileprivate let namespace : String
    fileprivate let refId = UUID()
    fileprivate var cancellable : AnyCancellable? = nil
        
    public init(namespace : String = RefDefaultNamespace) {
        self.value = nil
        self.namespace = namespace
    }
    
    init(value : T, namespace : String = RefDefaultNamespace) {
        self.value = value
        self.namespace = namespace
        observeChanges()
    }
    
    deinit {
        destroyedAction?()
        
        cancellable?.cancel()
        cancellable = nil
    }
    
    fileprivate func observeChanges() {
        cancellable = didChange.debounce(interval: .milliseconds(300)) += { [weak self] change in
            guard change.senderId != self?.refId else {
                return
            }
            
            guard self?.value != change.value else {
                return
            }

            self?.value = change.value
            self?.objectWillChange.send()
        }
    }
    
}

extension Ref : Equatable {
    
    public static func == (lhs: Ref<T>, rhs: Ref<T>) -> Bool {
        lhs.refId == rhs.refId
    }
    
}

extension Ref {
    
    public struct Change {
        let senderId : UUID
        public let value : T
    }
    
    var didChange : ValueEmitter<Change> {
        Storage.shared.value(at: Storage.RefKey<T>(id: self.wrappedValue.id, namespace: self.namespace)) {
            ValueEmitter<Change>()
        }
    }
    
}
