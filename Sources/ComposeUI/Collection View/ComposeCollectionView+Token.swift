import Foundation

public class ComposeCollectionViewToken : ObservableObject {
    
    public init() {
        
    }
    
    public func invalidate() {
        objectWillChange.send()
    }
    
}
