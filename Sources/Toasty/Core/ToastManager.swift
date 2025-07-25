import Combine
import SwiftUI

/// Configuration for toast queueing behavior
public enum ToastQueueMode {
    case replace  // Replace current toast with new one (default behavior)
    case queue    // Queue toasts and show them sequentially
}

/// Manages the state and presentation of toast messages.
@MainActor  // Ensure all updates happen on the main thread
public class ToastManager: ObservableObject {

    /// The currently active toast data. nil means no toast is shown.
    @Published public private(set) var currentToast: ToastData? = nil
    
    /// The queue mode for handling multiple toasts
    @Published public var queueMode: ToastQueueMode = .replace

    private var dismissalTask: Task<Void, Never>?  // Task to handle auto-dismissal
    private var currentToastId: UUID?  // Track the ID of the currently active toast
    @Published public private(set) var toastQueue: [ToastData] = []  // Queue for pending toasts (now published for automatic updates)
    
    /// Current queue count (computed property to avoid unnecessary @Published updates)
    public var queueCount: Int {
        toastQueue.count
    }

    // MARK: - Show Methods

    /// Shows a new toast message using a `ToastData` object.
    ///
    /// Behavior depends on the queueMode:
    /// - .replace: If a toast is already being displayed, it will be replaced by the new one
    /// - .queue: If a toast is already being displayed, the new toast will be queued
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
        
        switch queueMode {
        case .replace:
            showImmediately(toast: toast)
        case .queue:
            // In queue mode, add to queue and show stacked
            toastQueue.append(toast)
            
            // Set up auto-dismissal for this specific toast
            setupAutoDismissal(for: toast)
        }
    }
    
    /// Shows a toast immediately, cancelling any current toast
    private func showImmediately(toast: ToastData) {
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
                self.dismissAndShowNext()
            }
        }
    }
    
    /// Sets up auto-dismissal for a specific toast in queue mode
    private func setupAutoDismissal(for toast: ToastData) {
        let toastId = toast.id
        Task {
            // Wait for the specified duration
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            
            // Check if the task was cancelled
            guard !Task.isCancelled else { return }
            
            // Remove this specific toast from the queue
            await MainActor.run {
                self.toastQueue.removeAll { $0.id == toastId }
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

    // MARK: - Dismiss Methods

    /// Dismisses the currently shown toast immediately.
    public func dismiss() {
        dismissAndShowNext()
    }
    
    /// Dismisses a specific toast from the queue
    public func dismiss(toast: ToastData) {
        // If it's the current toast, dismiss it normally
        if currentToast?.id == toast.id {
            dismiss()
            return
        }
        
        // Otherwise, remove it from the queue
        toastQueue.removeAll { $0.id == toast.id }
    }
    
    /// Internal method to dismiss current toast and show next in queue
    private func dismissAndShowNext() {
        // Cancel the dismissal task if it's running
        dismissalTask?.cancel()
        dismissalTask = nil  // Clear the task reference

        if queueMode == .replace {
            // In replace mode, clear current toast and show next from queue
            currentToast = nil
            currentToastId = nil
            
            // Show next toast in queue if available
            if !toastQueue.isEmpty {
                let nextToast = toastQueue.removeFirst()
                
                // Small delay to allow smooth transition
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                    showImmediately(toast: nextToast)
                }
            }
        } else {
            // In queue mode, just remove the first toast from the queue
            // The stacked view will automatically update to show remaining toasts
            if !toastQueue.isEmpty {
                toastQueue.removeFirst()
            }
        }
    }
    
    // MARK: - Queue Management
    
    /// Clears all queued toasts
    public func clearQueue() {
        toastQueue.removeAll()
    }
    
    /// Returns the current queue as an array of ToastData
    public var queue: [ToastData] {
        toastQueue
    }
    
    /// Dismisses current toast and clears the entire queue
    public func dismissAll() {
        clearQueue()
        dismiss()
    }
    
    // MARK: - Lifecycle
    
    /// Clean up resources when the manager is deallocated
    deinit {
        dismissalTask?.cancel()
    }
    
    // MARK: - Public State
    
    /// Returns true if a toast is currently being displayed
    public var isShowingToast: Bool {
        if queueMode == .queue {
            return !toastQueue.isEmpty
        } else {
            return currentToast != nil
        }
    }
    
    /// Returns true if there are toasts in the queue
    public var hasQueuedToasts: Bool {
        !toastQueue.isEmpty
    }
    
    // MARK: - Convenience Methods
    
    /// Enable toast queueing (toasts will be shown sequentially)
    public func enableQueueing() {
        queueMode = .queue
    }
    
    /// Disable toast queueing (new toasts will replace current toast)
    public func disableQueueing() {
        queueMode = .replace
        // Optionally clear queue when switching to replace mode
        clearQueue()
    }
}
