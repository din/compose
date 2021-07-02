import Foundation
import Combine

final class ObservationBag {
    
    typealias Monitor = (AnyCancellable) -> Void
    
    static let shared = ObservationBag()
    
    var cancellables = [AnyHashable : Set<AnyCancellable>]()
    var owners = [AnyHashable : [AnyHashable]]()
    var monitors = [AnyHashable : Monitor]()
    
    func add(_ cancellable : AnyCancellable, for identifier : AnyHashable) {
        if cancellables[identifier] == nil {
            cancellables[identifier] = .init()
        }
        
        cancellables[identifier]?.insert(cancellable)
        
        monitors.values.forEach {
            $0(cancellable)
        }
    }
    
    func remove(for identifier : AnyHashable) {
        cancellables[identifier]?.forEach {
            $0.cancel()
        }
        
        cancellables[identifier] = nil
    }
    
    func remove(forOwner identifier : AnyHashable) {
        guard let ids = owners[identifier] else {
            return
        }
        
        for id in ids {
            remove(for: id)
        }
        
        owners[identifier] = nil
    }
    
}

extension ObservationBag {
    
    func addOwner(_ ownerId : AnyHashable, for id : AnyHashable) {
        if owners[ownerId] == nil {
            owners[ownerId] = .init()
        }
        
        owners[ownerId]?.append(id)
    }
    
}

extension ObservationBag {
    
    func beginMonitoring(with monitor : @escaping Monitor) -> AnyHashable {
        let key = UUID()
        
        self.monitors[key] = monitor
        
        return key
    }
    
    func endMonitoring(key : AnyHashable) {
        self.monitors[key] = nil
    }
}
