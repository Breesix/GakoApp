//
//  AppColor.swift
//  Breesix
//
//  Created by Kevin Fairuz on 07/11/24.
//
import SwiftUI
import UIKit


class AppColor: ObservableObject {
    @Published var tint: Color = .accentColor
}
extension Color {
    static let accentGlobal = Color("AccentColor")
}

final class AppTheme: ObservableObject {
    static let shared = AppTheme()
    
    // Definisikan warna accent default
    @Published var accentColor: Color = Color("AccentColor") // Sesuaikan dengan nama di asset catalog
    
    private init() {}
}


// 1. Definisikan AlertTintKey
private struct AlertTintKey: EnvironmentKey {
    static let defaultValue: Color = .accent
}

// 2. Buat extension EnvironmentValues
extension EnvironmentValues {
    var alertTint: Color {
        get { self[AlertTintKey.self] }
        set { self[AlertTintKey.self] = newValue }
    }
}



//// 2. Buat extension EnvironmentValues
//extension EnvironmentValues {
//    var alertTint: Color {
//        get { self[AlertTintKey.self] }
//        set { self[AlertTintKey.self] = newValue }
//    }
//}

// 3. Buat GlobalAccentModifier yang benar
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
        windows.first?.tintColor = UIColor(color)
    }
}
