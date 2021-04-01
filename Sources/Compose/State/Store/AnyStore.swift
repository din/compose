import Foundation

public protocol AnyStore : class {
    associatedtype State : AnyState
    associatedtype Status : AnyStatus
    
    var state : State { get set }
    
    var emitter : Emitter<State> { get }
    var statusEmitter : Emitter<Status> { get }
}
