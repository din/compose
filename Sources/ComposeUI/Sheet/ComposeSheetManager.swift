import Foundation
import SwiftUI

final public class ComposeSheetManager : ObservableObject {
    
    var style : ComposeSheetPresentationStyle = .sheet
    
    @Published var content : AnyView? = nil
    @Published public var shouldPreventDismissal : Bool = false
    
    public init() {
        
    }
    
    func hasContent(with style : ComposeSheetPresentationStyle) -> Binding<Bool> {
        .init(get: {
            self.content != nil && self.style == style
        }, set: { value in
            if value == false {
                DispatchQueue.main.async {
                    self.content = nil
                }
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
