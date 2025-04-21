<p align="center">
    <img src="docs/toasty-icon.png" alt="Toasty Logo" width="200">
</p>

<h1 align="center">Toasty</h1>

<p align="center">
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/Swift-5.5+-orange.svg" alt="Swift 5.5+">
    </a>
    <a href="https://developer.apple.com/ios/">
        <img src="https://img.shields.io/badge/iOS-15.0+-blue.svg" alt="iOS 15.0+">
    </a>
    <a href="https://developer.apple.com/macos/">
        <img src="https://img.shields.io/badge/macOS-12.0+-blue.svg" alt="macOS 12.0+">
    </a>
    <a href="https://github.com/yourusername/Toasty/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT">
    </a>
</p>

<p align="center">
    A lightweight, customizable toast notification library for SwiftUI applications, 
    designed to provide elegant and user-friendly toast with minimal setup.
</p>

<p align="center">
    <img src="docs/toasty-demo.gif" alt="Toasty Demo" height="500">
</p>

## ✨ Features

- 🎯 Simple and intuitive API
- 🎨 Four built-in toast types (info, success, warning, error)
- ⚡️ Smooth animations and transitions
- 🔄 Auto-dismissal with customizable duration
- 👆 Tap to dismiss
- ♿️ Accessibility support
- 📱 Safe area aware
- 🎭 Flexible positioning (top, bottom)

## 📦 Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/Toasty.git", from: "0.1.10")
]
```

## 🚀 Usage

### Basic Setup

1. Add the `.toastable()` modifier to your root view:

```swift
import Toasty

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .toastable() // Add this modifier
        }
    }
}
```

### Show Toasts

You can use the `@Toast` property wrapper (recommended) or `@EnvironmentObject`:

```swift
struct ContentView: View {
    @Toast private var toast
    
    var body: some View {
        Button("Show Toast") {
            // Simple usage
            toast.show(message: "Hello, World!")
            
            // With type and duration
            toast.show(
                message: "Operation successful!",
                type: .success,
                duration: 3.0
            )
            
            // Using ToastData
            let customToast = ToastData(
                message: "Custom toast",
                type: .warning,
                duration: 2.0
            )
            toast.show(toast: customToast)
        }
    }
}
```

### Toast Types

- `.info` - For general information
- `.success` - For successful operations
- `.warning` - For warning messages
- `.error` - For error messages

### Customization

Adjust toast position using the alignment parameter:

```swift
ContentView()
    .toastable(alignment: .bottom) // Show toasts at the bottom
```

## ⚙️ Requirements

- iOS 15.0+
- macOS 12.0+
- Xcode 15.0+
- Swift 5.5+

## 👥 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Annurdien Rasyid**
- GitHub: [@annurdien](https://github.com/annurdien)
- LinkedIn: [Annurdien Rasyid](https://www.linkedin.com/in/annurdien)
---

<p align="center">
    Made with ❤️ by <a href="https://github.com/annurdien">Annurdien Rasyid</a>
</p>