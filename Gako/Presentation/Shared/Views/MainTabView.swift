//
//  MainTabView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var studentViewModel: StudentViewModel
    @EnvironmentObject var noteViewModel: NoteViewModel
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var summaryViewModel: SummaryViewModel
    @StateObject private var tabBarController = TabBarController.shared
    @State private var selectedTab = 0
    @State private var hideTabBar = false
    @State private var isAddingStudent = false
    
    init() {
        UITabBar.appearance().isHidden = true
    }

    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    SummaryTabView(
                        selectedTab:$selectedTab,
                        isAddingStudent: $isAddingStudent)
                        .tag(0)
                    StudentTabView(isAddingStudent: $isAddingStudent)
                        .tag(1)
                }
                .tint(Color.accent)
                .accentColor(Color.accent)
                .shadow(color: .black.opacity(1), radius: 0, x: 50, y: 50)
                if !tabBarController.isHidden {
                    customTabBar
                        .background(Color.white)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .environmentObject(tabBarController)
    }
    
    private var customTabBar: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
                ForEach(TabbedItems.allCases, id: \.self) { item in
                    Button {
                        withAnimation(.none) {
                            selectedTab = item.rawValue
                        }
                    } label: {
                        CustomTabItem(
                            imageName: item.iconName,
                            title: item.title,
                            isActive: (selectedTab == item.rawValue),
                            imageBackground: item.imageBackground,
                            negativeImage: item.negativeImage
                        )
                        .optimizedTabBarItem()
                    }
                }
            }
            .background(Color.white)
            .frame(height: 72)
            .padding(.bottom, 5)
        }
    }
}


enum TabbedItems: Int, CaseIterable {
    case home = 0
    case student
    
    var title: String {
        switch self {
        case .home:
            return "Dokumentasi"
        case .student:
            return "Murid"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "book.fill"
        case .student:
            return "person.3.fill"
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
    static let shared = TabBarController()
    @Published var isHidden = false
    private var hideCount = 0
    
    func incrementHide() {
        hideCount += 1
        updateHiddenState()
    }
    
    func decrementHide() {
        hideCount -= 1
        updateHiddenState()
    }
    
    private func updateHiddenState() {
        isHidden = hideCount > 0
    }
}

final class ImageCache {
    static let shared = ImageCache()
    private var cache: [String: Image] = [:]
    
    func getImage(_ name: String) -> Image {
        if let cached = cache[name] {
            return cached
        }
        let image = Image(name)
        cache[name] = image
        return image
    }
}

extension MainTabView {
    func getBackgroundImage(isActive: Bool, activeImage: String, inactiveImage: String) -> Image {
        let imageName = isActive ? activeImage : inactiveImage
        return ImageCache.shared.getImage(imageName)
    }
}
