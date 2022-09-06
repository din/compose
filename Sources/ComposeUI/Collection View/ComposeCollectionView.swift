#if os(iOS)

import Foundation
import SwiftUI
import UIKit
import Compose

public struct ComposeCollectionView<Data : RandomAccessCollection & Equatable,
                                    Content : View> : UIViewControllerRepresentable, DynamicViewContent where Data.Element : Identifiable {
    
    public var data: Data
    
    @Binding var currentIndex : Int
    @ViewBuilder var content : (Data.Element) -> Content

    weak var token : ComposeCollectionViewToken? = nil
    
    @Environment(\.composeCollectionViewStyle) var style

    public init(data: Data,
                token : ComposeCollectionViewToken? = nil,
                currentIndex : Binding<Int> = .init(get: { 0 }, set: { _ in }),
                @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.token = token
        self._currentIndex = currentIndex
        self.content = content
    }
    
    public func makeUIViewController(context: Context) -> some UIViewController {
        let view = CollectionView(frame: .zero, collectionViewLayout: Layout())
        
        context.coordinator.collectionView = view
        context.coordinator.style = style
        context.coordinator.token = token
        
        let controller = UIViewController()
        controller.view = view
        
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if data != context.coordinator.data {
            context.coordinator.data = data
        }
 
        if style != context.coordinator.style {
            context.coordinator.style = style
        }
    }
    
    public func makeUIView(context: Context) -> UICollectionView {
        let view = CollectionView(frame: .zero, collectionViewLayout: Layout())
        context.coordinator.collectionView = view
        context.coordinator.style = style

        return view
    }
    
    public func updateUIView(_ view: UICollectionView, context: Context) {
        if data != context.coordinator.data {
            context.coordinator.data = data
        }
        
        if style != context.coordinator.style {
            context.coordinator.style = style
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(content: content, currentIndex: $currentIndex)
    }
    
}

#endif

