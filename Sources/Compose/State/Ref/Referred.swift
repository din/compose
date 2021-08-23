import Foundation

public struct Referred<T : Identifiable & Codable & Equatable> : Identifiable {
    
    public let id : T.ID
    
    init(id : T.ID) {
        self.id = id
    }
    
    public static func `for`(_ object : T) -> Referred<T> {
        if var emitter = Storage.shared.value(at: Storage.RefKey<T>(id: object.id)) as? ValueEmitter<Ref<T>.Change> {
            if emitter.lastValue == nil {
                emitter.lastValue = .init(senderId: UUID(), value: object)
            }
        }
        else {
            var emitter = ValueEmitter<Ref<T>.Change>()
            emitter.lastValue = .init(senderId: UUID(), value: object)
                
            Storage.shared.setValue(emitter, at: Storage.RefKey<T>(id: object.id))
        }

    
        return .init(id: object.id)
    }
    
}

