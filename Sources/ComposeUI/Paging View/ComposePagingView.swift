#if os(iOS)

import Foundation
import SwiftUI
import UIKit
import Compose

public struct ComposePagingView<Data : RandomAccessCollection & Equatable, Content : View> : UIViewControllerRepresentable, DynamicViewContent where Data.Element : Identifiable {
    
    public var data: Data
    @Binding public var currentIndex : Int
    @ViewBuilder public var content : (Data.Element) -> Content
    
    public init(data: Data,
                currentIndex : Binding<Int>,
                @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self._currentIndex = currentIndex
        self.content = content
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical)
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

