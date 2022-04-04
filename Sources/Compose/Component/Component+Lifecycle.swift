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

//
//struct AppearanceTracker : UIViewControllerRepresentable {
//
//    class Controller : UIViewController {
//
//        let id : UUID
//
//        init(id : UUID) {
//            self.id = id
//            super.init(nibName: nil, bundle: nil)
//        }
//
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//
//        override func viewWillAppear(_ animated: Bool) {
//            print("!! WILL APPEAR", self.id)
//        }
//
//        override func viewDidAppear(_ animated: Bool) {
//            print("!! DID APPEAR", self.id)
//        }
//
//        override func viewWillDisappear(_ animated: Bool) {
//            print("!! WILL DISAPPEAR", self.id)
//        }
//
//        override func viewDidDisappear(_ animated: Bool) {
//            print("!! DID DISAPPEAR", self.id)
//        }
//
//    }
//
//    let id : UUID
//
//    func makeUIViewController(context: Context) -> Controller {
//        let controller = Controller(id: id)
//        controller.view.alpha = 0.0
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: Controller, context: Context) {
//
//    }
//
//}
