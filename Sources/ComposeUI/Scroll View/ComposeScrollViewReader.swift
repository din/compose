import SwiftUI
import UIKit

struct ComposeScrollViewReader : UIViewRepresentable {
    
    typealias OnReachedBottom = () -> Void
    
    @Binding var startDraggingOffset : CGPoint
    let onReachedBottom : OnReachedBottom?

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
                    onReachedBottom: onReachedBottom)
    }
    
}

extension ComposeScrollViewReader {
    
    class Coordinator : NSObject, UIScrollViewDelegate {
        
        @Binding var startDraggingOffset : CGPoint
        let onReachedBottom : OnReachedBottom?
        
        fileprivate var hasAlreadyReachedBottom: Bool = false
  
        public init(startDraggingOffset : Binding<CGPoint>,
                    onReachedBottom : OnReachedBottom?) {
            self._startDraggingOffset = startDraggingOffset
            self.onReachedBottom = onReachedBottom
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
        }

    }
    
}
