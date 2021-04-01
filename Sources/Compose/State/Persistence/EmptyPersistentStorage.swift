import Foundation

public class EmptyPersistentStorage : AnyPersistentStorage {
   
    public let key: String
    
    public init() {
        self.key = "none"
    }
    
    public required init(key: String) {
        self.key = key
    }
    
    public func save<State>(state: State) where State : AnyState {
        //Intentionally left blank
    }
    
    public func restore<State>() -> State? where State : AnyState {
        return nil
    }
    
    public func purge() {
        //Intentionally left blank
    }
    
    
    
    
}
