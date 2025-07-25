import SwiftUI

public enum ToastType {
    case info
    case success
    case warning
    case error

    var systemImageName: String {
        switch self {
        case .info: return "info.circle.fill"
        case .success: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .error: return "xmark.octagon.fill"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .info: return Color.blue
        case .success: return Color.green
        case .warning: return Color.orange
        case .error: return Color.red
        }
    }

    var foregroundColor: Color {
        return Color.white
    }
    
    var accessibilityLabel: String {
        switch self {
        case .info: return "Information"
        case .success: return "Success"
        case .warning: return "Warning"
        case .error: return "Error"
        }
    }
}

public struct ToastData: Equatable {
    let id = UUID()
    var message: String
    var type: ToastType
    var duration: TimeInterval

    public init(message: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
        self.message = message
        self.type = type
        self.duration = max(0.5, min(duration, 10.0))
    }

    public static func == (lhs: ToastData, rhs: ToastData) -> Bool {
        lhs.id == rhs.id
    }
}
