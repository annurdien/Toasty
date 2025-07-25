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
  
  // Custom configuration for demonstration
  private let customConfig = ToastConfiguration()
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Toasty Demo")
        .font(.title2)
        .fontWeight(.bold)
      
      VStack(spacing: 15) {
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
        
        Button("Quick Toast (1s)") {
          toast.show(message: "Quick message!", type: .success, duration: 1.0)
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
}
