import Foundation
import SwiftUI

extension Storage {
    
    struct LifecycleEmitterKey : Hashable {
        let id : UUID
        let keyPath : AnyKeyPath
    }
    
}

extension Component {
  
    public var didAppear : SignalEmitter {
        Storage.shared.value(at: Storage.LifecycleEmitterKey(id: self.id, keyPath: \Self.didAppear)) {
            SignalEmitter()
        }
    }
    
    public var didDisappear : SignalEmitter {
        Storage.shared.value(at: Storage.LifecycleEmitterKey(id: self.id, keyPath: \Self.didDisappear)) {
            SignalEmitter()
        }
    }
    
}

extension Component {
    
    func lifecycle<Body : View>(_ view : Body) -> some View {
        return view
            .onAppear {
                didAppear.send()
            }
            .onDisappear {
                didDisappear.send()
            }
    }
    
}
