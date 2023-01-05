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
        
        self.parentController?.addObserver(cancellable, for: self.id)

        for upstreamId in upstreamIds {
            self.parentController?.addObserver(cancellable, for: upstreamId)
        }
        
        return cancellable
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

