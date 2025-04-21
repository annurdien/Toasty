import SwiftUI

/// A view modifier that observes a `ToastManager` and presents a `ToastView`
/// when a toast is available. (Consider making this `internal` if not needed publicly)
struct ToastPresenterModifier: ViewModifier {
    /// Use @ObservedObject for modifiers if the object is created outside.
    /// If the modifier *creates* the object, use @StateObject.
    /// Here, the object is created by the .toastable() extension and passed in.
    @ObservedObject var toastManager: ToastManager
    let alignment: Alignment  // Where the toast should appear

    init(toastManager: ToastManager, alignment: Alignment = .top) {
        self.toastManager = toastManager
        self.alignment = alignment
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                // Only create the ZStack and ToastView if there's a toast to show
                ZStack(alignment: alignment) {
                    // GeometryReader helps position correctly within the overlay
                    GeometryReader { geometry in
                        // Use optional binding to safely unwrap the toast
                        if let currentToast = toastManager.currentToast {
                            // Ensure ToastView is accessible (it's likely internal or public)
                            ToastView(toast: currentToast)
                                .transition(toastTransition(for: alignment))  // Apply transition
                                .offset(
                                    y: calculateOffset(for: alignment, in: geometry.safeAreaInsets)
                                )  // Adjust position based on safe area
                                .zIndex(1)  // Ensure toast is on top
                                .id(currentToast.id)  // Use ID for explicit animation identity
                                .onTapGesture {  // Allow tapping to dismiss
                                    // Ensure dismissal happens on the main thread via the manager's method
                                    toastManager.dismiss()
                                }
                                .accessibilityLabel("Toast message: \(currentToast.message)")  // Accessibility
                                .accessibilityHint("Tap to dismiss")
                        } else {
                            // EmptyView ensures the ZStack exists even when no toast is shown,
                            // preventing potential layout shifts when the toast appears/disappears.
                            EmptyView()
                        }
                    }
                }
                // Apply animation to the overlay container for smooth appearance/disappearance
                // Using the toast's ID as the value ensures animation triggers correctly even if
                // message/type changes but the toast object itself remains (though current implementation replaces it).
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0),
                    value: toastManager.currentToast?.id)
            )
    }

    /// Determines the appropriate transition based on the alignment.
    private func toastTransition(for alignment: Alignment) -> AnyTransition {
        switch alignment {
        case .top, .topLeading, .topTrailing:
            return .move(edge: .top).combined(with: .opacity)
        case .bottom, .bottomLeading, .bottomTrailing:
            return .move(edge: .bottom).combined(with: .opacity)
        default:  // Center, leading, trailing
            return .opacity.combined(with: .scale(scale: 0.9))
        }
    }

    /// Calculates the vertical offset to account for safe areas.
    private func calculateOffset(for alignment: Alignment, in safeAreaInsets: EdgeInsets) -> CGFloat
    {
        switch alignment {
        case .top, .topLeading, .topTrailing:
            // Add a small extra padding below the top safe area
            return safeAreaInsets.top + 8
        case .bottom, .bottomLeading, .bottomTrailing:
            // Add a small extra padding above the bottom safe area
            return -safeAreaInsets.bottom - 8
        default:
            return 0  // No offset needed for center alignments
        }
    }
}
