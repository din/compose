import Foundation

public protocol AnyPersistentStorage : class {
    
    var key : String { get }
    
    init(key : String)
    
    func save<State : AnyState>(state : State)
    func restore<State : AnyState>() -> State?
    func purge()
}
