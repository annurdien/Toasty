//
//  ContentView.swift
//  Example
//
//  Created by Annurdien Rasyid on 22/04/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      NavigationStack {
        ToastyScreen()
      }
      .toastable(alignment: .top)
    }
}

#Preview {
    ContentView()
}
