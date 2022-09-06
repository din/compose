#if os(iOS)

import Foundation
import SwiftUI

public struct ComposeCollectionViewStyle : Equatable {
    
    public var direction : Axis
    public var pageSize : CGSize
    public var pageSpacing : CGFloat
    public var padding : EdgeInsets
    
    public var shouldCenterOnCells : Bool
    public var shouldRecreateContentView : Bool
    public var pagingDeccelerationSensitivity : CGFloat
    
    public init(direction : Axis = .horizontal,
                pageSize : CGSize = .init(width: UIScreen.main.bounds.width, height: 300),
                pageSpacing : CGFloat = 16,
                padding : EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                shouldCenterOnCells : Bool = false,
                shouldRecreateContentView : Bool = false,
                pagingDeccelerationSensitivity : CGFloat = 0.2) {
        self.direction = direction
        self.pageSize = pageSize
        self.pageSpacing = pageSpacing
        self.padding = padding
        self.shouldCenterOnCells = shouldCenterOnCells
        self.shouldRecreateContentView = shouldRecreateContentView
        self.pagingDeccelerationSensitivity = pagingDeccelerationSensitivity
    }
    
}

private struct ComposeCollectionViewStyleKey : EnvironmentKey {
    
    static let defaultValue: ComposeCollectionViewStyle = ComposeCollectionViewStyle()
    
}

extension EnvironmentValues {
    
    public var composeCollectionViewStyle : ComposeCollectionViewStyle {
        get { self[ComposeCollectionViewStyleKey.self] }
        set { self[ComposeCollectionViewStyleKey.self] = newValue }
    }
    
}

extension View {
    
    public func composeCollectionViewStyle(_ style : ComposeCollectionViewStyle) -> some View {
        self.environment(\.composeCollectionViewStyle, style)
    }
    
}


#endif
