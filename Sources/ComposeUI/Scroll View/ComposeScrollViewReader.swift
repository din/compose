import SwiftUI

struct ComposeScrollViewReader : UIViewRepresentable {
    
    @Binding var startDraggingOffset : CGPoint

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
            
            guard let scrollView = container.subviews(ofType: UIScrollView.self).first else {
                return
            }

            scrollView.delegate = context.coordinator
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(startDraggingOffset: $startDraggingOffset)
    }
    
}

extension ComposeScrollViewReader {
    
    class Coordinator : NSObject, UIScrollViewDelegate {
        
        @Binding var startDraggingOffset : CGPoint
  
        public init(startDraggingOffset : Binding<CGPoint>) {
            self._startDraggingOffset = startDraggingOffset
        }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            startDraggingOffset = scrollView.contentOffset
        }

    }
    
}
