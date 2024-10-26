//
//  CustomColor.swift
//  Breesix
//
//  Created by Akmal Hakim on 15/10/24.
//

import Foundation
import SwiftUI

extension Color {
    static let customGreen = CustomGreen()
    static let customYellow = CustomYellow()
    static let customMonochrome = CustomMonochrome()
    
    struct CustomGreen {
        let g000 = Color(hex: "EAF0E4")
        let g300 = Color(hex: "6DA451")
        let g600 = Color(hex: "72A065")
    }
    
    struct CustomYellow {
        let y600 = Color(hex: "FFAD1F")
        let y600_2 = Color(hex: "FFBA5F")
    }
    
    struct CustomMonochrome {
        let m000 = Color(hex: "FFFFFF")
        let m100 = Color(hex: "F7F9FB")
        let m200 = Color(hex: "F0F3ED")
        let m900 = Color(hex: "999999")
        let m900_2 = Color(hex: "D9D9D9")
        let black = Color(hex: "4C4C4C")
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
