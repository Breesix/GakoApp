//
//  MainTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var studentListViewModel: StudentListViewModel
    
    init(studentListViewModel: StudentListViewModel) {
        _studentListViewModel = StateObject(wrappedValue: studentListViewModel)
    }
    
    var body: some View {
        TabView {
            SummaryTabView(studentListViewModel: studentListViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            StudentTabView(viewModel: studentListViewModel)
                .tabItem {
                    Label("Murid", systemImage: "person.3")
                }
        }
    }
}
