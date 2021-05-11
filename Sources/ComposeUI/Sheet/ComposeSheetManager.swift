import Foundation
import SwiftUI

final public class ComposeSheetManager : ObservableObject {
    
    public typealias DismissHandler = () -> Void
    
    @Published var sheet : AnyView? = nil
    @Published var onDismiss : DismissHandler? = nil
    
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
    
    public func present<Content : View>(@ViewBuilder content : () -> Content, onDismiss : DismissHandler? = nil) {
        self.sheet = AnyView(content())
        self.onDismiss = onDismiss
    }
    
    public func dismiss() {
        sheet = nil
    }
    
    
}
