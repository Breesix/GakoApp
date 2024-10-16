//
//  MainTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var studentListViewModel: StudentListViewModel
    @State private var selectedTab = 0
    @State private var isShowingInputTypeSheet = false
    @State private var selectedInputType: InputTypeUser?
    @State private var isNavigatingToVoiceInput = false
    @State private var isNavigatingToTextInput = false

    init(studentListViewModel: StudentListViewModel) {
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

                if selectedTab == 0 {
                    PlusButton(action: {
                        isShowingInputTypeSheet = true
                    }, imageName: "plus.circle.fill")
                    .offset(y: 12)
                } else {
                    PlusButton(action: addNewStudent, imageName: "person.crop.circle.fill.badge.plus")
                    .offset(y: 15)
                }
            }
            .sheet(isPresented: $isShowingInputTypeSheet) {
                InputTypeSheet(studentListViewModel: studentListViewModel, onSelect: { selectedInput in
                    switch selectedInput {
                    case .voice:
                        isShowingInputTypeSheet = false
                        isNavigatingToVoiceInput = true
                    case .text:
                        isShowingInputTypeSheet = false
                        isNavigatingToTextInput = true
                    }
                })
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .background(
                NavigationLink(destination: VoiceInputView(), isActive: $isNavigatingToVoiceInput) { EmptyView() }
            )
            .background(
                NavigationLink(destination: TextInputView(studentListViewModel: studentListViewModel, isNavigatingToTextInput: $isNavigatingToTextInput), isActive: $isNavigatingToTextInput) { EmptyView() }
            )
        }
    }

    private func addNewStudent() {
        print("Add new student")
    }
}
