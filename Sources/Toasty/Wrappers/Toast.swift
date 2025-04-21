import SwiftUI

/// A property wrapper to easily access the `ToastManager` from the SwiftUI environment.
///
/// This wrapper simplifies obtaining the `ToastManager` instance provided by the
/// `.toastable()` view modifier on an ancestor view. It acts as a convenient alternative
/// to using `@EnvironmentObject var toastManager: ToastManager`.
///
/// Usage:
/// ```swift
/// struct MyView: View {
///     @Toast var toast // Access the toast manager via the wrapper
///
///     var body: some View {
///         VStack {
///             Button("Show Info") {
///                 // Use the convenience overload (message only, defaults to .info, 3s)
///                 toast.show(message: "Just an informational message.")
///             }
///             Button("Show Success") {
///                 // Use the convenience overload (message and type, defaults to 3s)
///                 toast.show(message: "Operation Successful!", type: .success)
///             }
///             Button("Show Error (5s)") {
///                 // Use the convenience overload (all parameters)
///                 toast.show(message: "Something went wrong.", type: .error, duration: 5.0)
///             }
///             Button("Show Original Way") {
///                 // Still possible to use the original method with ToastData
///                 let customToast = ToastData(message: "Custom Warning", type: .warning, duration: 2.0)
///                 toast.show(toast: customToast)
///             }
///         }
///     }
/// }
/// ```
///
/// **Important:** An ancestor view *must* have the `.toastable()` modifier applied
/// for this property wrapper to function correctly. Otherwise, it will result in a runtime crash
/// when accessing the environment object, similar to using `@EnvironmentObject` incorrectly.
@propertyWrapper
public struct Toast: DynamicProperty {
    /// Accesses the ToastManager instance from the environment.
    /// This is the core mechanism that connects the wrapper to the manager
    /// set up by `.toastable()`.
    @EnvironmentObject private var toastManager: ToastManager

    /// The wrapped value provides direct access to the `ToastManager` instance
    /// found in the environment. You call methods like `.show()` directly on this value.
    public var wrappedValue: ToastManager {
        toastManager
    }

    /// Initializes the property wrapper. No parameters are needed as it relies
    /// solely on the environment.
    public init() {}

    // Note: No projected value (`$toast`) is provided in this simple implementation,
    // as direct access to the manager via `wrappedValue` is sufficient for showing toasts.
}
