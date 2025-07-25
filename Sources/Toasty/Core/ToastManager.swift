import Combine
import SwiftUI

/// Manages the state and presentation of toast messages.
@MainActor  // Ensure all updates happen on the main thread
public class ToastManager: ObservableObject {

    /// The currently active toast data. nil means no toast is shown.
    @Published public private(set) var currentToast: ToastData? = nil

    private var dismissalTask: Task<Void, Never>?  // Task to handle auto-dismissal
    private var currentToastId: UUID?  // Track the ID of the currently active toast

    // MARK: - Show Methods

    /// Shows a new toast message using a `ToastData` object.
    ///
    /// If a toast is already being displayed, it will be replaced by the new one.
    /// The dismissal timer for the previous toast (if any) will be cancelled.
    ///
    /// - Parameter toast: The `ToastData` object containing the details of the toast to show.
    public func show(toast: ToastData) {
        // Validate input
        guard !toast.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return  // Don't show empty messages
        }
        
        guard toast.duration > 0 else {
            return  // Don't show toasts with invalid duration
        }
        
        // Cancel any existing dismissal task before showing a new toast
        dismissalTask?.cancel()
        dismissalTask = nil

        // Set the new toast with animation
        currentToast = toast
        currentToastId = toast.id

        // Schedule dismissal using the tracked ID to prevent race conditions
        let toastId = toast.id
        dismissalTask = Task {
            // Wait for the specified duration
            // Use UInt64 for nanoseconds conversion
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))

            // Check if the task was cancelled before proceeding
            guard !Task.isCancelled else { return }

            // Only dismiss if this is still the same toast (prevents race conditions)
            if self.currentToastId == toastId {
                self.dismiss()
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

        // Remove the current toast without animation (animation handled by modifier)
        currentToast = nil
        currentToastId = nil
    }
    
    // MARK: - Lifecycle
    
    /// Clean up resources when the manager is deallocated
    deinit {
        dismissalTask?.cancel()
    }
    
    // MARK: - Public State
    
    /// Returns true if a toast is currently being displayed
    public var isShowingToast: Bool {
        currentToast != nil
    }
}
