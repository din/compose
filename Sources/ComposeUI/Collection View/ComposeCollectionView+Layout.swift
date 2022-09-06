#if os(iOS)

import Foundation
import UIKit

extension ComposeCollectionView {
    
    class Layout : UICollectionViewFlowLayout {
        
        var style : ComposeCollectionViewStyle = .init() {
            
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
            guard style.shouldCenterOnCells == true else {
                return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            }
            
            let collectionViewSize = self.collectionView!.bounds.size
            
            if style.direction == .horizontal {
                let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width * 0.5
                
                let proposedRect = CGRect(x: proposedContentOffset.x,
                                          y: 0,
                                          width: collectionViewSize.width,
                                          height: collectionViewSize.height)
                
                var candidateAttributes: UICollectionViewLayoutAttributes?
                for attributes in self.layoutAttributesForElements(in: proposedRect)! {
                    if attributes.representedElementCategory != .cell {
                        continue
                    }
                    
                    let currentOffset = self.collectionView!.contentOffset

                    if (attributes.center.x < (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x > 0) || (attributes.center.x > (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x < 0) {
                        continue
                    }
      
                    if candidateAttributes == nil {
                        candidateAttributes = attributes
                        continue
                    }
    
                    let lastCenterOffset = candidateAttributes!.center.x - proposedContentOffsetCenterX
                    let centerOffset = attributes.center.x - proposedContentOffsetCenterX
                    
                    if fabsf( Float(centerOffset) ) < fabsf( Float(lastCenterOffset) ) {
                        candidateAttributes = attributes
                    }
                }
                
                if candidateAttributes != nil {
                    return CGPoint(x: candidateAttributes!.center.x - collectionViewSize.width * 0.5 + sectionInset.left / 2,
                                   y: proposedContentOffset.y)
                } else {
                    return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
                }
            }
            else {
                let proposedContentOffsetCenterY = proposedContentOffset.y + collectionViewSize.height * 0.5
                
                let proposedRect = CGRect(x: 0,
                                          y: proposedContentOffset.y,
                                          width: collectionViewSize.width,
                                          height: collectionViewSize.height)
                
                var candidateAttributes: UICollectionViewLayoutAttributes?
                for attributes in self.layoutAttributesForElements(in: proposedRect)! {
                    if attributes.representedElementCategory != .cell {
                        continue
                    }
                    
                    let currentOffset = self.collectionView!.contentOffset
                    
                    if (attributes.center.y < (currentOffset.y + collectionViewSize.height * 0.5) && velocity.y > 0) || (attributes.center.y > (currentOffset.y + collectionViewSize.height * 0.5) && velocity.y < 0) {
                        continue
                    }
                    
                    if candidateAttributes == nil {
                        candidateAttributes = attributes
                        continue
                    }
                    
                    let lastCenterOffset = candidateAttributes!.center.y - proposedContentOffsetCenterY
                    let centerOffset = attributes.center.y - proposedContentOffsetCenterY
                    
                    if fabsf( Float(centerOffset) ) < fabsf( Float(lastCenterOffset) ) {
                        candidateAttributes = attributes
                    }
                }
                
                if candidateAttributes != nil {
                    return CGPoint(x: proposedContentOffset.x,
                                   y: candidateAttributes!.center.y - collectionViewSize.height * 0.5 + sectionInset.top / 2)
                } else {
                    return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
                }
            }
        }
        
        fileprivate func updateStyle() {
            self.scrollDirection = style.direction == .horizontal ? .horizontal : .vertical
            
            self.itemSize = style.pageSize
            
            self.sectionInset = .init(top: style.padding.top,
                                      left: style.padding.leading,
                                      bottom: style.padding.bottom,
                                      right: style.padding.trailing)

            if style.pageSpacing == 0 {
                self.minimumLineSpacing = 0
                self.minimumInteritemSpacing = 0
            }
            else {
                self.minimumInteritemSpacing = style.pageSpacing
            }
        }
        
    }
    
}


#endif
