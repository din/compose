import Foundation
import Combine

public protocol AnyRef : AnyObject {

    var objectWillChange : ObservableObjectPublisher { get }
    var destroyedAction : (() -> Void)? { get set }
  
}
