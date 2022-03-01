import Foundation
import Combine

extension Emitters {
    
    public struct Receive<Upstream : Emitter, SelectedScheduler : Scheduler> : Emitter {
        
        public let id : UUID
        public let publisher: AnyPublisher<Upstream.Value, Never>
        
        public init(emitter : Upstream, scheduler : SelectedScheduler, options : SelectedScheduler.SchedulerOptions? = nil) {
            self.id = emitter.id
            self.publisher = emitter.publisher
                .receive(on: scheduler, options: options)
                .eraseToAnyPublisher()
        }
        
    }
    
}

extension Emitter {
    
    public func onMain() -> Emitters.Receive<Self, DispatchQueue> {
        self.on(DispatchQueue.main)
    }
    
    public func onBackground(qos: DispatchQoS.QoSClass = .default) -> Emitters.Receive<Self, DispatchQueue> {
        self.on(DispatchQueue.global(qos: qos))
    }
    
    public func on<SelectedScheduler : Scheduler>(_ scheduler : SelectedScheduler,
                                                  options : SelectedScheduler.SchedulerOptions? = nil) -> Emitters.Receive<Self, SelectedScheduler> {
        Emitters.Receive(emitter: self, scheduler: scheduler, options: options)
    }
    
}
