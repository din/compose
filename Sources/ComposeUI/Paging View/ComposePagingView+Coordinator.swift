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
        
        var delay : Double = 0.0
        
        var content : (Data.Element) -> Content
        var transitionContent : (Data.Element) -> TransitionContent
        
        @Binding var currentIndex : Int
        
        init(@ViewBuilder content : @escaping (Data.Element) -> Content,
             @ViewBuilder transitionContent : @escaping (Data.Element) -> TransitionContent,
             currentIndex : Binding<Int>) {
            self.content = content
            self.transitionContent = transitionContent
            self._currentIndex = currentIndex
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            guard let index = (viewController as? HostingController)?.index else {
                return nil
            }
            
            guard index - 1 >= 0 else {
                return nil
            }
            
            return makeController(for: index - 1, isTransition: true)
        }
        
        public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
            guard let index = (viewController as? HostingController)?.index else {
                return nil
            }
            
            guard index + 1 < data?.count ?? 0 else {
                return nil
            }
            
            return makeController(for: index + 1, isTransition: true)
        }
         
        public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            guard let controller = pageViewController.viewControllers?.first as? HostingController else {
                return
            }
            
            if finished == true && pageViewController.viewControllers != previousViewControllers {
                currentIndex = controller.index

                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    controller.rootView = self.makeController(for: controller.index).rootView
                    controller.isTransition = false
                }
                
                for controller in previousViewControllers.compactMap({ $0 as? HostingController }) {
                    controller.rootView = makeController(for: controller.index, isTransition: true).rootView
                    controller.isTransition = true
                }
            }
        }
        
        func makeController(for index : Int, isTransition : Bool = false) -> HostingController {
            guard let element = element(for: index) else {
                return HostingController(rootView: AnyView(EmptyView()))
            }
            
            var view = AnyView(EmptyView())
            
            if isTransition == true {
                view = AnyView(transitionContent(element).edgesIgnoringSafeArea(.all))
            }
            else {
                view = AnyView(content(element).edgesIgnoringSafeArea(.all))
            }
            
            let controller = HostingController(rootView: view)
            controller.index = index
            controller.isTransition = isTransition
            
            return controller
        }
        
        func updateVisibleController() {
            guard let controller = controller?.viewControllers?.first as? HostingController else {
                return
            }
            
            guard controller.isTransition == false else {
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
