import Foundation
import SwiftUI

public struct ComposeToastViewStyle {
    
    public var background : AnyView
    public var foregroundColor : Color
    public var errorBackgroundColor : Color
    public var successBackgroundColor : Color
    
    public init<Background : View>(background : Background = Color.black,
                                   foregroundColor : Color = .white,
                                   errorBackgroundColor : Color = Color.red.opacity(0.6),
                                   successBackgroundColor : Color = Color.green.opacity(0.6)) {
        self.background = AnyView(background)
        self.foregroundColor = foregroundColor
        self.errorBackgroundColor = errorBackgroundColor
        self.successBackgroundColor = successBackgroundColor
    }
    
    public func background(for event : ComposeToastViewEvent) -> AnyView {
        switch event {
        
        case .normal:
            return background
            
        case .error:
            return AnyView(errorBackgroundColor)
            
        case .success:
            return AnyView(successBackgroundColor)
            
        }
    }
    
}

private struct ComposeToastViewStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposeToastViewStyle = ComposeToastViewStyle()
    
}

extension EnvironmentValues {
    
    public var composeToastViewStyle : ComposeToastViewStyle {
        get { self[ComposeToastViewStyleKey.self] }
        set { self[ComposeToastViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composeToastViewStyle(_ style : ComposeToastViewStyle) -> some View {
        self.environment(\.composeToastViewStyle, style)
    }
    
}

