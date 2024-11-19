//
//  MainTabView.swift
//  Gako
//
//  Created by Rangga Biner on 30/09/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A view that display main tab view
//  Usage: Use this view to display main tab view
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
    
    var tabBarHeight = UIConstants.MainTabView.tabBarHeight
    var tabBarSpacing = UIConstants.MainTabView.tabBarSpacing
    var tabBarBottomPadding = UIConstants.MainTabView.tabBarBottomPadding
    var shadowRadius = UIConstants.MainTabView.shadowRadius
    var shadowOffset = UIConstants.MainTabView.shadowOffset
    var tabBarBackground = UIConstants.MainTabView.tabBarBackground
    var shadowColor = UIConstants.MainTabView.shadowColor
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    SummaryTabView(
                        selectedTab: $selectedTab,
                        isAddingStudent: $isAddingStudent)
                        .tag(0)
                    StudentTabView(isAddingStudent: $isAddingStudent)
                        .tag(1)
                }
                .tint(Color.accent)
                .accentColor(Color.accent)
                .shadow(color: shadowColor, radius: shadowRadius, x: shadowOffset, y: shadowOffset)
                if !tabBarController.isHidden {
                    customTabBar
                        .background(tabBarBackground)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .environmentObject(tabBarController)
    }
    
    private var customTabBar: some View {
        ZStack(alignment: .bottom) {
            HStack(spacing: tabBarSpacing) {
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
            .background(.white)
            .frame(height: tabBarHeight)
            .padding(.bottom, tabBarBottomPadding)
        }
    }
}
