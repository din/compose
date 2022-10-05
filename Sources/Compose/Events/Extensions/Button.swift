import Foundation
import SwiftUI

extension Button {
    
    public init(emitter : SignalEmitter, @ViewBuilder label: () -> Label) {
        self.init {
            emitter.send()
        } label: {
            label()
        }
    }
    
    public init<V>(emitter : ValueEmitter<V>, value : V, @ViewBuilder label : () -> Label) {
        self.init {
            emitter.send(value)
        } label: {
            label()
        }
    }
    
    @available(iOS 15.0, *)
    public init(role: ButtonRole?, emitter : SignalEmitter, @ViewBuilder label: () -> Label) {
        self.init(role: role) {
            emitter.send()
        } label: {
            label()
        }
    }
    
}
