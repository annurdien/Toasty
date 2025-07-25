import SwiftUI

/// Extension to add the toast presentation capability to any SwiftUI View.
extension View {
    /// Makes the view capable of presenting toasts managed by an injected `ToastManager`.
    ///
    /// Apply this modifier to a root view in your hierarchy (e.g., `ContentView`, `NavigationView`, or `TabView`).
    /// Views within this hierarchy can then access the `ToastManager` via `@EnvironmentObject` or the `@Toast` property wrapper.
    ///
    /// - Parameters:
    ///   - alignment: The alignment guiding the toast's position (default is `.top`).
    ///   - manager: An optional, existing `ToastManager` instance. If `nil` (default),
    ///              a new `@StateObject` instance will be created and managed by this view.
    ///              Provide an existing manager if you need to control toasts from outside
    ///              the view hierarchy where `.toastable()` is applied.
    /// - Returns: A view modified to present toasts.
    public func toastable(
        alignment: Alignment = .top,
        manager: ToastManager? = nil
    ) -> some View {
        modifier(ToastableViewModifier(alignment: alignment, providedManager: manager))
    }
    
    /// Makes the view capable of presenting toasts with queue mode configuration.
    ///
    /// - Parameters:
    ///   - alignment: The alignment guiding the toast's position (default is `.top`).
    ///   - queueMode: The queue mode for handling multiple toasts (default is `.replace`).
    ///   - manager: An optional, existing `ToastManager` instance.
    /// - Returns: A view modified to present toasts with the specified queue mode.
    public func toastable(
        alignment: Alignment = .top,
        queueMode: ToastQueueMode = .replace,
        manager: ToastManager? = nil
    ) -> some View {
        modifier(ToastableViewModifier(
            alignment: alignment,
            providedManager: manager,
            queueMode: queueMode
        ))
    }
}

// Internal modifier to handle manager creation or injection
private struct ToastableViewModifier: ViewModifier {
    /// Creates and manages the ToastManager state if one isn't provided externally.
    @StateObject private var internalManager = ToastManager()

    /// The alignment for the toast presentation.
    let alignment: Alignment
    /// An optional externally provided manager.
    let providedManager: ToastManager?
    /// The queue mode for handling multiple toasts.
    let queueMode: ToastQueueMode

    /// Initializes the modifier, storing the alignment and any provided manager.
    init(alignment: Alignment, providedManager: ToastManager?, queueMode: ToastQueueMode = .replace) {
        self.alignment = alignment
        self.providedManager = providedManager
        self.queueMode = queueMode
        // Note: We no longer initialize managerToUse here to avoid initialization order issues.
    }

    /// Applies the necessary modifiers to the content view.
    func body(content: Content) -> some View {
        // Determine the actual manager to use (provided or internal) inside the body,
        // ensuring all properties (including @StateObject) are initialized.
        let actualManager = providedManager ?? internalManager

        content
            // Apply the presenter modifier using the determined manager.
            .modifier(ToastPresenterModifier(toastManager: actualManager, alignment: alignment))
            // Inject the determined manager into the environment for child views.
            .environmentObject(actualManager)
            // Configure the queue mode only once when the view appears
            .onAppear {
                actualManager.queueMode = queueMode
            }
    }
}
