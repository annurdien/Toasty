import Testing
import SwiftUI
@testable import Toasty

@MainActor
struct ToastyTests {
    
    @Test func toastDataValidation() async throws {
        // Test normal case
        let normalToast = ToastData(message: "Test message", type: .info, duration: 3.0)
        #expect(normalToast.message == "Test message")
        #expect(normalToast.type == .info)
        #expect(normalToast.duration == 3.0)
        
        // Test duration bounds
        let shortToast = ToastData(message: "Short", type: .info, duration: 0.1)
        #expect(shortToast.duration == 0.5) // Should be clamped to minimum
        
        let longToast = ToastData(message: "Long", type: .info, duration: 15.0)
        #expect(longToast.duration == 10.0) // Should be clamped to maximum
    }
    
    @Test func toastManagerShowAndDismiss() async throws {
        let manager = ToastManager()
        
        // Initially no toast
        #expect(manager.currentToast == nil)
        #expect(manager.isShowingToast == false)
        
        // Show a toast
        let toast = ToastData(message: "Test", type: .success, duration: 1.0)
        manager.show(toast: toast)
        
        // Toast should be shown
        #expect(manager.currentToast != nil)
        #expect(manager.isShowingToast == true)
        #expect(manager.currentToast?.message == "Test")
        
        // Dismiss toast
        manager.dismiss()
        #expect(manager.currentToast == nil)
        #expect(manager.isShowingToast == false)
    }
    
    @Test func toastManagerEmptyMessage() async throws {
        let manager = ToastManager()
        
        // Try to show empty message
        manager.show(message: "", type: .info)
        #expect(manager.currentToast == nil) // Should not show
        
        // Try to show whitespace only
        manager.show(message: "   ", type: .info)
        #expect(manager.currentToast == nil) // Should not show
    }
    
    @Test func toastManagerConvenienceMethod() async throws {
        let manager = ToastManager()
        
        manager.show(message: "Convenience test", type: .warning, duration: 2.0)
        
        #expect(manager.currentToast?.message == "Convenience test")
        #expect(manager.currentToast?.type == .warning)
        #expect(manager.currentToast?.duration == 2.0)
    }
    
    @Test func toastTypeProperties() async throws {
        // Test all toast types have required properties
        let types: [ToastType] = [.info, .success, .warning, .error]
        
        for type in types {
            #expect(!type.systemImageName.isEmpty)
            #expect(!type.accessibilityLabel.isEmpty)
        }
        
        // Test specific values
        #expect(ToastType.info.systemImageName == "info.circle.fill")
        #expect(ToastType.success.systemImageName == "checkmark.circle.fill")
        #expect(ToastType.warning.systemImageName == "exclamationmark.triangle.fill")
        #expect(ToastType.error.systemImageName == "xmark.octagon.fill")
        
        #expect(ToastType.info.accessibilityLabel == "Information")
        #expect(ToastType.success.accessibilityLabel == "Success")
        #expect(ToastType.warning.accessibilityLabel == "Warning")
        #expect(ToastType.error.accessibilityLabel == "Error")
    }
    
    @Test func toastDataEquality() async throws {
        let toast1 = ToastData(message: "Same message", type: .info)
        let toast2 = ToastData(message: "Same message", type: .info)
        
        // Different instances with same content should not be equal (due to UUID)
        #expect(toast1 != toast2)
        
        // Same instance should be equal to itself
        #expect(toast1 == toast1)
    }
    
    @Test func toastManagerRapidCalls() async throws {
        let manager = ToastManager()
        
        // Show multiple toasts rapidly
        manager.show(message: "First", type: .info)
        let firstToastId = manager.currentToast?.id
        
        manager.show(message: "Second", type: .success)
        let secondToastId = manager.currentToast?.id
        
        // Should show the latest toast
        #expect(manager.currentToast?.message == "Second")
        #expect(firstToastId != secondToastId)
    }
    
