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
  
  // You can still use @EnvironmentObject if preferred, they both access the same manager
  // @EnvironmentObject private var toastManager: ToastManager
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Using @Toast Wrapper")
      
      Button("Show Info via @Toast") {
        // Call show() directly on the wrapped variable
        toast.show(toast: ToastData(message: "Info from @Toast!", type: .info))
      }
      
      Button("Show Success via @Toast") {
        toast.show(toast: ToastData(message: "Success from @Toast!", type: .success, duration: 4.0))
      }
      
      Button("Show Error via @Toast") {
        toast.show(message: "Error from @Toast", type: .error, duration: 1.0)
      }
      
      Button("Dismiss via @Toast") {
        // You can also call other public methods like dismiss
        toast.dismiss()
      }
    }
    .navigationTitle("Toast Demo (@Toast)")
  }
}
