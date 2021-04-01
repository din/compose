import Foundation

public class Persistence<State : AnyState> {
    
    private unowned let storage : AnyPersistentStorage
    
    private let getState : () -> State
    private let setState : (State) -> Void
    
    init(storage : AnyPersistentStorage, get : @escaping () -> State, set : @escaping (State) -> Void) {
        self.storage = storage
        self.getState = get
        self.setState = set
    }
    
    public func save() {
        storage.save(state: getState())
    }
    
    public func restore() {
        if let state : State = storage.restore() {
            setState(state)
        }
    }
    
    public func purge() {
        storage.purge()
    }
    
}
