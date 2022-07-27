#if os(iOS)

import Foundation
import SwiftUI

public struct ComposePagingViewStyle : Equatable {
    
    public var pageSize : CGSize
    public var pageSpacing : CGFloat
    public var padding : EdgeInsets
    
    public init(pageSize : CGSize = .init(width: UIScreen.main.bounds.width,
                                          height: 300),
                pageSpacing : CGFloat = 16,
                padding : EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)) {
        self.pageSize = pageSize
        self.pageSpacing = pageSpacing
        self.padding = padding
    }
    
}

private struct ComposePagingViewStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposePagingViewStyle = ComposePagingViewStyle()
    
}

extension EnvironmentValues {
    
    public var composePagingViewStyle : ComposePagingViewStyle {
        get { self[ComposePagingViewStyleKey.self] }
        set { self[ComposePagingViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composePagingViewStyle(_ style : ComposePagingViewStyle) -> some View {
        self.environment(\.composePagingViewStyle, style)
    }
    
}


#endif
