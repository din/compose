import Foundation
import Combine

extension Emitters {
    
    public struct Map<Upstream : Emitter, OutputValue> : Emitter {
        
        public let id : UUID
        public let publisher: AnyPublisher<OutputValue, Never>
        
        public init(emitter : Upstream, transform : @escaping (Upstream.Value) -> OutputValue) {
            self.id = emitter.id
            self.publisher = emitter.publisher.map({ (value : Upstream.Value) -> OutputValue in
                transform(value)
            }).eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func map<OutputValue>(_ transform : @escaping (Value) -> OutputValue) -> Emitters.Map<Self, OutputValue> {
        Emitters.Map(emitter: self, transform: transform)
    }
    
}
