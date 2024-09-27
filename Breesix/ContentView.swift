//
//  ContentView.swift
//  Breesix
//
//  Created by Rangga Biner on 19/09/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView(selection: .constant(2)) {
            Text("Tab Content 1").tabItem { Text("Tab Label 1") }.tag(1)
            
            AgendaListView().tabItem { Text("Tab Label 2") }.tag(2)
        }
    }
}

#Preview {
    ContentView()
}
