import Foundation
import Combine

extension AnyCancellable {
 
    public func store<State : AnyState>(in store : StoreContainer<State>) {
        self.store(in: &store.cancellables)
    }
    
}
