import Foundation
import Combine

extension Emitters {
    
    public struct DropUntil<Upstream : Emitter> : Emitter  {
        
        public let id : UUID
        public let publisher: AnyPublisher<Upstream.Value, Never>
        
        public init<OtherEmitter : Emitter>(emitter : Upstream, otherEmitter : OtherEmitter) {
            self.id = emitter.id
            self.publisher = emitter.publisher
                .drop(untilOutputFrom: otherEmitter.publisher)
                .eraseToAnyPublisher()
        }
        
        public init<OtherPublisher : Publisher>(emitter : Upstream, otherPublisher : OtherPublisher) where OtherPublisher.Failure == Never {
            self.id = emitter.id
            self.publisher = emitter.publisher
                .drop(untilOutputFrom: otherPublisher)
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func dropUntil<OtherEmitter : Emitter>(emitter : OtherEmitter) -> Emitters.DropUntil<Self> {
        Emitters.DropUntil(emitter: self, otherEmitter: emitter)
    }
    
    public func dropUntil<OtherPublisher : Publisher>(publisher : OtherPublisher) -> Emitters.DropUntil<Self> where OtherPublisher.Failure == Never {
        Emitters.DropUntil(emitter: self, otherPublisher: publisher)
    }
    
}
