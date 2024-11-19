//
//  TapBar+Extension.swift
//  Gako
//
//  Created by Kevin Fairuz on 21/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Custom tab bar extensions and modifiers for SwiftUI
//  Usage: Provides functionality for hiding tab bar, custom tab items, and tab bar optimization
//

import SwiftUI

struct HideTabBarModifier: ViewModifier {
    @ObservedObject private var tabBarController = TabBarController.shared
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                tabBarController.incrementHide()
            }
            .onDisappear {
                tabBarController.decrementHide()
            }
    }
}

extension View {
    func hideTabBar() -> some View {
        modifier(HideTabBarModifier())
    }
}

private extension UIView {
    func allSubviews() -> [UIView] {
        var subviews = [UIView]()
        subviews.append(contentsOf: self.subviews)
        subviews.forEach { subview in
            subviews.append(contentsOf: subview.allSubviews())
        }
        return subviews
    }
}

extension MainTabView {
    func CustomTabItem(imageName: String, title: String, isActive: Bool, imageBackground: String, negativeImage: String) -> some View {
        VStack {
            Spacer()
            Image(systemName: imageName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(isActive ? .accentColor : .gray)
                .scaledToFit()
                .frame(width: 30, height: 20)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isActive ? .accentColor : .gray)
            Spacer()
        }
        .padding(.bottom, 10)
        .background(
            Image(isActive ? imageBackground : negativeImage)
                .resizable()
                .scaledToFit()
                .frame(width: 210)
                .allowsHitTesting(false) 
                .padding(.bottom, 22)
        )
        .frame(width: UIScreen.main.bounds.width / 2, height: 99)
        .contentShape(Rectangle())
        .animation(.none, value: isActive)
    }
}

extension View {
    func optimizedTabBarItem() -> some View {
        self
            .compositingGroup()
    }
}
