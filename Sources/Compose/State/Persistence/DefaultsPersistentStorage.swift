import Foundation

public class DefaultsPersistentStorage : AnyPersistentStorage {
    
    public let key : String
    
    public required init(key: String) {
        self.key = key
    }
    
    public func save<State>(state: State) where State : Codable {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(state)
            UserDefaults.standard.set(data, forKey: key)
        }
        catch let error {
            print("DefaultPersistentStorage '\(key)' save error: \(error)")
        }
    }
    
    public func restore<State>() -> State? where State : Codable {
        let decoder = PropertyListDecoder()
        
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        do {
            return try decoder.decode(State.self, from: data)
        }
        catch let error {
            print("DefaultPersistentStorage '\(key)' load error: \(error)")
            return nil
        }
    }
    
    public func purge() {
        UserDefaults.standard.setValue(nil, forKey: key)
    }
    
}
