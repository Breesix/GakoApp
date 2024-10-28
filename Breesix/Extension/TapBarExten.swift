//
//  TapBarExten.swift
//  Breesix
//
//  Created by Kevin Fairuz on 21/10/24.
//

import SwiftUI


//extension View {
//    func hideTabBar(_ isHidden: Bool = true) -> some View {
//        modifier(TabBarModifier(isHidden: isHidden))
//    }
//}

struct HideTabBarOnPush: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
    }
}




struct HideTabBarModifier: ViewModifier {
    @ObservedObject private var tabBarController = TabBarController.shared
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                tabBarController.isHidden = true
            }
            .onDisappear {
                tabBarController.isHidden = false
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
                .foregroundColor(isActive ? .green : .gray)
                .scaledToFit()
                .frame(width: 30, height: 20)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(isActive ? .green : .gray)
            Spacer()
        }
        .padding(.bottom, 10)
        .background(
            Image(isActive ? imageBackground : negativeImage)
                .resizable()
                .scaledToFill()
                .frame(width: 210, height: 100)
                .clipped() // Tambahkan clipping
                .allowsHitTesting(false) // Mencegah interaksi dengan background
        )
        .frame(width: UIScreen.main.bounds.width / 2, height: 99)
        .contentShape(Rectangle()) // Memastikan area tap mencakup seluruh item
        .animation(.none, value: isActive) // Menghilangkan animasi default
    }
}

// Tambahkan extension untuk optimasi performa
extension View {
    func optimizedTabBarItem() -> some View {
        self
            //.drawingGroup() // Menggunakan Metal untuk rendering
            .compositingGroup() // Menggabungkan layers
    }
}



