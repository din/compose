#if os(iOS)

import Foundation
import UIKit
import SwiftUI
import Combine

extension ComposePagingView {
   
    public class Coordinator : NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
        weak var controller : UIPageViewController? = nil
        
        var data : Data? = nil {
            didSet {
                guard data != nil else {
                    return
                }
                
                controller?.setViewControllers([makeController(for: currentIndex)], direction: .forward, animated: false)
            }
        }
        
        let content : (Data.Element) -> Content
        @Binding var currentIndex : Int
        
        init(@ViewBuilder content : @escaping (Data.Element) -> Content,
             currentIndex : Binding<Int>) {
            self.content = content
            self._currentIndex = currentIndex
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            guard let index = (viewController as? HostingController)?.index else {
                return nil
            }
            
            guard index - 1 >= 0 else {
                return nil
            }
            
            return makeController(for: index - 1)
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
            guard let index = (viewController as? HostingController)?.index else {
                return nil
            }
            
            guard index + 1 < data?.count ?? 0 else {
                return nil
            }
            
            return makeController(for: index + 1)
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard let controller = pageViewController.viewControllers?.first as? HostingController else {
                return
            }
            
            if finished == true {
                currentIndex = controller.index
            }
            
            for controller in previousViewControllers.compactMap({ $0 as? HostingController }) {
                controller.rootView = AnyView(EmptyView())
            }
        }
        
        func makeController(for index : Int) -> UIViewController {
            guard let element = element(for: index) else {
                return UIViewController()
            }
            
            let view = AnyView(content(element).edgesIgnoringSafeArea(.all))
            
            let controller = HostingController(rootView: view)
            controller.index = index
            
            return controller
        }
        
        func updateVisibleController() {
            guard let controller = controller?.viewControllers?.first as? HostingController else {
                return
            }
            
            guard let element = element(for: controller.index) else {
                return
            }
            
            let view = AnyView(content(element).edgesIgnoringSafeArea(.all))
            
            controller.rootView = view
        }
        
        func element(for index : Int) -> Data.Element? {
            guard let data = data, let elementIndex = data.index(data.startIndex, offsetBy: index, limitedBy: data.endIndex) else {
                return nil
            }
            
            return data[elementIndex]
        }
        
    }
   
}

#endif
