import Foundation
import SwiftUI

final public class ComposeSheetManager : ObservableObject {
    
    var style : ComposeSheetPresentationStyle = .sheet
    
    @Published var content : AnyView? = nil
    @Published public var shouldPreventDismissal : Bool = false
    
    public init() {
        
    }
    
    var hasContent : Binding<Bool> {
        .init(get: {
            self.content != nil
        }, set: { value in
            if value == false {
                self.content = nil
            }
        })
    }
    
    public func present<Content : View>(@ViewBuilder content : () -> Content, style : ComposeSheetPresentationStyle = .sheet) {
        self.style = style
        self.content = AnyView(content())
    }
    
    public func dismiss() {
        content = nil
        shouldPreventDismissal = false
    }
    
}
