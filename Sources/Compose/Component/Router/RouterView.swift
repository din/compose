import Foundation
import SwiftUI
import simd

public struct RouterView : View, Identifiable {
    
    let maxInteractiveTransitionOffset : CGFloat = UIScreen.main.bounds.width / 2.0
    let startingSubviewTransitionOffset : CGFloat = -80
    
    @EnvironmentObject var router : Router
    
    @State private var interactiveTransitionOffset : CGFloat = 0.0
    @State private var isTransitioning : Bool = false
    
    ///Identifier on a router view allows us to switch between similar nested router views inside other router views.
    ///Without an identifiers, SwiftUI wouldn't replace a view inside a `ForEach` statement because they would be identical to SwiftUI.
    public let id = UUID()

    public var body: some View {
        ZStack(alignment: .top) {
            ForEach(router.views.indices, id: \.self) { index in
                if index == router.views.indices.last {
                    router.views[index]
                        .offset(x: isTransitioning ? interactiveTransitionOffset : 0)
                }
                else if index == router.views.indices.endIndex.advanced(by: -2) {
                    router.views[index]
                        .offset(x: isTransitioning ? startingSubviewTransitionOffset * (1.0 - transitionProgress) : 0)
                }
                else {
                    router.views[index]
                }
            }
            
            if isTransitioning == true {
                Rectangle()
                    .fill(Color.black.opacity(0.00001))
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
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
                    guard canPerformTransition(value: value) else {
                        return
                    }
                    
                    guard value.predictedEndTranslation.width > maxInteractiveTransitionOffset else {
                        withAnimation {
                            interactiveTransitionOffset = 0
                        }
                        
                        return
                    }
                    
                    withAnimation(.easeOut(duration: 0.2)) {
                        interactiveTransitionOffset = UIScreen.main.bounds.width
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        router.pop()
                        interactiveTransitionOffset = 0
                        isTransitioning = false
                    }
                }
        )
    }
    
    public init() {
        
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
        
        guard router.paths.count > 1 else {
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
