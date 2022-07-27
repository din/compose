import UIKit
#if os(iOS)

extension ComposePagingView {
    
    class CollectionView : UICollectionView {
        
        override var intrinsicContentSize: CGSize {
            var size = super.intrinsicContentSize
            size.height = (self.collectionViewLayout as? Layout)?.itemSize.height ?? size.height
            return size
        }
        
    }
    
}

#endif
