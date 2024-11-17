//
//  OnboardingView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 06/11/24.
//
//  A view that displays onboarding
//  Usage: Use this view to show onboarding
//


import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    
    var defaultSpacing: CGFloat = UIConstants.OnboardingView.defaultSpacing
    var sectionPadding: CGFloat = UIConstants.OnboardingView.sectionPadding
    var safeArea : CGFloat = UIConstants.OnboardingView.safeArea
    
    var body: some View {
        VStack (spacing: defaultSpacing){
            Image("iconOnboarding")
                TabView(selection: $currentPage) {
                    ForEach(onboardingItems) { item in
                        OnboardingSection(onboarding: item)
                            .tag(onboardingItems.firstIndex(where: { $0.id == item.id }) ?? 0)
                    }
                    .padding(.horizontal, sectionPadding)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
             
                Spacer()

                PageIndicator(numberOfPages: onboardingItems.count, currentPage: currentPage)
                
                OnboardingButton(currentPage: $currentPage)
            }
        .safeAreaPadding(.horizontal, safeArea)
    }
}

#Preview {
    OnboardingView()
}
