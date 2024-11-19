//
//  AppColor.swift
//  Gako
//
//  Created by Kevin Fairuz on 07/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A custom color for the App
//  Usage: Use this color for the App color
//

import SwiftUI

class AppColor: ObservableObject {
    @Published var tint: Color = .accentColor
}

extension Color {
    static let accentGlobal = Color("AccentColor")
}

final class AppTheme: ObservableObject {
    static let shared = AppTheme()
    @Published var accentColor: Color = Color("AccentColor")
    private init() {}
}

private struct AlertTintKey: EnvironmentKey {
    static let defaultValue: Color = .accent
}

extension EnvironmentValues {
    var alertTint: Color {
        get { self[AlertTintKey.self] }
        set { self[AlertTintKey.self] = newValue }
    }
}

struct GlobalAccentModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tint(.accent)
            .accentColor(.accent)
            .buttonStyle(AccentButtonStyle())
    }
}

extension UIApplication {
    func setGlobalTint(_ color: Color) {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
            
            scenes.forEach { scene in
                scene.windows.forEach { window in
                    window.tintColor = UIColor(color)
                }
            }
        } else {
            windows.forEach { window in
                window.tintColor = UIColor(color)
            }
        }
    }
}
