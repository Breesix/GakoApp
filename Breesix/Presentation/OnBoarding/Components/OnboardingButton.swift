//
//  ButtonOnboarding.swift
//  Breesix
//
//  Created by Kevin Fairuz on 05/11/24.
//
//  A custom component that displays navigation buttons for onboarding flow
//  Usage: Use this component to show button for onboarding flow
//

import SwiftUI

struct OnboardingButton: View {
    @Binding var currentPage: Int
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    var next: String = UIConstants.OnboardingButtonText.next
    var previous: String = UIConstants.OnboardingButtonText.previous
    var done: String = UIConstants.OnboardingButtonText.done
    var defaultPadding: CGFloat = UIConstants.OnboardingButtonText.defaultPadding
    var buttonPadding: CGFloat = UIConstants.OnboardingButtonText.buttonPadding
    var buttonSpacing: CGFloat = UIConstants.OnboardingButtonText.buttonSpacing
    var buttonRadius: CGFloat = UIConstants.OnboardingButtonText.cornerRadius
    var nextColor: Color = UIConstants.OnboardingButtonText.nextColor
    var previousColor: Color = UIConstants.OnboardingButtonText.previousColor
    var initialButtonWidth: CGFloat = UIConstants.OnboardingButtonText.initialButtonWidth
    
    var body: some View {
               VStack {
                   HStack(spacing: buttonSpacing) {
                       if currentPage > 0 {
                           Button(action: {
                                   currentPage -= 1
                               if currentPage < 0 {
                                   currentPage = 0
                               }
                           }) {
                               Text(previous)
                                   .foregroundColor(.labelPrimaryBlack)
                                   .frame(maxWidth: .infinity)
                                   .padding(buttonPadding)
                                   .background(previousColor)
                           }
                           .cornerRadius(buttonRadius)
                       }
                       
                       if currentPage == 0 {
                           Spacer()
                               .padding(.horizontal, defaultPadding)
                       }
                       
                       Button(action: {
                           if currentPage == onboardingItems.count - 1 {
                               isOnboarding = false
                           } else {
                               currentPage += 1
                           }
                       }) {
                           Text(currentPage == onboardingItems.count - 1 ? done : next)
                               .foregroundColor(.white)
                               .frame(maxWidth: currentPage == 0 ? initialButtonWidth : .infinity)
                               .padding(buttonPadding)
                               .background(nextColor)
                       }
                       .cornerRadius(buttonRadius)
                   }
                   .font(.body)
                   .fontWeight(.semibold)
               }
       }
}

#Preview {
    OnboardingButton(currentPage: .constant(0), isOnboarding: true)
}
