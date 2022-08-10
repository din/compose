import Foundation

public class ComposePagingViewToken : ObservableObject {
    
    public init() {
        
    }
    
    public func invalidate() {
        objectWillChange.send()
    }
    
}
