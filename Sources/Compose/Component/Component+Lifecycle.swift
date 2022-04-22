import Foundation
import SwiftUI

extension Storage {
    
    struct LifecycleEmitterKey : Hashable {
        let id : UUID
        let keyPath : AnyKeyPath
    }
    
    struct PresentationEmitterKey : Hashable {

        enum Kind {
            case enter
            case leave
        }
        
        let id : UUID
        let kind : Kind
        
    }
    
}

extension Component {
    
    public var didEnterFocus : SignalEmitter {
        Storage.shared.value(at: Storage.PresentationEmitterKey(id: self.id, kind: .enter)) {
            SignalEmitter()
        }
    }
    
    public var didLeaveFocus : SignalEmitter {
        Storage.shared.value(at: Storage.PresentationEmitterKey(id: self.id, kind: .leave)) {
            SignalEmitter()
        }
    }
  
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
            .componentScope()
            .onAppear {
                didAppear.send()
                
                Introspection.shared.updateDescriptor(forComponent: self.id) {
                    $0?.isVisible = true
                }
            }
            .onDisappear {
                didDisappear.send()
                
                Introspection.shared.updateDescriptor(forComponent: self.id) {
                    $0?.isVisible = false
                }
            }
    }
    
}
