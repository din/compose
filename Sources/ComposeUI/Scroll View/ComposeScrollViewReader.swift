import SwiftUI
import UIKit

struct ComposeScrollViewReader : UIViewRepresentable {
    
    typealias CompletionHandler = () -> Void
    
    @Binding var startDraggingOffset : CGPoint
    @Binding var scrollPosition : ComposeScrollView.ScrollPosition
    
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
        @Binding var scrollPosition : ComposeScrollView.ScrollPosition
        
        let onReachedBottom : CompletionHandler?
        let onReachedTop : CompletionHandler?
        
        fileprivate var hasAlreadyReachedBottom: Bool = false
        fileprivate var hasAlreadyReachedTop: Bool = true
  
        public init(startDraggingOffset : Binding<CGPoint>,
                    scrollPosition : Binding<ComposeScrollView.ScrollPosition>,
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
            if scrollView.contentOffset.y <= 0 {
                scrollPosition = .top
            } else if (scrollView.contentSize.height - scrollView.contentOffset.y) <= scrollView.frame.size.height {
                scrollPosition = .bottom
            } else {
                scrollPosition = .middle
            }
            
            if scrollPosition == .bottom {
                if !hasAlreadyReachedBottom {
                    hasAlreadyReachedBottom = true
                    onReachedBottom?()
                }
            } else {
                hasAlreadyReachedBottom = false
            }
            
            if scrollPosition == .top {
                if !hasAlreadyReachedTop {
                    hasAlreadyReachedTop = true
                    onReachedTop?()
                }
            } else {
                hasAlreadyReachedTop = false
            }
        }

    }
    
}
