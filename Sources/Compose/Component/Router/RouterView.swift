import Foundation
import SwiftUI
import simd
import Combine

public struct RouterView<Content : View> : View, Identifiable {

    struct Route : Identifiable, Equatable {
        
        static func == (lhs: RouterView<Content>.Route, rhs: RouterView<Content>.Route) -> Bool {
            lhs.id == rhs.id
        }
       
        var id : AnyKeyPath {
            path
        }
        
        let view : AnyView
        let path : AnyKeyPath
        let zIndex : Double
    }
    
    let maxInteractiveTransitionOffset : CGFloat = UIScreen.main.bounds.width / 2.0
    let startingSubviewTransitionOffset : CGFloat = -120
    
    @EnvironmentObject var router : Router
    
    @State private var interactiveTransitionOffset : CGFloat = 0.0
    @State private var isTransitioning : Bool = false
    
    ///Identifier on a router view allows us to switch between similar nested router views inside other router views.
    ///Without an identifiers, SwiftUI wouldn't replace a view inside a `ForEach` statement because they would be identical to SwiftUI.
    public let id = UUID()
    
    ///Default view contents.
    let content : Content
    
    var routes : [Route] {
        var routes = [Route]()
        
        // Adding content view if it exists
        if content is EmptyView == false {
            routes.append(.init(view: AnyView(content), path: \Component.self, zIndex: 0))
        }

        // Adding all other routed views
        router.paths.enumerated().forEach { (index, keyPath) in
            guard let component = router.target[keyPath: keyPath] as? Component else {
                return
            }
            
            routes.append(.init(view: component.view, path: keyPath, zIndex: Double(index) + 1.0))
        }

        return routes
    }

    public init(@ViewBuilder content : () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            ForEach(self.routes) { route in
                if route.path == router.pushPath {
                    route.view
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .identity))
                        .zIndex(1000.0)
                }
                else {
                    route.view
                        .zIndex(route.zIndex)
                        .transition(.asymmetric(insertion: .identity, removal: .move(edge: .trailing)))
                        .offset(x: isTransitioning == false && route.path != router.path && router.paths.count > 0 ? -45 : 0)
                        .offset(x: isTransitioning == true && route.path != router.path ? startingSubviewTransitionOffset * (1.0 - transitionProgress) : 0)
                        .offset(x: isTransitioning == true && route.path == router.path ? interactiveTransitionOffset : 0)
                }
            }

            if isTransitioning == true {
                Rectangle()
                    .fill(Color.black.opacity(0.00001))
                    .zIndex(1005.0)
                    .contentShape(Rectangle())
            }
        }
        .readAnimationProgress(reader: router.reader)
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
                        withAnimation(.easeOut(duration: 0.15)) {
                            interactiveTransitionOffset = 0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                            isTransitioning = false
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
