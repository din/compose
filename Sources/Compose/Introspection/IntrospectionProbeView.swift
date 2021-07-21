import Foundation
import SwiftUI

struct IntrospectionProbeView<T : Component> : View {
    
    class Probe {
     
        let id : UUID
        
        init(id : UUID) {
            self.id = id
            
            print("[Compose] Allocated \(T.self) with id \(id)")
        }
        
        deinit {
            print("[Compose] Deallocated \(T.self) with id \(id)")
        }
        
    }
    
    let probe : Probe
    
    init(component : T) {
        self.probe = Probe(id: component.id)
    }
    
    var body: some View {
        EmptyView()
    }
    
}
