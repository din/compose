import Foundation
import SwiftUI

// Heavily influenced and adopted from
// https://github.com/globulus/swiftui-pull-to-refresh/blob/main/Sources/SwiftUIPullToRefresh/SwiftUIPullToRefresh.swift
public struct ComposeScrollView<Content : View> : View {
   
    public typealias CompletionHandler = () -> Void
    public typealias RefreshHandler = (@escaping CompletionHandler) -> Void
        
    private enum Status {
        case idle
        case dragging
        case primed
        case loading
    }
    
    @Environment(\.composeScrollViewStyle) var style
    
    private let axes : Axis.Set
    private let showsIndicators : Bool
    private let onRefresh : RefreshHandler?
    private let onReachedBottom : CompletionHandler?
    private let onReachedTop : CompletionHandler?
    private let content : Content
    
    @State private var status : Status = .idle
    @State private var progress : Double = 0
    @State private var startDraggingOffset : CGPoint = .zero
    
    @Binding var scrollPosition : ComposeScrollPosition
    
    public init(_ axes : Axis.Set = .vertical,
                showsIndicators: Bool = false,
                onRefresh : RefreshHandler? = nil,
                onReachedBottom : CompletionHandler? = nil,
                onReachedTop : CompletionHandler? = nil,
                scrollPosition : Binding<ComposeScrollPosition> = .constant(.top),
                @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.onReachedBottom = onReachedBottom
        self.onReachedTop = onReachedTop
        self._scrollPosition = scrollPosition
        self.content = content()
    }
    
    var progressBody: some View {
        ZStack {
            if status == .loading {
                ActivityIndicator()
                    .offset(y: -style.progressOffset)
            }
            else if status != .idle {
                PullIndicator()
                    .rotationEffect(.degrees(180 * progress))
                    .opacity(progress)
                    .offset(y: -style.progressOffset)
            }
        }
    }
    
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            
            ComposeScrollViewPositionIndicator(type: .moving)
                .frame(height: 0)
                .overlay(
                    ComposeScrollViewReader(startDraggingOffset: $startDraggingOffset,
                                            scrollPosition: $scrollPosition,
                                            onReachedBottom: onReachedBottom,
                                            onReachedTop: onReachedTop)
                )
            
            if status == .loading {
                Color.clear
                    .frame(height: style.threshold)
            }
            
            content
                .overlay(onRefresh != nil ? progressBody : nil, alignment: .top)
        }
        .background(ComposeScrollViewPositionIndicator(type: .fixed))
        .onPreferenceChange(ComposeScrollViewPositionIndicator.PositionPreferenceKey.self) { values in
            guard status != .loading, onRefresh != nil else {
                return
            }
            
            guard startDraggingOffset == .zero else {
                status = .idle
                return
            }
            
            if status == .idle {
                status = .dragging
            }
            
            DispatchQueue.main.async {
                let movingY = values.first { $0.type == .moving }?.y ?? 0
                let fixedY = values.first { $0.type == .fixed }?.y ?? 0
                let offset : CGFloat = movingY - fixedY

                progress = Double(min(max(abs(offset) / style.threshold, 0.0), 1.0))
                
                if offset > style.threshold && status == .dragging {
                    status = .primed
                }
                else if offset < style.threshold && status == .primed {
                    status = .loading
                    
                    onRefresh? {
                        withAnimation {
                            self.status = .idle
                        }
                    }
                }
            }
        }
        .onTapGesture {
            
        }
    }
    
}

public enum ComposeScrollPosition : Equatable {
    case top
    case middle
    case bottom
}

/* Indicators */
    
private struct PullIndicator : View {
    
    var body: some View {
        Image(systemName: "arrow.down")
            .resizable()
            .frame(width: 12, height: 12)
    }
    
}

private struct ActivityIndicator: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIActivityIndicatorView {
        UIActivityIndicatorView()
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Self>) {
        uiView.startAnimating()
    }
}
