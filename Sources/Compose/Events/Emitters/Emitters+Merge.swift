import Foundation
import Combine

extension Emitters {
    
    public struct Merge<Upstream : Emitter> : Emitter {
        
        public let id = UUID()
        public let publisher: AnyPublisher<Upstream.Value, Never>
        
        public let upstreamIds : [UUID]
        
        public init(_ emitters : Upstream...) {
            assert(emitters.count > 1, "Emitters.Merge must have at least two emitters to merge their results.")
            
            self.publisher = Publishers.MergeMany(emitters.map { $0.publisher }).eraseToAnyPublisher()
            self.upstreamIds = emitters.map { $0.id }
        }

    }
    
}

extension Emitters.Merge {
    
    @discardableResult
    public func observe(handler: @escaping (Upstream.Value) -> Void) -> AnyCancellable {
        let cancellable = publisher.sink { value in
            handler(value)
        }
        
        ObservationBag.shared.add(cancellable, for: id)
        
        for upstreamId in upstreamIds {
            ObservationBag.shared.add(cancellable, for: upstreamId)
        }
        
        return cancellable
    }
    
    @discardableResult
    public func observeOnce(handler : @escaping (Upstream.Value) -> Void) -> AnyCancellable {
        var cancellable : AnyCancellable? = nil
        
        cancellable = publisher.sink { value in
            handler(value)
            
            if let cancellable = cancellable {
                ObservationBag.shared.remove(for: id)
                
                for upstreamId in upstreamIds {
                    ObservationBag.shared.remove(for: upstreamId)
                }
                
                cancellable.cancel()
            }
        }
        
        if let cancellable = cancellable {
            ObservationBag.shared.add(cancellable, for: id)
            
            for upstreamId in upstreamIds {
                ObservationBag.shared.add(cancellable, for: upstreamId)
            }
        }
        
        return cancellable ?? AnyCancellable({ })
    }
    
}

extension Emitter {
    
    public func merge(with otherEmitter : Self) -> Emitters.Merge<Self> {
        Emitters.Merge(self, otherEmitter)
    }
    
    public static func +(lhs : Self, rhs : Self) -> Emitters.Merge<Self> {
        Emitters.Merge(lhs, rhs)
    }
    
}

