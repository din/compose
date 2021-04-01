import Foundation
import Combine

extension AnyCancellable {
 
    public func store<State : AnyState, Validation : AnyValidation, Status : AnyStatus>(in store : Store<State, Validation, Status>) {
        self.store(in: &store.cancellables)
    }
    
}
