import SwiftUI
import UIKit

struct ComposeScrollViewReader : UIViewRepresentable {
    
    typealias CompletionHandler = () -> Void
    
    @Binding var startDraggingOffset : CGPoint
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
                    onReachedBottom: onReachedBottom,
                    onReachedTop: onReachedTop)
    }
    
}

extension ComposeScrollViewReader {
    
    class Coordinator : NSObject, UIScrollViewDelegate {
        
        @Binding var startDraggingOffset : CGPoint
        
        let onReachedBottom : CompletionHandler?
        let onReachedTop : CompletionHandler?
        
        fileprivate var hasAlreadyReachedBottom: Bool = false
        fileprivate var hasAlreadyReachedTop: Bool = true
  
        public init(startDraggingOffset : Binding<CGPoint>,
                    onReachedBottom : CompletionHandler?,
                    onReachedTop : CompletionHandler?) {
            self._startDraggingOffset = startDraggingOffset
            self.onReachedBottom = onReachedBottom
            self.onReachedTop = onReachedTop
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            startDraggingOffset = scrollView.contentOffset
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if (scrollView.contentSize.height - scrollView.contentOffset.y) <= scrollView.frame.size.height
            {
                if !hasAlreadyReachedBottom
                {
                    hasAlreadyReachedBottom = true
                    onReachedBottom?()
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
                    onReachedTop?()
                }
            }
            else
            {
                hasAlreadyReachedTop = false
            }
        }

    }
    
}
