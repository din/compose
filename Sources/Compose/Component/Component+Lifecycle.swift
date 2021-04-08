import Foundation
import SwiftUI

extension Component {
    
    public var componentCreated : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.componentCreated) {
            SignalEmitter()
        }
    }
    
    public var componentViewAppeared : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.componentViewAppeared) {
            SignalEmitter()
        }
    }
    
    public var componentViewDisappeared : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.componentViewDisappeared) {
            SignalEmitter()
        }
    }
    
}

extension Component {
    
    func lifecycle<Body : View>(_ view : Body) -> some View {
        componentCreated.send()
        
        return view
            .onAppear {
                componentViewAppeared.send()
            }
            .onDisappear {
                componentViewDisappeared.send()
            }
    }
    
}
