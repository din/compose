import Foundation
import Combine

extension Emitters {
    
    public struct DropFirst<Upstream : Emitter> : Emitter {
        
        public let id = UUID()
        public let publisher: AnyPublisher<Upstream.Value, Never>
        
        public init(emitter : Upstream, count : Int = 1) {
            self.publisher = emitter.publisher
                .dropFirst(count)
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func dropFirst(count : Int = 1) -> Emitters.DropFirst<Self> {
        Emitters.DropFirst(emitter: self, count: count)
    }
    
}
