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
            
            Color.white.edgesIgnoringSafeArea(.all)
            VStack{
               
                TabView(selection: $currentPage) {
                    ForEach(0..<onboarding.count) { index in
                        CreateStudentOnboardingView(onboardingGako: onboarding[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                CustomPageIndicator(numberOfPages: onboarding.count, currentPage: currentPage)
                                    .padding(.bottom, 20)
                ButtonOnboarding(currentPage: $currentPage)
            }
        }
        
    }
    
}



#Preview {
    OnboardingView()
}
