import Foundation
import Combine

extension AnyCancellable {
 
    public func store<State : AnyState>(in store : BackingStore<State>) {
        self.store(in: &store.cancellables)
    }
    
}
