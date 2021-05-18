import Foundation
import Combine

extension Emitters {
    
    public struct FlatMap<Upstream : Emitter, Downstream : Emitter> : Emitter {
        
        public let id = UUID()
        public let publisher: AnyPublisher<Downstream.Value, Never>
        
        public init(emitter : Upstream, transform : @escaping (Upstream.Value) -> Downstream) {
            self.publisher = emitter.publisher
                .flatMap { value in
                    transform(value)
                        .publisher
                }
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func flatMap<Downstream : Emitter>(_ transform : @escaping (Self.Value) -> Downstream) -> Emitters.FlatMap<Self, Downstream> {
        Emitters.FlatMap(emitter: self, transform: transform)
    }
    
}

