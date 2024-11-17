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
    let isLastPage: Bool
    let onNextTapped: () -> Void
    let onPreviousTapped: () -> Void
    let showPreviousButton: Bool
    
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
                if showPreviousButton {
                    Button(action: onPreviousTapped) {
                        Text(previous)
                            .foregroundColor(.labelPrimaryBlack)
                            .frame(maxWidth: .infinity)
                            .padding(buttonPadding)
                            .background(previousColor)
                    }
                    .cornerRadius(buttonRadius)
                }
                
                if !showPreviousButton {
                    Spacer()
                        .padding(.horizontal, defaultPadding)
                }
                
                Button(action: onNextTapped) {
                    Text(isLastPage ? done : next)
                        .foregroundColor(.white)
                        .frame(maxWidth: !showPreviousButton ? initialButtonWidth : .infinity)
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
    OnboardingButton(
        isLastPage: false,
        onNextTapped: {},
        onPreviousTapped: {},
        showPreviousButton: true
    )
}
