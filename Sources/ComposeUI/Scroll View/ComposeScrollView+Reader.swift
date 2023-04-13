#if os(iOS)

import SwiftUI
import UIKit

public enum ComposeScrollViewEvent {
    case startedDragging
    case endedDragging
    case endedDeccelerating
    case reachedTop
    case reachedBottom
}

extension ComposeScrollView {
    
    public typealias DragHandler = (ComposeScrollViewEvent) -> Void
    public typealias CompletionHandler = () -> Void
    public typealias RefreshHandler = (@escaping CompletionHandler) -> Void

    struct Reader : UIViewRepresentable {
        
        @Binding var startDraggingOffset : CGPoint
        let onDrag : DragHandler?

        @State var isLoaded : Bool = false
        
        func makeUIView(context: Context) -> some UIView {
            let view = UIView()
            view.alpha = 0.0
            return view
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
            DispatchQueue.main.async {
                guard isLoaded == false else {
                    return
                }
                
                guard let scrollView = uiView.ancestor(ofType: UIScrollView.self) else {
                    return
                }
                
                isLoaded = true
                
                scrollView.delegate = context.coordinator
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(startDraggingOffset: $startDraggingOffset,
                        onDrag: onDrag)
        }
        
    }
    
}

extension ComposeScrollView {
    
    class Coordinator : NSObject, UIScrollViewDelegate {
        
        @Binding var startDraggingOffset : CGPoint
        
        let onDrag : DragHandler?
        
        fileprivate var hasAlreadyReachedBottom: Bool = false
        fileprivate var hasAlreadyReachedTop: Bool = true
        
        public init(startDraggingOffset : Binding<CGPoint>,
                    onDrag : DragHandler?) {
            self._startDraggingOffset = startDraggingOffset
            self.onDrag = onDrag
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            startDraggingOffset = scrollView.contentOffset
            
            onDrag?(.startedDragging)
        }
        
        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            onDrag?(.endedDragging)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            onDrag?(.endedDeccelerating)
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if (scrollView.contentSize.height - scrollView.contentOffset.y) <= scrollView.frame.size.height
            {
                if !hasAlreadyReachedBottom
                {
                    hasAlreadyReachedBottom = true
                    onDrag?(.reachedBottom)
                }
            }
            else
            {
                hasAlreadyReachedBottom = false
            }
            
            if scrollView.contentOffset.y <= 0
            {
                if !hasAlreadyReachedTop
                {
                    hasAlreadyReachedTop = true
                    onDrag?(.reachedTop)
                }
            }
            else
            {
                hasAlreadyReachedTop = false
            }
        }
        
    }
    
}

#endif
