#if os(iOS)

import Foundation
import SwiftUI
import UIKit
import Compose

public struct ComposePagingView<Data : RandomAccessCollection & Equatable,
                                Content : View,
                                TransitionContent : View> : UIViewControllerRepresentable, DynamicViewContent where Data.Element : Identifiable {

    public var data: Data
    @Binding public var currentIndex : Int
    @ViewBuilder public var content : (Data.Element) -> Content
    @ViewBuilder public var transitionContent : (Data.Element) -> TransitionContent
    
    let direction : Axis
    let spacing : CGFloat
    let delay : Double
    
    public init(data: Data,
                currentIndex : Binding<Int>,
                direction : Axis = .vertical,
                spacing : CGFloat = 0,
                delay : Double = 0.0,
                @ViewBuilder content: @escaping (Data.Element) -> Content,
                @ViewBuilder transitionContent: @escaping (Data.Element) -> TransitionContent) {
        self.data = data
        self._currentIndex = currentIndex
        self.direction = direction
        self.spacing = spacing
        self.delay = delay
        self.content = content
        self.transitionContent = transitionContent
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: direction == .vertical ? .vertical : .horizontal,
                                              options: [.interPageSpacing : spacing])
        
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        
        context.coordinator.delay = delay
        context.coordinator.controller = controller
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.content = content
        context.coordinator.transitionContent = transitionContent
        
        if data != context.coordinator.data {
            context.coordinator.data = data
        }
        else {
            context.coordinator.updateVisibleController()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(content: content,
                    transitionContent: transitionContent,
                    currentIndex: $currentIndex)
    }
    
}

extension ComposePagingView where TransitionContent == Content {
    
    public init(data: Data,
                currentIndex : Binding<Int>,
                direction : Axis = .vertical,
                spacing : CGFloat = 0,
                delay : Double = 0.0,
                @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self._currentIndex = currentIndex
        self.direction = direction
        self.spacing = spacing
        self.delay = delay
        self.content = content
        self.transitionContent = content
    }
    
}

#endif

