import Foundation
import Combine
import SwiftUI

public typealias ValidatedStore<State : AnyState, Validation : AnyValidation> = Store<State, Validation, Empty>
public typealias IndicatedStore<State : AnyState, Status : AnyStatus> = Store<State, Empty, Status>
public typealias PlainStore<State : AnyState> = Store<State, Empty, Empty>

public class Store<State : AnyState,
                   Validation : AnyValidation,
                   Status : AnyStatus> : AnyStore, ObservableObject {
    
    @Published public var state : State
    
    @Published public var status : Set<Status> = []
    
    @Published public var validation = Validation()
    
    public let didChange : ValueEmitter<State>

    public let didStatusChange : ValueEmitter<Set<Status>>
    
    internal var cancellables = Set<AnyCancellable>()
    
    fileprivate let storage : AnyPersistentStorage
    
    public init(_ initialState : State = .init(), storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        self.state = initialState
        self.didChange = ValueEmitter(initialState)
        self.didStatusChange = ValueEmitter([])
        self.storage = storage
        
        $state
            .removeDuplicates()
            .sink { state in
            self.didChange.send(state)
        }.store(in: &cancellables)
        
        if validation is Empty == false {
            $state
                .dropFirst()
                .removeDuplicates()
                .debounce(for: 0.1, scheduler: RunLoop.main)
                .sink { state in
                self.validation.validate(object: state)
            }.store(in: &cancellables)
        }
        
        if Status.Type.self != Empty.Type.self {
            $status
                .sink { status in
                self.didStatusChange.send(status)
            }.store(in: &cancellables)
        }
        
        let mirror = Mirror(reflecting: state)
        
        for child in mirror.children {
            guard let value = child.value as? AnyRef else {
                continue
            }
            
            value.objectWillChange.sink { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.didChange.send(strongSelf.state)
                strongSelf.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }
    
    public func invalidate() {
        self.objectWillChange.send()
    }
    
    deinit {
        cancellables.removeAll()
    }
    
}

extension Store {
    
    public var binding : Binding<State> {
        .init {
            return self.state
        } set: { value in
            self.state = value
        }
        
    }
    
}

extension Store {
    
    public var persistence : Persistence<State> {
        .init(storage: storage) {
            return self.state
        } set: { value in
            self.state = value
        }
    }
    
}
