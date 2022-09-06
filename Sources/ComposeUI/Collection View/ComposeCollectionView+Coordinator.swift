#if os(iOS)

import Foundation
import UIKit
import SwiftUI
import Combine

extension ComposeCollectionView {
    
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
                
                view.register(Cell.self, forCellWithReuseIdentifier: "Page")
            }
            
        }
        
        weak var token : ComposeCollectionViewToken? = nil {
            
            didSet {
                cancellables.forEach {
                    $0.cancel()
                }
                
                cancellables.removeAll()
                
                if let token = token {
                    token.objectWillChange.sink { [weak self] in
                        UIView.performWithoutAnimation {
                            guard let count = self?.data?.count, count > 0 else {
                                return
                            }
                            
                            let indexPaths = (0...count - 1).map { IndexPath(item: $0, section: 0) }
                            self?.collectionView?.reloadItems(at: indexPaths)
                        }
                    }
                    .store(in: &cancellables)
                }
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
        
        var style : ComposeCollectionViewStyle {
            
            get {
                (collectionView?.collectionViewLayout as? Layout)?.style ?? .init()
            }
            
            set {
                (collectionView?.collectionViewLayout as? Layout)?.style = newValue
                
                if style.shouldCenterOnCells == true {
                    collectionView?.decelerationRate = .fast
                }
                else {
                    collectionView?.decelerationRate = .normal
                }
            }
            
        }
        
        let content : (Data.Element) -> Content
        @Binding var currentIndex : Int
        
        fileprivate var cancellables = [AnyCancellable]()
        fileprivate var lastOffset = CGPoint.zero
        
        init(@ViewBuilder content : @escaping (Data.Element) -> Content,
             currentIndex : Binding<Int>) {
            self.content = content
            self._currentIndex = currentIndex
        }
        
        deinit {
            token = nil
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
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Page", for: indexPath) as? Cell else {
                return UICollectionViewCell()
            }

            let element = data[index]
            
            cell.updateContent(to: content(element), shouldRecreateView: style.shouldRecreateContentView)
            
            return cell
        }
        
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView.isDragging == true || scrollView.isDecelerating == true else {
                return
            }
            
            guard let layout = collectionView?.collectionViewLayout as? Layout else {
                return
            }
            
            var finalIndex : CGFloat = 0
            var isForward = false
            
            if style.direction == .horizontal {
                finalIndex = max(0, scrollView.contentOffset.x / layout.itemSize.width)
                
                if lastOffset.x > scrollView.contentOffset.x {
                    isForward = true
                }
            }
            else {
                finalIndex = max(0, scrollView.contentOffset.y / layout.itemSize.height)
                
                if lastOffset.y <= scrollView.contentOffset.y {
                    isForward = true
                }
            }
            
            let proposedFinalIndex : CGFloat = isForward == true ? ceil(finalIndex) : floor(finalIndex)
            
            lastOffset = scrollView.contentOffset

            if abs(proposedFinalIndex - finalIndex) <= style.pagingDeccelerationSensitivity && Int(proposedFinalIndex) != self.currentIndex {
                self.currentIndex = Int(proposedFinalIndex)
            }
        }

    }
    
}

#endif
