import Foundation
import Combine

public struct TimerEmitter : Emitter, ComponentEntry {
    
    fileprivate class Storage {
        var timer : Timer? = nil
    }
    
    public let id = UUID()

    public var publisher : AnyPublisher<Void, Never> {
        subject.eraseToAnyPublisher()
    }
    
    fileprivate let subject = PassthroughSubject<Void, Never>()
    fileprivate let storage = Storage()
    fileprivate let interval : TimeInterval
    
    public init(every interval: TimeInterval) {
        self.interval = interval
    }
    
    public func start() {
        storage.timer = Timer.scheduledTimer(withTimeInterval: self.interval, repeats: true, block: { timer in
            subject.send()
        })
        
        parentController?.addObserver(AnyCancellable {
            stop()
        }, for: self.id)
    }
    
    public func stop() {
        storage.timer?.invalidate()
        storage.timer = nil
        
        parentController?.removeObserver(for: self.id)
    }
    
}

