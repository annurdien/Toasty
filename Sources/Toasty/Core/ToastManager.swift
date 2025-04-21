import Combine
import SwiftUI

/// Manages the state and presentation of toast messages.
@MainActor  // Ensure all updates happen on the main thread
public class ToastManager: ObservableObject {

    /// The currently active toast data. nil means no toast is shown.
    @Published public private(set) var currentToast: ToastData? = nil

    private var dismissalTask: Task<Void, Never>?  // Task to handle auto-dismissal

    // MARK: - Show Methods

    /// Shows a new toast message using a `ToastData` object.
    ///
    /// If a toast is already being displayed, it will be replaced by the new one.
    /// The dismissal timer for the previous toast (if any) will be cancelled.
    ///
    /// - Parameter toast: The `ToastData` object containing the details of the toast to show.
    public func show(toast: ToastData) {
        // Cancel any existing dismissal task before showing a new toast
        dismissalTask?.cancel()

        // Set the new toast with animation
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)) {
            currentToast = toast
        }

        // Schedule dismissal
        dismissalTask = Task {
            // Wait for the specified duration
            // Use UInt64 for nanoseconds conversion
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))

            // Check if the task was cancelled before proceeding
            guard !Task.isCancelled else { return }

            // Ensure we are still showing the *same* toast before dismissing
            // This prevents dismissing a newer toast if show() was called again quickly.
            if self.currentToast == toast {
                // Use MainActor.run to ensure UI updates happen on the main thread
                await MainActor.run {
                    self.dismiss()
                }
            }
        }
    }

    /// Convenience method to show a new toast message with individual parameters.
    ///
    /// This method creates a `ToastData` object internally and calls the primary `show(toast:)` method.
    ///
    /// - Parameters:
    ///   - message: The text message to display in the toast.
    ///   - type: The style of the toast (e.g., `.info`, `.success`). Defaults to `.info`.
    ///   - duration: How long the toast should remain visible, in seconds. Defaults to `3.0`.
    public func show(message: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
        // Create the ToastData object from the parameters
        let toast = ToastData(message: message, type: type, duration: duration)
        // Call the main show method
        show(toast: toast)
    }

    // MARK: - Dismiss Method

    /// Dismisses the currently shown toast immediately.
    public func dismiss() {
        // Cancel the dismissal task if it's running
        dismissalTask?.cancel()
        dismissalTask = nil  // Clear the task reference

        // Remove the current toast with animation
        withAnimation(.easeInOut(duration: 0.2)) {  // Add a fade-out animation
            currentToast = nil
        }
    }
}
