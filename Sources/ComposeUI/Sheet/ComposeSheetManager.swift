import Foundation
import SwiftUI

final public class ComposeSheetManager : ObservableObject {
    
    @Published var sheet : AnyView? = nil
    @Published public var shouldPreventDismissal : Bool = false
    
    public init() {
        
    }
    
    var hasSheet : Binding<Bool> {
        .init(get: {
            self.sheet != nil
        }, set: { value in
            if value == false {
                self.sheet = nil
            }
        })
    }
    
    public func present<Content : View>(@ViewBuilder content : () -> Content) {
        self.sheet = AnyView(content())
    }
    
    public func dismiss() {
        sheet = nil
        shouldPreventDismissal = false
    }
    
}
