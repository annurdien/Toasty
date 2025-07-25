import Combine
import SwiftUI

public enum ToastQueueMode {
    case replace
    case queue
}

@MainActor
public class ToastManager: ObservableObject {

    @Published public private(set) var currentToast: ToastData? = nil
    @Published public var queueMode: ToastQueueMode = .replace

    private var dismissalTask: Task<Void, Never>?
    private var currentToastId: UUID?
    @Published public private(set) var toastQueue: [ToastData] = []
    
    public var queueCount: Int {
        toastQueue.count
    }

    public func show(toast: ToastData) {
        guard !toast.message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        guard toast.duration > 0 else {
            return
        }
        
        switch queueMode {
        case .replace:
            showImmediately(toast: toast)
        case .queue:
            toastQueue.append(toast)
            setupAutoDismissal(for: toast)
        }
    }
    
    private func showImmediately(toast: ToastData) {
        dismissalTask?.cancel()
        dismissalTask = nil

        currentToast = toast
        currentToastId = toast.id

        let toastId = toast.id
        dismissalTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))

            guard !Task.isCancelled else { return }

            if self.currentToastId == toastId {
                self.dismissAndShowNext()
            }
        }
    }
    
    private func setupAutoDismissal(for toast: ToastData) {
        let toastId = toast.id
        Task {
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.toastQueue.removeAll { $0.id == toastId }
            }
        }
    }

    public func show(message: String, type: ToastType = .info, duration: TimeInterval = 3.0) {
        let toast = ToastData(message: message, type: type, duration: duration)
        show(toast: toast)
    }

    public func dismiss() {
        dismissAndShowNext()
    }
    
    public func dismiss(toast: ToastData) {
        if currentToast?.id == toast.id {
            dismiss()
            return
        }
        
        toastQueue.removeAll { $0.id == toast.id }
    }
    
    private func dismissAndShowNext() {
        dismissalTask?.cancel()
        dismissalTask = nil

        if queueMode == .replace {
            currentToast = nil
            currentToastId = nil
            
            if !toastQueue.isEmpty {
                let nextToast = toastQueue.removeFirst()
                
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    showImmediately(toast: nextToast)
                }
            }
        } else {
            if !toastQueue.isEmpty {
                toastQueue.removeFirst()
            }
        }
    }
    
    public func clearQueue() {
        toastQueue.removeAll()
    }
    
    public var queue: [ToastData] {
        toastQueue
    }
    
    public func dismissAll() {
        clearQueue()
        dismiss()
    }
    
    deinit {
        dismissalTask?.cancel()
    }
    
    public var isShowingToast: Bool {
        if queueMode == .queue {
            return !toastQueue.isEmpty
        } else {
            return currentToast != nil
        }
    }
    
    public var hasQueuedToasts: Bool {
        !toastQueue.isEmpty
    }
    
    public func enableQueueing() {
        queueMode = .queue
    }
    
    public func disableQueueing() {
        queueMode = .replace
    }
}
