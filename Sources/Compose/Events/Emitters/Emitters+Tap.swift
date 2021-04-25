import Foundation
import Combine

extension Emitters {
    
    public struct Tap<Upstream : Emitter, OutputValue> : Emitter {
        
        public let id = UUID()
        public let publisher: AnyPublisher<OutputValue?, Never>
        
        public init(emitter : Upstream, keyPath : KeyPath<Upstream.Value, OutputValue>) {
            self.publisher = emitter.publisher.map({ (value : Upstream.Value?) -> OutputValue? in
                let outputValue = value?[keyPath: keyPath]
                return outputValue
            }).eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func tap<OutputValue>(_ keyPath : KeyPath<Self.Value, OutputValue>) -> Emitters.Tap<Self, OutputValue> {
        Emitters.Tap(emitter: self, keyPath: keyPath)
    }

}
