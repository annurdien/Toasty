//
//  ToastyScreen.swift
//  Example
//
//  Created by Annurdien Rasyid on 22/04/25.
//

import Toasty
import SwiftUI

struct ToastyScreen: View {
  @Toast private var toast
  @Binding var toastAlignment: Alignment
  @State private var queueMode: ToastQueueMode = .replace
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Toasty Demo")
        .font(.title2)
        .fontWeight(.bold)
      
      // Queue Mode Toggle
      VStack(spacing: 10) {
        Text("Queue Mode")
          .font(.headline)
        
        Picker("Queue Mode", selection: $queueMode) {
          Text("Replace").tag(ToastQueueMode.replace)
          Text("Stack").tag(ToastQueueMode.queue)
        }
        .pickerStyle(.segmented)
        
        if queueMode == .queue {
          HStack {
            Text("Queued: \(toast.queueCount)")
              .font(.caption)
              .foregroundColor(.secondary)
            
            Spacer()
            
            if toast.hasQueuedToasts {
              Button("Clear Queue") {
                toast.clearQueue()
              }
              .font(.caption)
              .foregroundColor(.red)
            }
          }
        }
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(10)
      
      // Alignment Picker
      VStack(spacing: 10) {
        Text("Toast Position")
          .font(.headline)
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
          alignmentButton(.topLeading, "↖️ Top Leading")
          alignmentButton(.top, "⬆️ Top")
          alignmentButton(.topTrailing, "↗️ Top Trailing")
          
          alignmentButton(.leading, "⬅️ Leading")
          alignmentButton(.center, "🎯 Center")
          alignmentButton(.trailing, "➡️ Trailing")
          
          alignmentButton(.bottomLeading, "↙️ Bottom Leading")
          alignmentButton(.bottom, "⬇️ Bottom")
          alignmentButton(.bottomTrailing, "↘️ Bottom Trailing")
        }
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .cornerRadius(10)
      
      Divider()
      
      VStack(spacing: 15) {
        Text("Current Position: \(alignmentName(toastAlignment))")
          .font(.subheadline)
          .foregroundColor(.secondary)
        
        // Quick sequence button for testing queue
        if queueMode == .queue {
          Button("Show 3 Quick Toasts") {
            toast.show(message: "First toast 🥇", type: .info, duration: 2.0)
            toast.show(message: "Second toast 🥈", type: .success, duration: 2.0)
            toast.show(message: "Third toast 🥉", type: .warning, duration: 2.0)
          }
          .buttonStyle(.borderedProminent)
          .foregroundColor(.white)
          .background(Color.purple)
        }
        
        HStack(spacing: 10) {
          Button("Info") {
            toast.show(message: "This is an informational message!", type: .info, duration: 3.0)
          }
          .buttonStyle(.borderedProminent)
          
          Button("Success") {
            toast.show(message: "Operation completed successfully! ✅", type: .success, duration: 4.0)
          }
          .buttonStyle(.borderedProminent)
        }
        
        HStack(spacing: 10) {
          Button("Warning") {
            toast.show(message: "Please check your input before proceeding.", type: .warning, duration: 3.5)
          }
          .buttonStyle(.borderedProminent)
          
          Button("Error") {
            toast.show(message: "Something went wrong. Please try again.", type: .error, duration: 5.0)
          }
          .buttonStyle(.borderedProminent)
        }
        
        Button("Show Long Message") {
          toast.show(message: "This is a very long message that demonstrates how the toast handles multiple lines of text gracefully.", type: .info, duration: 4.0)
        }
        .buttonStyle(.bordered)
        
        HStack(spacing: 10) {
          if toast.isShowingToast {
            Button("Dismiss Current") {
              toast.dismiss()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
          }
          
          if toast.hasQueuedToasts {
            Button("Dismiss All") {
              toast.dismissAll()
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
          }
        }
      }
      
      Spacer()
      
      Text("Tap any toast to dismiss it")
        .font(.caption)
        .foregroundColor(.secondary)
    }
    .padding()
    .navigationTitle("Toast Demo")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      // Sync the toast manager's queue mode with our local state
      toast.queueMode = queueMode
    }
    .onChange(of: queueMode) { _, newMode in
      // Update the toast manager when picker changes
      toast.queueMode = newMode
    }
  }
  
  private func alignmentButton(_ alignment: Alignment, _ title: String) -> some View {
    Button(title) {
      toastAlignment = alignment
    }
    .font(.caption)
    .foregroundColor(toastAlignment == alignment ? .white : .primary)
    .padding(.vertical, 8)
    .padding(.horizontal, 4)
    .background(toastAlignment == alignment ? Color.accentColor : Color.clear)
    .cornerRadius(6)
    .overlay(
      RoundedRectangle(cornerRadius: 6)
        .stroke(Color.accentColor, lineWidth: toastAlignment == alignment ? 0 : 1)
    )
  }
  
  private func alignmentName(_ alignment: Alignment) -> String {
    switch alignment {
    case .topLeading: return "Top Leading"
    case .top: return "Top"
    case .topTrailing: return "Top Trailing"
    case .leading: return "Leading"
    case .center: return "Center"
    case .trailing: return "Trailing"
    case .bottomLeading: return "Bottom Leading"
    case .bottom: return "Bottom"
    case .bottomTrailing: return "Bottom Trailing"
    default: return "Unknown"
    }
  }
}
