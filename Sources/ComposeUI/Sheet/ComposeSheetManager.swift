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
    
    public func present<Content : View>(@ViewBuilder content : () -> Content,
                                        style : ComposeSheetPresentationStyle = .sheet) {
        self.style = style
        self.content = AnyView(content().zIndex(6))
    }
    
    public func present<Content : View, Background : View>(@ViewBuilder content : () -> Content,
                                                           background : Background,
                                                           style : ComposeSheetPresentationStyle = .sheet) {
        self.style = style
        self.content = AnyView(
            ZStack {
                background
                    .zIndex(5)
                
                content()
                    .zIndex(6)
            }
        )
    }
    
    public func dismiss() {
        content = nil
        shouldPreventDismissal = false
    }
    
}
