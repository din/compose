import Foundation
import Combine

class ObservationTree : ObservationNode {
    
    static let shared = ObservationTree()
    
    fileprivate var nodes = NSMapTable<NSString, ObservationNode>.strongToWeakObjects()
    fileprivate var scope = [UUID]()
    
    fileprivate init() {
        super.init(id: UUID())
        
        nodes.setObject(self, forKey: self.id.uuidString as NSString)
        scope.append(self.id)
    }
    
    var currentNode : ObservationNode? {
        guard let scopeId = scope.last else {
            return nil
        }
        
        return nodes.object(forKey: scopeId.uuidString as NSString)
    }
    
    func node(for id : UUID) -> ObservationNode? {
        return nodes.object(forKey: id.uuidString as NSString)
    }
    
    func push(id : UUID) {
        scope.append(id)
    }
    
    func pop() {
        guard scope.last != nil else {
            print("[Compose] Warning: trying to get out of observation scope when there are no scopes.")
            return
        }
        
        scope.removeLast()
    }
    
}

// Observation node represents a subtree of observers for part of
// hierarchy.
class ObservationNode {
    
    // Each observation node represents a component scope.
    let id : UUID
    
    // Parent of a node.
    weak var parent : ObservationNode? = nil
    
    // Children observation node.
    var children = Set<ObservationNode>()

    // Observers defined for this observation node.
    var observers = Set<AnyCancellable>()
    
    init(id : UUID) {
        self.id = id
    }
    
    deinit {
        ObservationTree.shared.nodes.removeObject(forKey: id.uuidString as NSString)
    }
    
    func addObserver<V>(_ observer : Observer<V>, for emitterid : UUID) {
        self.observers.insert(observer.cancellable)
    }
    
    @discardableResult
    func addChild(id : UUID) -> ObservationNode {
        let child = ObservationNode(id: id)
        child.parent = self
        
        ObservationTree.shared.nodes.setObject(child, forKey: child.id.uuidString as NSString)
        
        children.insert(child)
        return child
    }
    
    func remove(includeChildren : Bool = true) {
        observers.forEach {
            $0.cancel()
        }
        
        observers.removeAll()
        
        if includeChildren == true {
            children.forEach {
                $0.remove(includeChildren: true)
            }
            
            children.removeAll()
        }
        
        parent?.children.remove(self)
    }
    
}

extension ObservationNode : Hashable, Equatable {
    
    static func == (lhs: ObservationNode, rhs: ObservationNode) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
