import Foundation
import Combine

public protocol AnyRef : AnyObject {

    var objectWillChange : ObservableObjectPublisher { get }
  
}
