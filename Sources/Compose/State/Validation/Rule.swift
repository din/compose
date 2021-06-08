import Foundation

public struct Rule<T> {

    public let id = UUID()
    public let validate : (T) -> Bool
    
    public init(validate: @escaping (T) -> Bool) {
        self.validate = validate
    }
    
}

extension Rule : Hashable, Equatable {
   
    public static func == (lhs: Rule<T>, rhs: Rule<T>) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
