import Foundation

public protocol AnyStore : class {
    associatedtype State : AnyState
    associatedtype Status : AnyStatus
    
    var status : Set<Status> { get set }
    
    var state : State { get set }
    
    var didChange : Emitter<State> { get }
    var didStatusChange : Emitter<Set<Status>> { get }
}
