import Foundation

public protocol AnyStore : class {
    associatedtype State : AnyState
    associatedtype Status : AnyStatus
    
    var state : State { get set }
    
    var didChange : Emitter<State> { get }
    var didStatusChange : Emitter<Status> { get }
}
