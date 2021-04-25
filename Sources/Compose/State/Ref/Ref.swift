import Foundation
import Combine

@propertyWrapper public class Ref<T : Codable & Equatable & Identifiable> : Codable, Identifiable, ObservableObject, AnyRef {
    
    public enum CodingKeys : CodingKey {
        case value
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
            if let emitter = Storage.storage(for: ObjectIdentifier(Ref.self)).value(at: newValue.id) as? ValueEmitter<Change>,
                  let change = emitter.subject.value {
                self.value = change.value
            }

            observeChanges()
        }
    }
    
    fileprivate let refId = UUID()
    
    private var value : T? = nil
    
    public init() {
        self.value = nil
    }
    
    public init(wrappedValue : T) {
        self.value = wrappedValue
        self.didChange.send(.init(senderId: refId, value: wrappedValue))
        
        observeChanges()
    }
    
    fileprivate func observeChanges() {
        didChange += { [weak self] change in
            guard change.senderId != self?.refId else {
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
        Storage.storage(for: ObjectIdentifier(Ref.self)).value(at: self.wrappedValue.id) {
            ValueEmitter<Change>()
        }
    }
    
}
