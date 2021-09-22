import Foundation
import SwiftUI

public struct ComposeScrollViewStyle {
    
    public var tintColor : Color
    
    public var threshold : CGFloat
    public var progressOffset : CGFloat

    public init(tintColor : Color = .white,
                threshold : CGFloat = 50,
                progressOffset : CGFloat = 35) {
        self.tintColor = tintColor
        self.threshold = threshold
        self.progressOffset = progressOffset
    }
    
}

private struct ComposeScrollViewStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposeScrollViewStyle = ComposeScrollViewStyle()
    
}

extension EnvironmentValues {
    
    public var composeScrollViewStyle : ComposeScrollViewStyle {
        get { self[ComposeScrollViewStyleKey.self] }
        set { self[ComposeScrollViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composeScrollViewStyle(_ style : ComposeScrollViewStyle) -> some View {
        self.environment(\.composeScrollViewStyle, style)
    }
    
}
