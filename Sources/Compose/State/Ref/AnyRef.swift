import Foundation
import Combine

public protocol AnyRef {

    var objectWillChange : ObservableObjectPublisher { get }
    
}
