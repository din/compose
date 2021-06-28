import Foundation

class RefBag {
    
    typealias Monitor = ([AnyRef]) -> Void
    
    static let shared = RefBag()
    
    var refs = [AnyRef]()
    
    init() {
        
    }
    
    func add(_ ref : AnyRef) {
        refs.append(ref)
    }
    
}

extension RefBag {
    
    func endMonitoring(with monitor : Monitor) {
        guard refs.count > 0 else {
            return
        }
        
        monitor(refs)
        refs.removeAll()
    }
}
