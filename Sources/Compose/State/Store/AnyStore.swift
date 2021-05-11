import Foundation

public protocol AnyStore : AnyObject {
    associatedtype State : AnyState
    associatedtype Status : AnyStatus
    
    var status : Set<Status> { get set }
    
    var state : State { get set }
    
    var didChange : ValueEmitter<State> { get }
    var didStatusChange : ValueEmitter<Set<Status>> { get }
}
