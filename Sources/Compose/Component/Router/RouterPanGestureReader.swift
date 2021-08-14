import Foundation
import SwiftUI

#if os(iOS)
import UIKit

struct RouterPanGestureReader : UIViewRepresentable {
    
    struct State {
        let gesture : UIPanGestureRecognizer
        let gestureState : UIPanGestureRecognizer.State
        let velocity : CGPoint
        let translation : CGPoint
        let predictedEndTranslation : CGPoint
        let startLocation : CGPoint
    }
    
    @Binding var isInteractiveGestureEnabled : Bool
    let action : (State) -> Void
    
    @SwiftUI.State fileprivate var isLoaded : Bool = false

    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.alpha = 0.0
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.recognizer?.isEnabled = isInteractiveGestureEnabled
        
        DispatchQueue.main.async {
            guard isLoaded == false else {
                return
            }
            
            isLoaded = true
            
            let recognizer = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
            recognizer.delegate = context.coordinator
   
            context.coordinator.recognizer = recognizer
            
            if uiView.superview?.superview?.gestureRecognizers?.contains(recognizer) == false {
                uiView.superview?.superview?.addGestureRecognizer(recognizer)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
}

extension RouterPanGestureReader {
    
    class Coordinator : NSObject, UIGestureRecognizerDelegate {
        
        weak var recognizer : UIPanGestureRecognizer? = nil
        
        private let action : (State) -> Void
        private var startLocation : CGPoint = .zero
        
        init(action : @escaping (State) -> Void) {
            self.action = action
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            return gestureRecognizer.location(in: gestureRecognizer.view).x <= 55
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            false
        }
        
        @objc fileprivate func handlePan(_ recognizer : UIPanGestureRecognizer) {
            let translation = recognizer.translation(in: recognizer.view)
            let location = recognizer.location(in: recognizer.view)
            let velocity = recognizer.velocity(in: recognizer.view)
            
            if recognizer.state == .began {
                startLocation = location
            }
            
            action(.init(gesture: recognizer,
                         gestureState: recognizer.state,
                         velocity: velocity,
                         translation: translation,
                         predictedEndTranslation: .init(x: translation.x + velocity.x, y: translation.y + velocity.y),
                         startLocation: startLocation))
        }
        
    }
    
}

#endif
