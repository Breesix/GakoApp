//
//  OnboardingView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 06/11/24.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    
    var body: some View {
        ZStack{
            
            VStack{
                TabView(selection: $currentPage) {
                    ForEach(Array(0..<onboardingItems.count), id: \.self) { index in
                        CreateStudentOnboardingView(onboardingGako: onboardingItems[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                CustomPageIndicator(numberOfPages: onboardingItems.count, currentPage: currentPage)
                                    .padding(.bottom, 20)
                OnboardingButton(currentPage: $currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
