import Foundation
import SwiftUI

extension Component {
    
    public var componentCreatedEmitter : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.componentCreatedEmitter) {
            SignalEmitter()
        }
    }
    
    public var componentViewAppearedEmitter : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.componentViewAppearedEmitter) {
            SignalEmitter()
        }
    }
    
    public var componentViewDisappearedEmitter : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.componentViewDisappearedEmitter) {
            SignalEmitter()
        }
    }
    
}

extension Component {
    
    func lifecycle<Body : View>(_ view : Body) -> some View {
        componentCreatedEmitter.send()
        
        return view
            .onAppear {
                componentViewAppearedEmitter.send()
            }
            .onDisappear {
                componentViewDisappearedEmitter.send()
                Storage.removeStorage(for: self.id)
            }
    }
    
}
