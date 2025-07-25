 import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

internal struct ToastPresenterModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    @Environment(\.toastConfiguration) private var configuration
    let alignment: Alignment

    init(toastManager: ToastManager, alignment: Alignment = .top) {
        self.toastManager = toastManager
        self.alignment = alignment
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if toastManager.queueMode == .queue && !toastManager.toastQueue.isEmpty {
                        GeometryReader { geometry in
                            Color.clear
                                .overlay(
                                    stackedToastsView(geometry: geometry),
                                    alignment: alignment
                                )
                        }
                        .allowsHitTesting(true)
                    } else if let currentToast = toastManager.currentToast {
                        GeometryReader { geometry in
                            Color.clear
                                .overlay(
                                    singleToastView(toast: currentToast, geometry: geometry),
                                    alignment: alignment
                                )
                        }
                        .allowsHitTesting(true)
                    }
                }
                .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: toastManager.currentToast?.id)
                .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: toastManager.toastQueue.count)
            )
    }
    
    @ViewBuilder
    private func singleToastView(toast: ToastData, geometry: GeometryProxy) -> some View {
        ToastView(toast: toast)
            .transition(toastTransition(for: alignment))
            .offset(
                x: calculateHorizontalOffset(for: alignment),
                y: calculateVerticalOffset(for: alignment, in: geometry.safeAreaInsets)
            )
            .zIndex(1)
            .id(toast.id)
            .onTapGesture {
                toastManager.dismiss()
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Toast notification: \(toast.message)")
            .accessibilityHint("Double tap to dismiss")
            .accessibilityAction(named: "Dismiss") {
                toastManager.dismiss()
            }
            .onAppear {
                announceToast(toast)
            }
    }
    
    @ViewBuilder
    private func stackedToastsView(geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(Array(toastManager.toastQueue.enumerated().reversed()), id: \.element.id) { index, toast in
                stackedToastView(toast: toast, index: index, totalCount: toastManager.toastQueue.count)
            }
        }
        .offset(
            x: calculateHorizontalOffset(for: alignment),
            y: calculateVerticalOffset(for: alignment, in: geometry.safeAreaInsets)
        )
    }
    
    @ViewBuilder
    private func stackedToastView(toast: ToastData, index: Int, totalCount: Int) -> some View {
        SwipeableToastCard(
            toast: toast,
            index: index,
            totalCount: totalCount,
            onDismiss: { toastManager.dismiss(toast: toast) }
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Toast \(totalCount - index) of \(totalCount): \(toast.message)")
        .accessibilityHint("Swipe or double tap to dismiss this toast")
        .accessibilityAction(named: "Dismiss") {
            toastManager.dismiss(toast: toast)
        }
        .onAppear {
            if index == totalCount - 1 {
                announceToast(toast)
            }
        }
    }
    
    private func announceToast(_ toast: ToastData) {
        #if canImport(UIKit)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let announcement = "\(toast.type.accessibilityLabel). \(toast.message)"
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
        #endif
    }
    
    private func stackingEdge(for alignment: Alignment) -> Edge {
        switch alignment {
        case .top, .topLeading, .topTrailing:
            return .top
        case .bottom, .bottomLeading, .bottomTrailing:
            return .bottom
        case .leading, .leadingFirstTextBaseline, .leadingLastTextBaseline:
            return .leading
        case .trailing, .trailingFirstTextBaseline, .trailingLastTextBaseline:
            return .trailing
        default:
            return .top
        }
    }

    internal func toastTransition(for alignment: Alignment) -> AnyTransition {
        switch alignment {
        case .top, .topLeading, .topTrailing:
            return .move(edge: .top).combined(with: .opacity)
        case .bottom, .bottomLeading, .bottomTrailing:
            return .move(edge: .bottom).combined(with: .opacity)
        case .leading, .leadingFirstTextBaseline, .leadingLastTextBaseline:
            return .move(edge: .leading).combined(with: .opacity)
        case .trailing, .trailingFirstTextBaseline, .trailingLastTextBaseline:
            return .move(edge: .trailing).combined(with: .opacity)
        default:
            return .opacity.combined(with: .scale(scale: 0.9))
        }
    }

    internal func calculateHorizontalOffset(for alignment: Alignment) -> CGFloat {
        return 0
    }

    internal func calculateVerticalOffset(for alignment: Alignment, in safeAreaInsets: EdgeInsets) -> CGFloat {
        switch alignment {
        case .top, .topLeading, .topTrailing:
            return safeAreaInsets.top + 8
        case .bottom, .bottomLeading, .bottomTrailing:
            return -safeAreaInsets.bottom - 8
        default:
            return 0
        }
    }
}

private struct SwipeableToastCard: View {
    let toast: ToastData
    let index: Int
    let totalCount: Int
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    private var cardOffset: CGFloat {
        let baseOffset = CGFloat(index) * -8
        return baseOffset + dragOffset.height
    }
    
    private var cardScale: CGFloat {
        let baseScale = 1.0 - CGFloat(index) * 0.03
        let dragScale = isDragging ? 1.02 : 1.0
        return baseScale * dragScale
    }
    
    private var cardOpacity: Double {
        let baseOpacity = 1.0 - Double(index) * 0.15
        let dragOpacity = 1.0 - Double(abs(dragOffset.height) / 200)
        return max(0.3, min(1.0, baseOpacity * dragOpacity))
    }
    
    private var cardRotation: Double {
        return Double(dragOffset.width / 20)
    }
    
    var body: some View {
        ToastView(toast: toast)
            .scaleEffect(cardScale)
            .opacity(cardOpacity)
            .rotationEffect(.degrees(cardRotation))
            .offset(y: cardOffset)
            .zIndex(Double(totalCount - index))
            .shadow(
                color: .black.opacity(0.1),
                radius: isDragging ? 8 : 4,
                x: 0,
                y: isDragging ? 4 : 2
            )
            .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: isDragging)
            .animation(.interpolatingSpring(stiffness: 300, damping: 30), value: dragOffset)
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                removal: .move(edge: .trailing).combined(with: .opacity).combined(with: .scale(scale: 0.7))
            ))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                        }
                        dragOffset = value.translation
                    }
                    .onEnded { value in
                        isDragging = false
                        
                        let dismissThreshold: CGFloat = 80
                        let velocity = value.predictedEndLocation.y - value.location.y
                        
                        if abs(dragOffset.height) > dismissThreshold || abs(velocity) > 300 {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dragOffset = CGSize(
                                    width: dragOffset.width * 2,
                                    height: dragOffset.height > 0 ? 200 : -200
                                )
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDismiss()
                            }
                        } else {
                            withAnimation(.interpolatingSpring(stiffness: 400, damping: 25)) {
                                dragOffset = .zero
                            }
                        }
                    }
            )
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    dragOffset = CGSize(width: 0, height: -100)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    onDismiss()
                }
            }
    }
}
