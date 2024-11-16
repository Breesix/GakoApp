//
//  CustomPageIndicator.swift
//  Breesix
//
//  Created by Kevin Fairuz on 06/11/24.
//
import SwiftUI

struct CustomPageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color(.buttonPrimaryOnBg) : Color.gray.opacity(0.5))
                    .frame(width: 12, height: 12)
                    .animation(.easeInOut, value: currentPage)
            }
        }
    }
}
