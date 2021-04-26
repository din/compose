import Foundation
import Combine

public struct SignalEmitter : Emitter {
    
    public let id = UUID()
    
    public var publisher: AnyPublisher<Void, Never> {
        subject
            .eraseToAnyPublisher()
    }
    
    internal let subject = PassthroughSubject<Void, Never>()
    
    public init() {
        
    }
    
    public func send() {
        subject.send()
    }
    
    public static func +(lhs : Self, rhs : Self) -> Emitters.Merge<Self> {
        Emitters.Merge(lhs, rhs)
    }
    
}
