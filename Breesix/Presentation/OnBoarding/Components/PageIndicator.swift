//
//  CustomPageIndicator.swift
//  Gako
//
//  Created by Kevin Fairuz on 06/11/24.
//
//  Copyright © 2024 Breesix. All rights reserved.
//
//  Description: A custom component that displays page indicators for onboarding flow
//  Usage: Use this component to show current page position in a paginated view
//

import SwiftUI

struct PageIndicator: View {
    let numberOfPages: Int
    let currentPage: Int
    
    var activeColor: Color = UIConstants.PageIndicator.activeColor
    var inactiveColor: Color = UIConstants.PageIndicator.inactiveColor
    var dotSize: CGFloat = UIConstants.PageIndicator.dotSize
    var spacing: CGFloat = UIConstants.PageIndicator.defaultSpacing
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? activeColor : inactiveColor)
                    .frame(width: dotSize, height: dotSize)
            }
        }
        .animation(.easeInOut, value: currentPage)
    }
}

#Preview("Default") {
    PageIndicator(numberOfPages: 4, currentPage: 0)
}

#Preview("Middle Page") {
    PageIndicator(numberOfPages: 4, currentPage: 2)
}
