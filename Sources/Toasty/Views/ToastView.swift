import SwiftUI

/// The visual representation of a toast message.
struct ToastView: View {
    let toast: ToastData

    var body: some View {
        HStack(spacing: 10) {
            // Icon
            Image(systemName: toast.type.systemImageName)
                .foregroundColor(toast.type.foregroundColor)
                .font(.system(size: 20, weight: .semibold))  // Slightly larger icon

            // Message Text
            Text(toast.message)
                .font(.system(size: 14, weight: .medium))  // Clear font size
                .foregroundColor(toast.type.foregroundColor)
                .lineLimit(3)  // Allow up to 3 lines for longer messages
                .multilineTextAlignment(.leading)  // Align text to the leading edge

            Spacer()  // Push content to the left
        }
        .padding(.vertical, 12)  // More vertical padding
        .padding(.horizontal, 16)  // Standard horizontal padding
        .background(toast.type.backgroundColor)
        .cornerRadius(10)  // Rounded corners
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)  // Subtle shadow
        .padding(.horizontal)  // Add padding around the toast itself
    }
}

// Optional: Preview for ToastView
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ToastView(toast: ToastData(message: "Informational message here.", type: .info))
            ToastView(toast: ToastData(message: "Success! Operation completed.", type: .success))
            ToastView(
                toast: ToastData(message: "Warning: Please check your input.", type: .warning))
            ToastView(
                toast: ToastData(
                    message:
                        "Error: Failed to load data. A slightly longer message to test wrapping.",
                    type: .error))
        }
        .padding()
        .previewLayout(.sizeThatFits)  // Adjust preview layout
    }
}
