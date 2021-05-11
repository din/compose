import Foundation
import Combine

final class ObservationBag {
    
    typealias Monitor = (AnyCancellable) -> Void
    
    static let shared = ObservationBag()
    
    var cancellables = Set<AnyCancellable>()
    var namedCancellables = [AnyHashable : AnyCancellable]()
    
    var monitor : Monitor? = nil
    
    func add(_ cancellable : AnyCancellable) {
        cancellables.insert(cancellable)
        monitor?(cancellable)
    }
    
    func remove(_ cancellable : AnyCancellable) {
        cancellables.remove(cancellable)
    }
    
    func add(_ cancellable : AnyCancellable, for key : AnyHashable) {
        namedCancellables[key] = cancellable
        monitor?(cancellable)
    }
    
    func remove(for key : AnyHashable) {
        namedCancellables[key]?.cancel()
        namedCancellables[key] = nil
    }
    
}

extension ObservationBag {
    
    func beginMonitoring(with monitor : @escaping Monitor) {
        self.monitor = monitor
    }
    
    func endMonitoring() {
        self.monitor = nil
    }
}
