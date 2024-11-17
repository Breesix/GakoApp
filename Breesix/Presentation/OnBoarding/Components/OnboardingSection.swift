//
//  OnboardingSection.swift
//  Breesix
//
//  Created by Kevin Fairuz on 05/11/24.
//
//  A custom component that displays animation and text
//  Usage: Use this component to show animation and text for onboarding view
//

import SwiftUI

struct OnboardingSection: View {
    var onboarding: Onboarding
    
    var defaultSpacing: CGFloat = UIConstants.OnboardingSection.defaultSpacing
    var textSpacing: CGFloat = UIConstants.OnboardingSection.textSpacing
    var primaryText: Color = UIConstants.OnboardingSection.primaryText
    var secondaryText: Color = UIConstants.OnboardingSection.secondaryText
    
    var body: some View {
            VStack(spacing: defaultSpacing) {
                LottieAnimation(lottieFile: onboarding.lottie)
                
                VStack (spacing: textSpacing){
                    Text(onboarding.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(primaryText)
                    
                    Text(onboarding.description)
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundStyle(secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            
        }
}

#Preview {
    OnboardingSection(onboarding: onboardingItems[1])
}
