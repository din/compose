import Foundation
import Combine
import SwiftUI

public class StoreContainer<State : AnyState> : ObservableObject {
    
    struct RefStorage {
        weak var ref : AnyRef?
    }

    public let willChange = ValueEmitter<State>()

    @Published internal var state : State
    
    internal var cancellables = Set<AnyCancellable>()
    fileprivate var persistStateChangesCancellable : AnyCancellable?
    
    fileprivate var refs = [RefStorage]()
    fileprivate var hasRefs : Bool = true
    
    fileprivate let storage : AnyPersistentStorage
   
    public init(storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        self.storage = storage
        self.state = .init()
        
        $state
            .removeDuplicates()
            .sink { [weak self] state in
                self?.willChange.send(state)
                self?.updateRefs()
        }.store(in: &cancellables)
        
        updateRefs()
    }
    
    public func invalidate() {
        self.objectWillChange.send()
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
        
        persistStateChangesCancellable?.cancel()
        
        cancellables.removeAll()
        persistStateChangesCancellable = nil
    }
    
}

extension StoreContainer {
    
    public var binding : Binding<State> {
        .init {
            return self.state
        } set: { value in
            self.state = value
        }
        
    }
    
}

extension StoreContainer where State : Codable {
    
    public func persistStateChanges() {
        guard persistStateChangesCancellable == nil else {
            return
        }
        
        persistStateChangesCancellable = $state
            .removeDuplicates()
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] state in
                self?.persistence.save()
            }
    }
    
    public var persistence : Persistence<State> {
        .init(storage: storage) {
            return self.state
        } set: { value in
            self.state = value
        }
    }
    
}

extension StoreContainer {
    
    fileprivate func updateRefs() {
        guard hasRefs == true && (refs.isEmpty == true || refs.contains(where: { $0.ref == nil })) else {
            return
        }
        
        refs.removeAll()
        
        let mirror = Mirror(reflecting: state)

        for child in mirror.children {
            guard let value = child.value as? AnyRef else {
                continue
            }
            
            refs.append(.init(ref: value))
            
            value.objectWillChange.sink { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.willChange.send(strongSelf.state)
                strongSelf.objectWillChange.send()
            }.store(in: &cancellables)
        }
        
        if refs.count == 0 {
            self.hasRefs = false
            return
        }
    }
    
}
