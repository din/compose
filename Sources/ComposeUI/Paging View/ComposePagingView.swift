#if os(iOS)

import Foundation
import SwiftUI
import UIKit

// Paging view supports horizontal scrolling only for now.
public struct ComposePagingView<Data : RandomAccessCollection & Equatable, Content : View> : UIViewRepresentable, DynamicViewContent {
    
    public var data: Data
    
    @Binding var currentIndex : Int
    @ViewBuilder var content : (Data.Element) -> Content
    
    @Environment(\.composePagingViewStyle) var style
    
    public init(data: Data,
                currentIndex : Binding<Int>,
                @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self._currentIndex = currentIndex
        self.content = content
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

