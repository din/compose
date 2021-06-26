import Foundation

public class FilePersistentStorage : AnyPersistentStorage {

    public let key : String
    
    fileprivate let url : URL
    
    public required init(key: String) {
        self.key = key
        self.url = FilePersistentStorage.Root.appendingPathComponent(key)
        
        do {
            try FileManager.default.createDirectory(at: FilePersistentStorage.Root,
                                                     withIntermediateDirectories: true,
                                                     attributes: nil)
        }
        catch let error {
            print("FilePersistentStorage: cannot create root directory. \(error.localizedDescription)")
        }
    }
    
    public func save<State>(state: State) where State : Codable {
        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(state)
            try data.write(to: url)
        }
        catch let error {
            print("FilePersistentStorage '\(key)' save error: \(error)")
        }
    }
    
    public func restore<State>() -> State? where State : Codable {
        let decoder = PropertyListDecoder()
        
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        do {
            return try decoder.decode(State.self, from: data)
        }
        catch let error {
            print("FilePersistentStorage '\(key)' load error: \(error)")
            return nil
        }
    }
  
    public func purge() {
        try? FileManager.default.removeItem(at: url)
    }
 
}

extension FilePersistentStorage {
    
    fileprivate static let Root : URL = {
        let value = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return value.appendingPathComponent("compose-persistence")
    }()
    
}
