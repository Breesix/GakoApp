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
    @State private var hideTabBar = false
    @StateObject private var tabBarController = TabBarController.shared
    init(studentListViewModel: StudentListViewModel) {
        _studentListViewModel = StateObject(wrappedValue: studentListViewModel)
        
    }

    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    SummaryTabView(studentListViewModel: studentListViewModel)
                        .tag(0)
                    StudentTabView(viewModel: studentListViewModel)
                        .tag(1)
                }
                
                if !tabBarController.isHidden {
                    customTabBar
                        .transition(.move(edge: .bottom))
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .environmentObject(tabBarController)
    }
    
    private var customTabBar: some View {
        ZStack(alignment: .bottom) {
            HStack {
                ForEach(TabbedItems.allCases, id: \.self) { item in
                    Button {
                        selectedTab = item.rawValue
                    } label: {
                        CustomTabItem(imageName: item.iconName,
                                    title: item.title,
                                    isActive: (selectedTab == item.rawValue),
                                    imageBackground: item.imageBackground,
                                    negativeImage: item.negativeImage)
                    }
                }
            }
            .frame(height: 72)
            .padding(.horizontal, -10)
            .padding(.bottom, 8)
        }
    }
}


enum TabbedItems: Int, CaseIterable {
    case home = 0
    case student
    
    var title: String {
        switch self {
        case .home:
            return "Ringkasan"
        case .student:
            return "Murid"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "house"
        case .student:
            return "person.3"
        }
    }
    
    var imageBackground: String {
        switch self {
        case .home:
            return "ringkasan-active"
        case .student:
            return "murid-active"
        }
    }
    
    var negativeImage: String {
        switch self {
        case .home:
            return "ringkasan-inactive"
        case .student:
            return "murid-inactive"
        }
    }
}


class TabBarController: ObservableObject {
    @Published var isHidden: Bool = false
    
    static let shared = TabBarController()
    
    private init() {}
}
