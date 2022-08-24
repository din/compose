#if os(iOS)

import Foundation
import SwiftUI
import UIKit
import Compose

public struct ComposePagingView<Data : RandomAccessCollection & Equatable, Content : View> : UIViewControllerRepresentable, DynamicViewContent where Data.Element : Identifiable {

    public var data: Data
    @Binding public var currentIndex : Int
    @ViewBuilder public var content : (Data.Element) -> Content
    
    let direction : Axis
    let spacing : CGFloat
    
    public init(data: Data,
                currentIndex : Binding<Int>,
                direction : Axis = .vertical,
                spacing : CGFloat = 0,
                @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self._currentIndex = currentIndex
        self.direction = direction
        self.spacing = spacing
        self.content = content
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIPageViewController(transitionStyle: .scroll,
                                              navigationOrientation: direction == .vertical ? .vertical : .horizontal,
                                              options: [.interPageSpacing : spacing])
        
        controller.dataSource = context.coordinator
        controller.delegate = context.coordinator
        
        context.coordinator.controller = controller
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if data != context.coordinator.data {
            context.coordinator.data = data
        }
        else {
            context.coordinator.updateVisibleController()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(content: content, currentIndex: $currentIndex)
    }
    
}

#endif

