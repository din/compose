#if os(iOS)

import Foundation
import UIKit
import SwiftUI

extension ComposePagingView {
    
    public class Coordinator : NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
        
        weak var collectionView : UICollectionView? = nil {
            
            didSet {
                guard let view = collectionView else {
                    return
                }
                
                view.dataSource = self
                view.delegate = self
                
                view.decelerationRate = .fast
                view.showsVerticalScrollIndicator = false
                view.showsHorizontalScrollIndicator = false
                view.backgroundColor = UIColor.clear
                view.contentInsetAdjustmentBehavior = .never
                
                view.register(PageCell.self, forCellWithReuseIdentifier: "Page")
            }
            
        }
        
        var data : Data? = nil {
            
            didSet {
                if let oldData = oldValue, let newData = data {
                    let diff = newData.difference(from: oldData) { a, b in
                        return a.id == b.id
                    }
                    
                    if diff.insertions.count == 0 && diff.removals.count == 0 {
                        UIView.performWithoutAnimation {
                            collectionView?.reloadItems(at: collectionView?.indexPathsForVisibleItems ?? [])
                        }
                    }
                    else {
                        collectionView?.reloadData()
                    }
                }
                else {
                    collectionView?.reloadData()
                }
                
                if data != nil && currentIndex != 0 {
                    DispatchQueue.main.async {
                        self.collectionView?.scrollToItem(at: .init(item: self.currentIndex, section: 0),
                                                          at: .centeredVertically,
                                                          animated: false)
                    }
                }
            }
            
        }
        
        var style : ComposePagingViewStyle {
            
            get {
                (collectionView?.collectionViewLayout as? Layout)?.style ?? .init()
            }
            
            set {
                (collectionView?.collectionViewLayout as? Layout)?.style = newValue
            }
            
        }
        
        let content : (Data.Element) -> Content
        @Binding var currentIndex : Int
        
        init(@ViewBuilder content : @escaping (Data.Element) -> Content,
             currentIndex : Binding<Int>) {
            self.content = content
            self._currentIndex = currentIndex
        }
        
        public func numberOfSections(in collectionView: UICollectionView) -> Int {
            1
        }
        
        public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            guard let data = data else {
                return 0
            }
            
            return data.count
        }
        
        public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let data = data,
                  let index = data.index(data.startIndex, offsetBy: indexPath.item, limitedBy: data.endIndex) else {
                return UICollectionViewCell()
            }
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Page", for: indexPath) as? PageCell else {
                return UICollectionViewCell()
            }

            let element = data[index]
            
            cell.updateContent(to: content(element), shouldRecreateView: style.shouldRecreateContentView)
            
            return cell
        }
        
        public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            guard let layout = collectionView?.collectionViewLayout as? Layout else {
                return
            }
            
            let finalOffset = layout.targetContentOffset(forProposedContentOffset: scrollView.contentOffset, withScrollingVelocity: velocity)
            let finalIndex = Int(max(0, floor(finalOffset.x / layout.itemSize.width)))
            
            if finalIndex != self.currentIndex {
                self.currentIndex = finalIndex
            }
        }

    }
    
}

#endif