    @Test func toastManagerQueueMode() async throws {
        let manager = ToastManager()
        manager.queueMode = .queue
        
        // Initial state
        #expect(manager.queueCount == 0)
        #expect(manager.hasQueuedToasts == false)
        #expect(manager.isShowingToast == false)
        
        // Show first toast - in stacked mode, goes directly to queue
        manager.show(message: "First", type: .info)
        #expect(manager.currentToast == nil) // No current toast in stacked mode
        #expect(manager.queueCount == 1)
        #expect(manager.hasQueuedToasts == true)
        #expect(manager.isShowingToast == true) // Should show stacked toasts
        
        // Show second toast - should be added to queue
        manager.show(message: "Second", type: .success)
        #expect(manager.queueCount == 2)
        #expect(manager.hasQueuedToasts == true)
        #expect(manager.isShowingToast == true)
        
        // Show third toast - should also be added to queue
        manager.show(message: "Third", type: .warning)
        #expect(manager.queueCount == 3)
        #expect(manager.hasQueuedToasts == true)
        #expect(manager.isShowingToast == true)
        
        // Dismiss first toast from stack
        manager.dismiss()
        #expect(manager.queueCount == 2) // Queue should be reduced
        #expect(manager.hasQueuedToasts == true)
        #expect(manager.isShowingToast == true)
        
        // Dismiss again
        manager.dismiss()
        #expect(manager.queueCount == 1)
        #expect(manager.hasQueuedToasts == true)
        #expect(manager.isShowingToast == true)
        
        // Final dismiss
        manager.dismiss()
        #expect(manager.queueCount == 0)
        #expect(manager.hasQueuedToasts == false)
        #expect(manager.isShowingToast == false)
    }
    
    @Test func toastManagerReplaceMode() async throws {
        let manager = ToastManager()
        manager.queueMode = .replace
        
        // Show first toast
        manager.show(message: "First", type: .info)
        #expect(manager.currentToast?.message == "First")
        #expect(manager.queueCount == 0)
        
        // Show second toast - should replace first
        manager.show(message: "Second", type: .success)
        #expect(manager.currentToast?.message == "Second")
        #expect(manager.queueCount == 0)
        #expect(manager.hasQueuedToasts == false)
    }
    
    @Test func toastManagerClearQueue() async throws {
        let manager = ToastManager()
        manager.queueMode = .queue
        
        // Add multiple toasts - in stacked mode, all go to queue
        manager.show(message: "First", type: .info)
        manager.show(message: "Second", type: .success)
        manager.show(message: "Third", type: .warning)
        
        #expect(manager.queueCount == 3)
        #expect(manager.hasQueuedToasts == true)
        #expect(manager.isShowingToast == true)
        
        // Clear queue
        manager.clearQueue()
        #expect(manager.queueCount == 0)
        #expect(manager.hasQueuedToasts == false)
        #expect(manager.isShowingToast == false) // No toasts showing in stacked mode
    }
    
    @Test func toastManagerDismissAll() async throws {
        let manager = ToastManager()
        manager.queueMode = .queue
        
        // Add multiple toasts - in stacked mode, all go to queue
        manager.show(message: "First", type: .info)
        manager.show(message: "Second", type: .success)
        manager.show(message: "Third", type: .warning)
        
        #expect(manager.isShowingToast == true)
        #expect(manager.queueCount == 3)
        #expect(manager.hasQueuedToasts == true)
        
        // Dismiss all
        manager.dismissAll()
        #expect(manager.isShowingToast == false)
        #expect(manager.currentToast == nil)
        #expect(manager.queueCount == 0)
        #expect(manager.hasQueuedToasts == false)
    }
    
    @Test func toastPresenterModifierAlignment() async throws {
        // Test that all alignment cases are handled without crashing
        let alignments: [Alignment] = [
            .top, .topLeading, .topTrailing,
            .center, .leading, .trailing,
            .bottom, .bottomLeading, .bottomTrailing
        ]
        
        for alignment in alignments {
            let modifier = ToastPresenterModifier(toastManager: ToastManager(), alignment: alignment)
            
            // Test that transition calculation doesn't crash
            let transition = modifier.toastTransition(for: alignment)
            // Just verify we can call the method without crashing
            _ = transition
            
            // Test that offset calculation doesn't crash
            let safeArea = EdgeInsets(top: 44, leading: 0, bottom: 34, trailing: 0)
            let verticalOffset = modifier.calculateVerticalOffset(for: alignment, in: safeArea)
            let horizontalOffset = modifier.calculateHorizontalOffset(for: alignment)
            
            // Verify offsets are reasonable
            #expect(abs(verticalOffset) <= 100) // Should be reasonable offset
            #expect(abs(horizontalOffset) <= 100) // Should be reasonable offset
        }
    }
}
