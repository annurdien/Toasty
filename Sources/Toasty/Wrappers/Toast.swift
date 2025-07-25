import SwiftUI

@propertyWrapper
public struct Toast: DynamicProperty {
    @EnvironmentObject private var toastManager: ToastManager

    public var wrappedValue: ToastManager {
        toastManager
    }

    public init() {}
}
