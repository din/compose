#if os(iOS)

import Foundation
import SwiftUI

// Heavily influenced and adopted from
// https://github.com/globulus/swiftui-pull-to-refresh/blob/main/Sources/SwiftUIPullToRefresh/SwiftUIPullToRefresh.swift
public struct ComposeScrollView<Content : View> : View {
   
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
    private let onReachedEdge : ReachedEdgeHandler?
    private let content : Content
    
    @State private var status : Status = .idle
    @State private var progress : Double = 0
    @State private var startDraggingOffset : CGPoint = .zero
    
    public init(_ axes : Axis.Set = .vertical,
                showsIndicators: Bool = false,
                onRefresh : RefreshHandler? = nil,
                onReachedEdge : ReachedEdgeHandler? = nil,
                @ViewBuilder content: () -> Content) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onRefresh = onRefresh
        self.onReachedEdge = onReachedEdge
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
                    Reader(startDraggingOffset: $startDraggingOffset,
                           onReachedEdge: onReachedEdge)
                )
            
            if status != .idle {
                Color.clear
                    .frame(height: status == .loading ? style.threshold : style.threshold * progress)
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
                
                guard offset > 0 else {
                    return
                }

                progress = Double(min(max(abs(offset) / style.threshold, 0.0), 1.0))
                
                if offset > style.threshold && status == .dragging {
                    status = .primed
                }
                else if offset < style.threshold && status == .primed {
                    withAnimation(.linear(duration: 0.2)) {
                        status = .loading
                    }
                    
                    onRefresh? {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                            withAnimation {
                                self.status = .idle
                                self.progress = 0
                            }
                        }
                      
                    }
                }
            }
        }
        .onTapGesture {
            
        }
    }
    
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

#endif
