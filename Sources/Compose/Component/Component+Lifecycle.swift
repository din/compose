import Foundation
import SwiftUI

extension Component {
    
    public var didCreate : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.didCreate) {
            SignalEmitter()
        }
    }
    
    public var didAppear : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.didAppear) {
            SignalEmitter()
        }
    }
    
    public var didDisappear : SignalEmitter {
        Storage.storage(for: self.id).value(at: \Self.didDisappear) {
            SignalEmitter()
        }
    }
    
}

extension Component {
    
    func lifecycle<Body : View>(_ view : Body) -> some View {
        didCreate.send()
        
        return view
            .onAppear {
                didAppear.send()
            }
            .onDisappear {
                didDisappear.send()
            }
    }
    
}
