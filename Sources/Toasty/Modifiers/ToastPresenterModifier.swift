 import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// A view modifier that observes a `ToastManager` and presents a `ToastView`
/// when a toast is available.
internal struct ToastPresenterModifier: ViewModifier {
    /// Use @ObservedObject for modifiers if the object is created outside.
    /// If the modifier *creates* the object, use @StateObject.
    /// Here, the object is created by the .toastable() extension and passed in.
    @ObservedObject var toastManager: ToastManager
    @Environment(\.toastConfiguration) private var configuration
    let alignment: Alignment  // Where the toast should appear

    init(toastManager: ToastManager, alignment: Alignment = .top) {
        self.toastManager = toastManager
        self.alignment = alignment
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                // Show stacked toasts when in queue mode, or single toast in replace mode
                Group {
                    if toastManager.queueMode == .queue && !toastManager.toastQueue.isEmpty {
                        // Stacked mode: show all toasts in a stacked arrangement
                        GeometryReader { geometry in
                            Color.clear
                                .overlay(
                                    stackedToastsView(geometry: geometry),
                                    alignment: alignment
                                )
                        }
                        .allowsHitTesting(true)
                    } else if let currentToast = toastManager.currentToast {
                        // Single mode: show only current toast (replace mode or single toast in queue)
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
    
    /// Creates a view for a single toast (used in replace mode or when only one toast exists)
    @ViewBuilder
    private func singleToastView(toast: ToastData, geometry: GeometryProxy) -> some View {
        ToastView(toast: toast)
            .transition(toastTransition(for: alignment))
            .offset(
                x: calculateHorizontalOffset(for: alignment),
                y: calculateVerticalOffset(for: alignment, in: geometry.safeAreaInsets)
            )
            .zIndex(1)  // Ensure toast is on top
            .id(toast.id)  // Use ID for explicit animation identity
            .onTapGesture {  // Allow tapping to dismiss
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
    
    /// Creates a stacked view of all toasts in the queue
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
    
    /// Creates a single toast view for the stacked display
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
            if index == totalCount - 1 { // Only announce the topmost (newest) toast
                announceToast(toast)
            }
        }
    }
    
    /// Announces a toast for accessibility
    private func announceToast(_ toast: ToastData) {
        #if canImport(UIKit)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let announcement = "\(toast.type.accessibilityLabel). \(toast.message)"
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
        #endif
    }
    
    /// Determines the edge from which new toasts should appear when stacking
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

    /// Determines the appropriate transition based on the alignment.
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
        default:  // Center and other alignments
            return .opacity.combined(with: .scale(scale: 0.9))
        }
    }

    /// Calculates the horizontal offset for positioning.
    internal func calculateHorizontalOffset(for alignment: Alignment) -> CGFloat {
        // Most alignments don't need horizontal offset as they're handled by the overlay alignment
        // Only add offsets if we need to fine-tune positioning
        return 0
    }

    /// Calculates the vertical offset to account for safe areas.
    internal func calculateVerticalOffset(for alignment: Alignment, in safeAreaInsets: EdgeInsets) -> CGFloat {
        switch alignment {
        case .top, .topLeading, .topTrailing:
            // Add padding below the top safe area
            return safeAreaInsets.top + 8
        case .bottom, .bottomLeading, .bottomTrailing:
            // Add padding above the bottom safe area
            return -safeAreaInsets.bottom - 8
        default:
            // Center, leading, trailing don't need safe area adjustments
            return 0
        }
    }
}

/// A swipeable toast card that can be dismissed with gestures
private struct SwipeableToastCard: View {
    let toast: ToastData
    let index: Int
    let totalCount: Int
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging: Bool = false
    
    private var cardOffset: CGFloat {
        let baseOffset = CGFloat(index) * -8 // Stack cards behind each other
        return baseOffset + dragOffset.height
    }
    
    private var cardScale: CGFloat {
        let baseScale = 1.0 - CGFloat(index) * 0.03 // Subtle scale reduction
        let dragScale = isDragging ? 1.02 : 1.0 // Slight scale up when dragging
        return baseScale * dragScale
    }
    
    private var cardOpacity: Double {
        let baseOpacity = 1.0 - Double(index) * 0.15 // Fade cards behind
        let dragOpacity = 1.0 - Double(abs(dragOffset.height) / 200) // Fade when dragging away
        return max(0.3, min(1.0, baseOpacity * dragOpacity))
    }
    
    private var cardRotation: Double {
        // Slight rotation based on horizontal drag
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
                        
                        // Determine if the card should be dismissed
                        let dismissThreshold: CGFloat = 80
                        let velocity = value.predictedEndLocation.y - value.location.y
                        
                        if abs(dragOffset.height) > dismissThreshold || abs(velocity) > 300 {
                            // Animate the card away before dismissing
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dragOffset = CGSize(
                                    width: dragOffset.width * 2,
                                    height: dragOffset.height > 0 ? 200 : -200
                                )
                            }
                            
                            // Dismiss after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDismiss()
                            }
                        } else {
                            // Spring back to original position
                            withAnimation(.interpolatingSpring(stiffness: 400, damping: 25)) {
                                dragOffset = .zero
                            }
                        }
                    }
            )
            .onTapGesture {
                // Simple tap to dismiss
                withAnimation(.easeInOut(duration: 0.25)) {
                    dragOffset = CGSize(width: 0, height: -100)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    onDismiss()
                }
            }
    }
}
