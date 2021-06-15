import Foundation
import SwiftUI

#if os(iOS) || os(macOS)
extension View {
    
    public func onTapGesture(emitter: SignalEmitter) -> some View {
        self.onTapGesture {
            emitter.send()
        }
    }
    
    public func onTapGesture<V>(emitter: ValueEmitter<V>, value: V) -> some View {
        self.onTapGesture {
            emitter.send(value)
        }
    }
    
}
#endif
