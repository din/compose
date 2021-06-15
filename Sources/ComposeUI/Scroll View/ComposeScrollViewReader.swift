import SwiftUI

struct ComposeScrollViewReader : UIViewRepresentable {
    
    typealias OnReachedBottom = () -> Void
    
    @Binding var startDraggingOffset : CGPoint
    let onReachedBottom : OnReachedBottom?

    @State var isLoaded : Bool = false
    
    func makeUIView(context: Context) -> some UIView {
        UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.async {
            guard let container = uiView.superview?.superview else {
                return
            }
            
            guard isLoaded == false else {
                return
            }
            
            isLoaded = true
            
            guard let scrollView = container.subviews(ofType: UIScrollView.self).last else {
                return
            }
            
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
            print(scrollView.contentSize.height - scrollView.contentOffset.y, "HEIGHT", scrollView.frame.size.height, "OFF", scrollView.contentOffset.y)
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
