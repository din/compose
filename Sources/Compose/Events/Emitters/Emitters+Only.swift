import Foundation
import Combine

extension Emitters {
    
    public struct Only<Upstream : Emitter> : Emitter where Upstream.Value : Equatable {
        
        public let id = UUID()
        public let publisher: AnyPublisher<Void, Never>
        
        public init(emitter : Upstream, value : Upstream.Value) {
            self.publisher = emitter.publisher
                .filter({ currentValue in
                    currentValue == value
                })
                .map { _ in
                    Void()
                }
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func only(_ value : Value) -> Emitters.Only<Self> where Value : Equatable {
        Emitters.Only(emitter: self, value: value)
    }
    
}
