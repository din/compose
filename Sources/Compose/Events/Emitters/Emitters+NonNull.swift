import Foundation
import Combine

extension Emitters {
    
    public struct NonNull<Upstream : Emitter> : Emitter where Upstream.Value : OptionalValue {
        
        public let id = UUID()
        public let publisher: AnyPublisher<Upstream.Value.Wrapped, Never>
        
        public init(emitter : Upstream) {
            self.publisher = emitter.publisher
                .compactMap { (currentValue : Upstream.Value?) in
                    currentValue as? Upstream.Value.Wrapped
                }
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func nonNull() -> Emitters.NonNull<Self> where Self.Value : OptionalValue {
        Emitters.NonNull(emitter: self)
    }
    
}
