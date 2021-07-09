import Foundation
import SwiftUI
import UIKit

struct RouterPanGestureReader : UIViewRepresentable {
    
    struct State {
        let gestureState : UIPanGestureRecognizer.State
        let translation : CGPoint
        let predictedEndTranslation : CGPoint
        let startLocation : CGPoint
    }
    
    let action : (State) -> Void
    
    @SwiftUI.State var isLoaded : Bool = false
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        view.alpha = 0.0
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            guard isLoaded == false else {
                return
            }
            
            isLoaded = true
            
            let gesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
            gesture.delegate = context.coordinator

            if uiView.superview?.superview?.gestureRecognizers?.contains(gesture) == false {
                uiView.superview?.superview?.addGestureRecognizer(gesture)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
}

extension RouterPanGestureReader {
    
    class Coordinator : NSObject, UIGestureRecognizerDelegate {
        
        private let action : (State) -> Void
        private var startLocation : CGPoint = .zero
        
        init(action : @escaping (State) -> Void) {
            self.action = action
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            true
        }
        
        @objc fileprivate func handlePan(_ recognizer : UIPanGestureRecognizer) {
            let translation = recognizer.translation(in: recognizer.view)
            let location = recognizer.location(in: recognizer.view)
            let velocity = recognizer.velocity(in: recognizer.view)
            
            if recognizer.state == .began {
                startLocation = location
            }
            
            action(.init(gestureState: recognizer.state,
                         translation: translation,
                         predictedEndTranslation: .init(x: translation.x + velocity.x, y: translation.y + velocity.y),
                         startLocation: startLocation))
        }
        
    }
    
}
