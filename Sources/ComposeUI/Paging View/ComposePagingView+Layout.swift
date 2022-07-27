#if os(iOS)

import Foundation
import UIKit

extension ComposePagingView {
    
    class Layout : UICollectionViewFlowLayout {
        
        var style : ComposePagingViewStyle = .init() {
            
            didSet {
                updateStyle()
                invalidateLayout()
            }
            
        }
        
        override init() {
            super.init()
            updateStyle()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                          withScrollingVelocity velocity: CGPoint) -> CGPoint {
            let collectionViewSize = self.collectionView!.bounds.size
            let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width * 0.5
            
            var proposedRect = self.collectionView!.bounds
            
            // Comment out if you want the collectionview simply stop at the center of an item while scrolling freely
            proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)
            
            var candidateAttributes: UICollectionViewLayoutAttributes?
            for attributes in self.layoutAttributesForElements(in: proposedRect)! {
                // == Skip comparison with non-cell items (headers and footers) == //
                if attributes.representedElementCategory != .cell {
                    continue
                }
                
                // Get collectionView current scroll position
                let currentOffset = self.collectionView!.contentOffset
                
                // Don't even bother with items on opposite direction
                // You'll get at least one, or else the fallback got your back
                if (attributes.center.x < (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x > 0) || (attributes.center.x > (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x < 0) {
                    continue
                }
                
                
                // First good item in the loop
                if candidateAttributes == nil {
                    candidateAttributes = attributes
                    continue
                }
                
                
                // Save constants to improve readability
                let lastCenterOffset = candidateAttributes!.center.x - proposedContentOffsetCenterX
                let centerOffset = attributes.center.x - proposedContentOffsetCenterX
                
                if fabsf( Float(centerOffset) ) < fabsf( Float(lastCenterOffset) ) {
                    candidateAttributes = attributes
                }
            }
            
            if candidateAttributes != nil {
                // Great, we have a candidate
                return CGPoint(x: candidateAttributes!.center.x - collectionViewSize.width * 0.5 + sectionInset.left / 2, y: proposedContentOffset.y)
            } else {
                // Fallback
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
            }
            
            
        }
        
        fileprivate func updateStyle() {
            self.scrollDirection = .horizontal
            
            self.itemSize = style.pageSize
            
            self.sectionInset = .init(top: style.padding.top,
                                      left: style.padding.leading,
                                      bottom: style.padding.bottom,
                                      right: style.padding.trailing)

            self.minimumInteritemSpacing = style.pageSpacing
        }
        
    }
    
}


#endif
