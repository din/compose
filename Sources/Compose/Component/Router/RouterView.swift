import Foundation
import SwiftUI
import simd
import Combine

public struct RouterView<Content : View> : View, Identifiable {
    
    let maxInteractiveTransitionOffset : CGFloat = UIScreen.main.bounds.width / 2.0
    let startingSubviewTransitionOffset : CGFloat = -90
    
    @EnvironmentObject var router : Router
    
    @State private var interactiveTransitionOffset : CGFloat = 0.0
    @State private var isTransitioning : Bool = false
    
    ///Identifier on a router view allows us to switch between similar nested router views inside other router views.
    ///Without an identifiers, SwiftUI wouldn't replace a view inside a `ForEach` statement because they would be identical to SwiftUI.
    public let id = UUID()
    
    ///Default view contents.
    let content : Content
    
    var routes : [Route] {
        router.routes
    }

    public init(@ViewBuilder content : () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            content
                .zIndex(1)
                .offset(x: isTransitioning == false && routes.count > 0 ? startingSubviewTransitionOffset : 0)
                .offset(x: isTransitioning == true && routes.count == 1 ? startingSubviewTransitionOffset * (1.0 - transitionProgress) : 0)
                .allowsHitTesting(isTransitioning == false && routes.count == 0)
       
            ForEach(routes) { route in
                let isLast = route.id == routes.last?.id
          
                route.view
                    .zIndex(route.zIndex)
                    .transition(.asymmetric(insertion: .identity, removal: .move(edge: .trailing)))
                    .offset(x: isTransitioning == false && isLast == false && routes.count > 0 ? startingSubviewTransitionOffset : 0)
                    .offset(x: isTransitioning == true && isLast == false ? startingSubviewTransitionOffset * (1.0 - transitionProgress) : 0)
                    .offset(x: isTransitioning == true && isLast == true ? interactiveTransitionOffset : 0)
                    .allowsHitTesting(isTransitioning == false && route.id != routes.last?.id ? false : true)
            }
            .gesture(
                DragGesture(minimumDistance: 0.03, coordinateSpace: .global)
                    .onChanged { value in
                        guard canPerformTransition(value: value) else {
                            return
                        }
                        
                        isTransitioning = true
                        interactiveTransitionOffset = max(value.translation.width, 0)
                    }
                    .onEnded { value in
                        guard isTransitioning == true else {
                            return
                        }
                        
                        guard value.predictedEndTranslation.width > maxInteractiveTransitionOffset else {
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
            )

            if isTransitioning == true || router.isPushing == true {
                Rectangle()
                    .fill(Color.black.opacity(0.0001))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .zIndex(1005.0)
                    .animation(.none)
            }
        }
    }
    
}

extension RouterView where Content == EmptyView {
    
    public init() {
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
    
    fileprivate func canPerformTransition(value : DragGesture.Value) -> Bool {
        guard isTransitioning == false else {
            return true
        }
        
        guard router.options.canTransition == true else {
            return false
        }
   
        guard router.paths.count > (content is EmptyView ? 1 : 0) else {
            return false
        }
        
        guard abs(value.translation.width) > abs(value.translation.height) else {
            return false
        }
        
        guard value.startLocation.x <= 40 else {
            return false
        }
        
        return true
    }
    
}
