import Foundation
import Combine

class CancellableStorage {
    
    var namedCancellables = [String : AnyCancellable]()
    var cancellables = Set<AnyCancellable>()
    
}
