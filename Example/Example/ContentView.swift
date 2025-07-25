//
//  ContentView.swift
//  Example
//
//  Created by Annurdien Rasyid on 22/04/25.
//

import SwiftUI

struct ContentView: View {
    @State private var toastAlignment: Alignment = .top
    
    var body: some View {
      NavigationStack {
        ToastyScreen(toastAlignment: $toastAlignment)
      }
      .toastable(alignment: toastAlignment)
    }
}

#Preview {
    ContentView()
}
