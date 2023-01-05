import Foundation
import Combine

public class TimerEmitter : Emitter {
    
    public let id = UUID()

    public var publisher: AnyPublisher<Date, Never> {
        timerPublisher.eraseToAnyPublisher()
    }
    
    fileprivate let timerPublisher : Timer.TimerPublisher
    
    deinit {
        stop()
    }
    
    public init(every interval: TimeInterval, on runloop: RunLoop = RunLoop.main, in mode: RunLoop.Mode = .default) {
        self.timerPublisher = Timer.publish(every: interval, on: runloop, in: mode)
    }
    
    public func start(_ handler : @escaping (Date) -> Void) {
        let cancellable = self.timerPublisher
            .autoconnect()
            .sink { value in
                handler(value)
            }
        
        self.parentController?.addObserver(cancellable, for: self.id)
    }
    
    public func stop() {
        self.parentController?.removeObserver(for: self.id)
    }
    
}
