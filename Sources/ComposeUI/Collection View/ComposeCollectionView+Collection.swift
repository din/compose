import UIKit
#if os(iOS)

extension ComposeCollectionView {
    
    class CollectionView : UICollectionView {
        
        override var intrinsicContentSize: CGSize {
            var size = super.intrinsicContentSize
            
            guard let layout = self.collectionViewLayout as? Layout else {
                return size
            }
            
            if layout.style.direction == .horizontal {
                size.height = layout.itemSize.height
            }
            else {
                size.width = layout.itemSize.width
            }
            
            return size
        }
        
    }
    
}

#endif
