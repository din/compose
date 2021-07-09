import Foundation
import SwiftUI
import simd
import Combine
import UIKit

public struct RouterView<Content : View> : View, Identifiable {
    
    let maxInteractiveTransitionOffset : CGFloat = UIScreen.main.bounds.width / 2.0
    let startingSubviewTransitionOffset : CGFloat = -90
    
    @ObservedObject var router : Router

    @State private var interactiveTransitionOffset : CGFloat = 0.0
    @State private var isTransitioning : Bool = false
    
    ///Identifier on a router view allows us to switch between similar nested router views inside other router views.
    ///Without identifiers, SwiftUI wouldn't replace a view inside a `ForEach` statement because they would be identical to SwiftUI.
    public let id = UUID()
    
    ///Default view contents.
    let content : Content
    
    var routes : [Route] {
        router.routes
    }

    public init(_ router : Router, @ViewBuilder content : () -> Content) {
        self.router = router
        self.content = content()
    }
    
    fileprivate var routesBody : some View {
        ForEach(routes) { route in
            let isLast = route.id == routes.last?.id
            
            #if os(iOS) || os(macOS)
            route.view
                .routerScope(router.options.scopesAnimations)
                .transition(.move(edge: .trailing))
                .zIndex(route.zIndex)
                .transition(.asymmetric(insertion: .identity, removal: .move(edge: .trailing)))
                .offset(x: isTransitioning == false && isLast == false && routes.count > 0 ? startingSubviewTransitionOffset : 0)
                .offset(x: isTransitioning == true && isLast == false ? startingSubviewTransitionOffset * (1.0 - transitionProgress) : 0)
                .offset(x: isTransitioning == true && isLast == true ? interactiveTransitionOffset : 0)
                .allowsHitTesting(isTransitioning == false && route.id != routes.last?.id ? false : true)
            #else
            route.view
                .opacity(isLast == true ? 1.0 : 0.0)
            #endif
        }
    }

    public var body: some View {
        ZStack(alignment: .top) {
            #if os(iOS) || os(macOS)
            content
                .zIndex(1)
                .offset(x: isTransitioning == false && routes.count > 0 ? startingSubviewTransitionOffset : 0)
                .offset(x: isTransitioning == true && routes.count == 1 ? startingSubviewTransitionOffset * (1.0 - transitionProgress) : 0)
                .allowsHitTesting(isTransitioning == false && routes.count == 0)
            
            routesBody
         
            #else
            content
            routesBody
            #endif

            if isTransitioning == true || router.isPushing == true {
                Rectangle()
                    .fill(Color.black.opacity(0.0001))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .zIndex(1005.0)
                    .animation(.none)
            }
            
            RouterPanGestureReader { state in
                switch state.gestureState {
                
                case .changed:
                    guard canPerformTransition(state: state) else {
                        return
                    }
                
                    isTransitioning = true
                    interactiveTransitionOffset = max(state.translation.x, 0)
                
                case .ended, .cancelled, .failed:
                    finishTransition(state: state)
                    
                default:
                    break
                    
                }
            }
            .frame(width: 0, height: 0)
        }
    }
    
}

extension RouterView where Content == EmptyView {
    
    public init(_ router : Router) {
        self.router = router
        self.content = EmptyView()
    }
    
}

extension RouterView {
    
    fileprivate var transitionProgress : CGFloat {
        CGFloat(
            simd_clamp(
                Double(interactiveTransitionOffset / UIScreen.main.bounds.width), 0.0, 1.0
            )
        )
    }
    
    #if os(iOS) || os(macOS)
    fileprivate func canPerformTransition(state : RouterPanGestureReader.State) -> Bool {
        guard isTransitioning == false else {
            return true
        }
        
        guard router.options.canTransition == true else {
            return false
        }
   
        guard router.paths.count > (content is EmptyView ? 1 : 0) else {
            return false
        }
        
        guard abs(state.translation.x) > abs(state.translation.y) else {
            return false
        }
        
        guard state.startLocation.x <= 40 else {
            return false
        }
        
        return true
    }
    
    fileprivate func finishTransition(state : RouterPanGestureReader.State) {
        guard isTransitioning == true else {
            return
        }
        
        guard state.predictedEndTranslation.x > maxInteractiveTransitionOffset else {
            withAnimation(.easeOut(duration: 0.25)) {
                interactiveTransitionOffset = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
                isTransitioning = false
            }
            
            return
        }
        
        withAnimation(.easeOut(duration: 0.25)) {
            interactiveTransitionOffset = UIScreen.main.bounds.width
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) {
            router.pop(animated: false)
            interactiveTransitionOffset = 0
            isTransitioning = false
        }
    }
    #endif
    
}
