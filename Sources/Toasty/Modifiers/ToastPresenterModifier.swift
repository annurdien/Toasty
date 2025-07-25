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
                // Only create the toast if there's one to show
                Group {
                    if let currentToast = toastManager.currentToast {
                        // Use GeometryReader only to get safe area insets, not for positioning
                        GeometryReader { geometry in
                            Color.clear
                                .overlay(
                                    ToastView(toast: currentToast)
                                        .transition(toastTransition(for: alignment))
                                        .offset(
                                            x: calculateHorizontalOffset(for: alignment),
                                            y: calculateVerticalOffset(for: alignment, in: geometry.safeAreaInsets)
                                        )
                                        .zIndex(1)  // Ensure toast is on top
                                        .id(currentToast.id)  // Use ID for explicit animation identity
                                        .onTapGesture {  // Allow tapping to dismiss
                                            toastManager.dismiss()
                                        }
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel("Toast notification: \(currentToast.message)")
                                        .accessibilityHint("Double tap to dismiss")
                                        .accessibilityAction(named: "Dismiss") {
                                            toastManager.dismiss()
                                        }
                                        .onAppear {
                                            // Announce toast appearance for VoiceOver users
                                            #if canImport(UIKit)
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                let announcement = "\(currentToast.type.accessibilityLabel). \(currentToast.message)"
                                                UIAccessibility.post(notification: .announcement, argument: announcement)
                                            }
                                            #endif
                                        },
                                    alignment: alignment
                                )
                        }
                        .allowsHitTesting(true)
                    }
                }
                .animation(configuration.showAnimation, value: toastManager.currentToast?.id)
            )
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
