import SwiftUI

/// Configuration object for customizing toast appearance and behavior
public struct ToastConfiguration {
    /// The corner radius of the toast
    public var cornerRadius: CGFloat = 10
    
    /// The shadow configuration
    public var shadowColor: Color = Color.black.opacity(0.15)
    public var shadowRadius: CGFloat = 5
    public var shadowOffset: CGSize = CGSize(width: 0, height: 2)
    
    /// Padding around the toast content
    public var verticalPadding: CGFloat = 12
    public var horizontalPadding: CGFloat = 16
    public var outerHorizontalPadding: CGFloat = 16
    
    /// Font configuration
    public var messageFont: Font = .system(size: 14, weight: .medium)
    public var iconFont: Font = .system(size: 20, weight: .semibold)
    
    /// Animation configuration
    public var showAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.7, blendDuration: 0)
    public var dismissAnimation: Animation = .easeInOut(duration: 0.2)
    
    /// Maximum number of lines for message text
    public var maxLines: Int = 3
    
    /// Default configuration
    public static let `default` = ToastConfiguration()
    
    public init() {}
}

/// Environment key for toast configuration
private struct ToastConfigurationKey: EnvironmentKey {
    static let defaultValue = ToastConfiguration.default
}

extension EnvironmentValues {
    public var toastConfiguration: ToastConfiguration {
        get { self[ToastConfigurationKey.self] }
        set { self[ToastConfigurationKey.self] = newValue }
    }
}

extension View {
    /// Apply a custom toast configuration to this view and its children
    public func toastConfiguration(_ configuration: ToastConfiguration) -> some View {
        environment(\.toastConfiguration, configuration)
    }
}
