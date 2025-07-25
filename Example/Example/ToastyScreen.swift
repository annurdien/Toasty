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
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Toasty Demo")
        .font(.title2)
        .fontWeight(.bold)
      
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
        
        Button("Show Info Toast") {
          toast.show(message: "This is an informational message!", type: .info, duration: 3.0)
        }
        .buttonStyle(.borderedProminent)
        
        Button("Show Success Toast") {
          toast.show(message: "Operation completed successfully! ✅", type: .success, duration: 4.0)
        }
        .buttonStyle(.borderedProminent)
        
        Button("Show Warning Toast") {
          toast.show(message: "Please check your input before proceeding.", type: .warning, duration: 3.5)
        }
        .buttonStyle(.borderedProminent)
        
        Button("Show Error Toast") {
          toast.show(message: "Something went wrong. Please try again.", type: .error, duration: 5.0)
        }
        .buttonStyle(.borderedProminent)
        
        Button("Show Long Message") {
          toast.show(message: "This is a very long message that demonstrates how the toast handles multiple lines of text gracefully.", type: .info, duration: 4.0)
        }
        .buttonStyle(.bordered)
        
        if toast.isShowingToast {
          Button("Dismiss Current Toast") {
            toast.dismiss()
          }
          .buttonStyle(.bordered)
          .foregroundColor(.red)
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
