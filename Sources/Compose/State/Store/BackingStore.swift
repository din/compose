import Foundation
import Combine
import SwiftUI

public class BackingStore<State : AnyState> : ObservableObject {

    public let willChange = ValueEmitter<State>()

    internal let id = UUID()
    @Published internal var state : State
    
    internal var cancellables = Set<AnyCancellable>()
    fileprivate var persistStateWhenChangedCancellable : AnyCancellable?
    
    fileprivate let storage : AnyPersistentStorage
   
    public init(storage : AnyPersistentStorage = EmptyPersistentStorage()) {
        self.storage = storage
        self.state = .init()
        
        $state
            .removeDuplicates()
            .sink { [weak self] state in
                self?.willChange.send(state)
        }.store(in: &cancellables)
        
        updateRefs()
        
        withIntrospection {
            willChange.publisher.removeDuplicates().debounce(for: .seconds(0.5), scheduler: RunLoop.main).sink { [weak self] state in
                guard let self = self else {
                    return
                }
                
                Introspection.shared.updateDescriptor(forStore: self.id) {
                    $0?.update(to: self.state)
                }
            }.store(in: &cancellables)
            
            DispatchQueue.main.async {
                Introspection.shared.updateDescriptor(forStore: self.id) {
                    $0?.update(to: self.state)
                }
            }

            guard storage is EmptyPersistentStorage == false else {
                return
            }
            
            Introspection.shared.updateDescriptor(forStore: self.id) {
                let name = String(describing: type(of: storage))
                $0?.persistence = StoreDescriptor.PersistenceDescriptor(name: name, key: storage.key)
            }
        }
    }
    
    deinit {
        cancellables.forEach {
            $0.cancel()
        }
        
        cancellables.removeAll()
        
        persistStateWhenChangedCancellable?.cancel()
        persistStateWhenChangedCancellable = nil
    }
    
    fileprivate func updateRefs() {
        let mirror = Mirror(reflecting: state)
        
        for child in mirror.children {
            guard let value = child.value as? AnyRef else {
                continue
            }
            
            value.destroyedAction = { [weak self] in
                DispatchQueue.main.async {
                    self?.updateRefs()
                }
            }
            
            value.objectWillChange.sink { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.willChange.send(strongSelf.state)
                strongSelf.objectWillChange.send()
            }.store(in: &cancellables)
        }
    }
    
}

extension BackingStore {
    
    public var binding : Binding<State> {
        .init {
            return self.state
        } set: { value in
            self.state = value
        }
        
    }
    
}

extension BackingStore where State : Codable {
    
    public func persistStateWhenChanged() {
        guard persistStateWhenChangedCancellable == nil else {
            return
        }
        
        persistStateWhenChangedCancellable = $state
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

extension BackingStore {

    public func scope<Content : View>(@ViewBuilder content : @escaping (State) -> Content) -> some View {
        let token = StoreScopeView<State, Content>.Token(state: self.state)
        
        let cancellable = $state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                token.state = self.state
            }
        
        cancellables.insert(cancellable)
        
        return StoreScopeView(token: token,
                              destroyedAction: {
                                cancellable.cancel()
                              },
                              content: content)
    }
    
    public func scope<Content : View, V : Equatable>(for keyPath : KeyPath<State, V>, @ViewBuilder content : @escaping (State) -> Content) -> some View {
        let token = StoreScopeView<State, Content>.Token(state: self.state)

        let cancellable = $state
            .map(keyPath)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                token.state = self.state
            }
        
        cancellables.insert(cancellable)
        
        return StoreScopeView(token: token,
                              destroyedAction: {
                                    cancellable.cancel()
                              },
                              content: content)
    }
    
}

