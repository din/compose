import Foundation
import SwiftUI
import Combine

public class AnimationReader : ObservableObject {
    
    public typealias Progress = (CGFloat) -> Void
    
    struct Modifier : AnimatableModifier {
        
        var value : CGFloat = 0.0
        @Binding var isDecreasing : Bool
        let progress : Progress?
        
        var animatableData: CGFloat {
            get {
                CGFloat(value)
            }
            set {
                value = newValue
                progress?(isDecreasing == false ? value : 1.0 - value)
            }
        }
        
        func body(content: Content) -> some View {
            content
                .background(Color.clear)
        }
        
    }
    
    @Published fileprivate var value : CGFloat = 0.0
    @Published fileprivate var isDecreasing : Bool = true
    
    fileprivate let id = UUID()
    
    fileprivate var progress : Progress? = nil
    
    fileprivate var isDecreasingBinding : Binding<Bool> {
        .init {
            self.isDecreasing
        } set: { _ in
            // Intentionally left blank.
        }
    }
    
    public init() {
        
    }
    
    public func read(progress : Progress? = nil) {
        self.progress = progress
        
        value = value == 0.0 ? 1.0 : 0.0
        isDecreasing.toggle()
    }
    
}

extension View {
    
    public func readAnimationProgress(reader : AnimationReader) -> some View {
        self
            .modifier(AnimationReader.Modifier(value: reader.value,
                                               isDecreasing: reader.isDecreasingBinding,
                                               progress: reader.progress))
    }
    
    public func onAnimationProgress(reader : AnimationReader, progress : @escaping (CGFloat) -> Void) -> some View {
        self
            .modifier(AnimationReader.Modifier(value: reader.value,
                                               isDecreasing: reader.isDecreasingBinding,
                                               progress: progress))
    }
    
}
