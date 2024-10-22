//
//  MainTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var studentListViewModel: StudentTabViewModel
    @State private var selectedTab = 0

    init(studentListViewModel: StudentTabViewModel) {
        _studentListViewModel = StateObject(wrappedValue: studentListViewModel)
    }

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    SummaryTabView(studentListViewModel: studentListViewModel)
                        .tag(0)
                        .tabItem {
                            Label("Ringkasan", systemImage: "house")
                        }
                    
                    StudentTabView(viewModel: studentListViewModel)
                        .tag(1)
                        .tabItem {
                            Label("Murid", systemImage: "person.3")
                        }
                }
                .tabViewStyle(DefaultTabViewStyle())
            }
        }
    }

    private func addNewStudent() {
        print("Add new student")
    }
}
