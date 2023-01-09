import Foundation
import SwiftUI

/// Detailed configuration of sheet presentation.
public struct ComponentPresentationSheetConfiguration : Equatable {
   
    public enum Detent {
        case medium
        case large
    }
    
    public var detents : [Detent] = [.large]
    
}

/// Defines how component will be  presented modally on the screen.
public enum ComponentPresentation : Equatable {
    /// Custom resizable sheet configuration with support for various detent sizing.
    case sheet(ComponentPresentationSheetConfiguration)
    
    /// Modal presentation which ensures the component covers the whole screen with no gestures support.
    case cover
    
    /// Non-resizable modal sheet presentation, dismissable with swipe gestures.
    public static var largeSheet : ComponentPresentation {
        .sheet(.init())
    }
    
    /// Non-resizable modal sheet presentation which is half of the screen size, dismissable with swipe gestures.
    public static var mediumSheet : ComponentPresentation {
        .sheet(.init(detents: [.medium]))
    }
    
    /// Resizable modal sheet presentation which can be resized from half of the screen size to ordinary large sheet size, dismissable with swipe gestures.
    public static var mediumLargeSheet : ComponentPresentation {
        .sheet(.init(detents: [.medium, .large]))
    }
    
}

extension Component {

    /// Presents component at the specified keypath modally with the specified presentation settings.
    public func present<V : Component>(_ keyPath : KeyPath<Self, V>,
                                       animated : Bool = true,
                                       presentation : ComponentPresentation = .largeSheet) {
        let child = self[keyPath: keyPath]
        
        let controller = self.controller
        
        var childController : ComponentController
        
        if let dynamicChild = child as? AnyDynamicComponent, let controller = dynamicChild.storage.lastController {
            childController = controller
        }
        else {
            childController = child.controller
        }
        
        if presentation == .cover {
            childController.modalPresentationStyle = .fullScreen
        }
        else if case .sheet(let configuration) = presentation {
            childController.modalPresentationStyle = .pageSheet
            
            if #available(iOS 15.0, *) {
                if let sheet = childController.sheetPresentationController {
                    var sheetDetents = [UISheetPresentationController.Detent]()
                    
                    if configuration.detents.contains(.medium) == true {
                        sheetDetents.append(.medium())
                    }
                    
                    if configuration.detents.contains(.large) == true  {
                        sheetDetents.append(.large())
                    }
                    
                    sheet.detents = sheetDetents
                    sheet.largestUndimmedDetentIdentifier = .none
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                    sheet.prefersGrabberVisible = false
                }
            }
            else {
                childController.modalPresentationStyle = .pageSheet
            }
        }
        
        controller.present(childController, animated: animated)
    }
    
    public func dismiss(animated : Bool = true) {
        let controller = self.controller
        
        guard controller.presentedViewController != nil else {
            return
        }
        
        controller.dismiss(animated: animated)
    }
    
}

extension Component {
    
    /// Returns true if current component is presented modally.
    public var isPresentedModally : Bool {
        controller.isModal
    }
    
}

extension Component {
    
    public var didCreate : SignalEmitter {
        controller.didCreate
    }
    
    public var didDestroy : SignalEmitter {
        controller.didDestroy
    }
    
    public var didAppear : SignalEmitter {
        controller.didAppear
    }
    
    public var didDisappear : SignalEmitter {
        controller.didDisappear
    }
    
}

extension Component where Self : View {
    
    public var view: AnyView {
        AnyView(
            self
        )
    }
    
}

