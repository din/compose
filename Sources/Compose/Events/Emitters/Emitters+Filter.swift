import Foundation
import Combine

extension Emitters {
    
    public struct Filter<Upstream : Emitter> : Emitter where Upstream.Value : Equatable {
        
        public let id = UUID()
        public let publisher: AnyPublisher<Upstream.Value, Never>
        
        public init(emitter : Upstream, isIncluded : @escaping (Upstream.Value?) -> Bool) {
            self.publisher = emitter.publisher
                .filter(isIncluded)
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func filter(_ isIncluded : @escaping (Value?) -> Bool) -> Emitters.Filter<Self> where Value : Equatable {
        Emitters.Filter(emitter: self, isIncluded: isIncluded)
    }
    
    public func not(_ value : Value) -> Emitters.Filter<Self> where Value : Equatable {
        Emitters.Filter(emitter: self) { currentValue in
            value != currentValue
        }
    }
    
}
