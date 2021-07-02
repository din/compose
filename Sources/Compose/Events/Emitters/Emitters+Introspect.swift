import Foundation
import Combine
import SwiftUI

extension Emitters {
    
    public struct Introspect<Upstream : Emitter> : Emitter {
        
        public let id : UUID
        public let publisher: AnyPublisher<Upstream.Value, Never>
        
        public init(emitter : Upstream,
             receiveSubscription : ((Subscription) -> Void)?,
             receiveOutput : ((Upstream.Value) -> Void)?,
             receiveCompletion : ((Subscribers.Completion<Never>) -> Void)?,
             receiveCancel : (() -> Void)?) {
            self.id = emitter.id
            self.publisher = emitter.publisher
                .handleEvents(receiveSubscription: receiveSubscription,
                              receiveOutput: receiveOutput,
                              receiveCompletion: receiveCompletion,
                              receiveCancel: receiveCancel)
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {

    public func introspect(receiveSubscription : ((Subscription) -> Void)? = nil,
                    receiveOutput : ((Self.Value) -> Void)? = nil,
                    receiveCompletion : ((Subscribers.Completion<Never>) -> Void)? = nil,
                    receiveCancel : (() -> Void)? = nil) -> Emitters.Introspect<Self> {
        Emitters.Introspect(emitter: self,
                            receiveSubscription: receiveSubscription,
                            receiveOutput: receiveOutput,
                            receiveCompletion: receiveCompletion,
                            receiveCancel: receiveCancel)
    }
    
    public func status<Status : AnyStatus>(_ binding : Binding<StatusSet<Status>>, _ value : Status) -> Emitters.Introspect<Self> {
        introspect { _ in
            binding.wrappedValue += value
        } receiveCompletion: { _ in
            binding.wrappedValue -= value
        }

    }
    
    public func status(_ binding : Binding<StatusSet<LoadingStatus>>) -> Emitters.Introspect<Self> {
        status(binding, .loading)
    }
    
}
