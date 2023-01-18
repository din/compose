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
    
}

extension SignalEmitter : DynamicComponentAddressable {
    
    public static var fallbackValue : SignalEmitter {
        SignalEmitter()
    }
    
}
