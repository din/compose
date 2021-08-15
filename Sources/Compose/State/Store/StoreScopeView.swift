import Foundation
import SwiftUI

public struct StoreScopeView<State : AnyState, Content : View> : View {
    
    @ObservedObject var token : Token
    let content : (State) -> Content
    
    fileprivate let tracker = AllocationTracker()
    
    init(token : Token,
         destroyedAction : @escaping () -> Void,
         @ViewBuilder content : @escaping (State) -> Content) {
        self.token = token
        self.tracker.destroyedAction = destroyedAction
        self.content = content
    }
    
    public var body: some View {
        content(token.state)
    }
    
}

extension StoreScopeView {
    
    class Token : ObservableObject {
        @Published var state : State
        
        init(state : State) {
            self.state = state
        }
    }
    
}

extension StoreScopeView {
    
    fileprivate class AllocationTracker {
        
        var destroyedAction : (() -> Void)? = nil
        
        deinit {
            destroyedAction?()
        }
        
    }
    
}
