import SwiftUI
import UIKit

struct ComposeScrollViewReader : UIViewRepresentable {
    
    typealias CompletionHandler = () -> Void
    
    let isPagingEnabled : Bool
    @Binding var startDraggingOffset : CGPoint
    @Binding var scrollPosition : ComposeScrollPosition
    
    let onReachedBottom : CompletionHandler?
    let onReachedTop : CompletionHandler?

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
            scrollView.isPagingEnabled = isPagingEnabled
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(startDraggingOffset: $startDraggingOffset,
                    scrollPosition: $scrollPosition,
                    onReachedBottom: onReachedBottom,
                    onReachedTop: onReachedTop)
    }
    
}

extension ComposeScrollViewReader {
    
    class Coordinator : NSObject, UIScrollViewDelegate {
        
        @Binding var startDraggingOffset : CGPoint
        @Binding var scrollPosition : ComposeScrollPosition
        
        let onReachedBottom : CompletionHandler?
        let onReachedTop : CompletionHandler?
  
        public init(startDraggingOffset : Binding<CGPoint>,
                    scrollPosition : Binding<ComposeScrollPosition>,
                    onReachedBottom : CompletionHandler?,
                    onReachedTop : CompletionHandler?) {
            self._startDraggingOffset = startDraggingOffset
            self._scrollPosition = scrollPosition
            self.onReachedBottom = onReachedBottom
            self.onReachedTop = onReachedTop
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            startDraggingOffset = scrollView.contentOffset
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            var nextScrollPosition: ComposeScrollPosition
            
            if scrollView.contentOffset.y <= 0 {
                nextScrollPosition = .top
            }
            else if (scrollView.contentSize.height - scrollView.contentOffset.y) <= scrollView.frame.size.height {
                nextScrollPosition = .bottom
            }
            else {
                nextScrollPosition = .middle
            }
            
            guard scrollPosition != nextScrollPosition else {
                return
            }
            
            scrollPosition = nextScrollPosition
            
            if scrollPosition == .bottom {
                onReachedBottom?()
            }
            else if scrollPosition == .top {
                onReachedTop?()
            }
        }

    }
    
}
