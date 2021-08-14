import Foundation

public struct StoreDescriptor : Codable, Equatable, Identifiable {
    
    public struct PersistenceDescriptor : Codable, Equatable {
        let name : String
        let key : String
        
        public static var empty : PersistenceDescriptor {
            .init(name: "", key: "")
        }
        
    }
    
    public indirect enum Content : Codable, Equatable, Hashable {
        
        public enum CodingKeys : CodingKey {
            case scalar
            case map
            case isRef
        }
        
        static var empty : Content {
            .map([:], isRef: false)
        }
        
        case scalar(String)
        case map([String : Content], isRef : Bool)

        public var isEmpty : Bool {
            switch self {
            
            case .scalar(_):
                return true
                
            case .map(let map, _):
                return map.isEmpty

            }
        }
        
        public var isRef : Bool {
            switch self {
            
            case .scalar(_):
                return false
                
            case .map(_, let isRef):
                return isRef

            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let isRef = try container.decodeIfPresent(Bool.self, forKey: .isRef) ?? false
            
            if let scalar = try container.decodeIfPresent(String.self, forKey: .scalar) {
                self = .scalar(scalar)
            }
            else if let map = try container.decodeIfPresent([String : Content].self, forKey: .map) {
                self = .map(map, isRef: isRef)
            }
            else {
                fatalError("Invalid store contents")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(isRef, forKey: .isRef)
            
            switch self {
            
            case .scalar(let description):
                try container.encode(description, forKey: .scalar)
                
            case .map(let map, _):
                try container.encode(map, forKey: .map)
            
            }
        }
    }
    
    ///Store descriptor ID.
    public let id : UUID
    
    ///Name of store.
    public let name : String
    
    ///Whether the store is a mapped store.
    public let isMapped : Bool
    
    ///Store contents.
    public var content : Content = .empty
    
    ///Persistence descriptor.
    public var persistence = PersistenceDescriptor.empty
    
}

extension StoreDescriptor {
    
    mutating func update<S : AnyState>(to state : S) {
        self.content = describe(value: state)
    }
    
    fileprivate mutating func describe(value : Any, parentValue : Any? = nil) -> Content {
        let mirror = Mirror(reflecting: value)

        if value is AnyOptionalValue, let optionalValue = mirror.descendant("some") {
            return describe(value: optionalValue)
        }
        
        if let date = value as? Date {
            return .scalar(String(date.description))
        }
        
        if value is AnyRef, let nestedValue = mirror.descendant("value") {
            return describe(value: nestedValue, parentValue: value)
        }

        if mirror.displayStyle == .struct || mirror.displayStyle == .collection || mirror.displayStyle == .dictionary ||
            mirror.displayStyle == .class || mirror.displayStyle == .set {
            var values = [String : Content]()
            
            for (name, child) in mirror.children {
                var name = name?.replacingOccurrences(of: "_", with: "") ?? "\(values.count)"

                if child is AnyOptionalValue {
                    name += "?"
                }

                values[name] = describe(value: child)
            }
            
            return .map(values, isRef: parentValue is AnyRef)
        }
        else {
            return .scalar(String(describing: value))
        }
    }
    
}
