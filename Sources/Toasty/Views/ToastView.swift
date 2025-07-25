import SwiftUI

struct ToastView: View {
    let toast: ToastData
    @Environment(\.toastConfiguration) private var configuration

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: toast.type.systemImageName)
                .foregroundColor(toast.type.foregroundColor)
                .font(configuration.iconFont)

            Text(toast.message)
                .font(configuration.messageFont)
                .foregroundColor(toast.type.foregroundColor)
                .lineLimit(configuration.maxLines)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(.vertical, configuration.verticalPadding)
        .padding(.horizontal, configuration.horizontalPadding)
        .background(toast.type.backgroundColor)
        .cornerRadius(configuration.cornerRadius)
        .shadow(
            color: configuration.shadowColor, 
            radius: configuration.shadowRadius, 
            x: configuration.shadowOffset.width, 
            y: configuration.shadowOffset.height
        )
        .padding(.horizontal, configuration.outerHorizontalPadding)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(toast.type.accessibilityLabel): \(toast.message)")
        .accessibilityAddTraits(.isButton)
    }
}

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
        .previewLayout(.sizeThatFits)
    }
}
