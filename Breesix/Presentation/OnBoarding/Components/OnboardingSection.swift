//
//  OnboardingSection.swift
//  Breesix
//
//  Created by Kevin Fairuz on 05/11/24.
//

import SwiftUI

struct OnboardingSection: View {
    
    var onboardingGako: OnboardingGako
    @State private var isLottieLoaded = false
    @AppStorage("isOnBoarding") var isOnBoarding: Bool = true
    
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(spacing: 20) {
                Image("Icon-Onboarding")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130)
                    .padding(.bottom, 20)
                
                LottieAnimation(lottieFile: onboardingGako.lottie)
                    .padding()
                
                VStack (spacing: 12){
                    Text(onboardingGako.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.labelPrimaryBlack)
                        .padding(.bottom, 8)
                    
                    Text(onboardingGako.description)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(.labelSecondaryBlack)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: 480)
                        .multilineTextAlignment(.center)
                }
                .padding([.bottom,.top], 20)
            }
         
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
        }
    }
}

#Preview {
    OnboardingSection(onboardingGako: onboardingItems[0])
}
