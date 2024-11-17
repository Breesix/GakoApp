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
    @StateObject private var viewModel = OnboardingViewModel()
    
    var defaultSpacing: CGFloat = UIConstants.OnboardingView.defaultSpacing
    var sectionPadding: CGFloat = UIConstants.OnboardingView.sectionPadding
    var safeArea : CGFloat = UIConstants.OnboardingView.safeArea
    
    var body: some View {
        VStack(spacing: defaultSpacing) {
            Image("iconOnboarding")
            
            TabView(selection: $viewModel.currentPage) {
                ForEach(onboardingItems) { item in
                    OnboardingSection(onboarding: item)
                        .tag(onboardingItems.firstIndex(where: { $0.id == item.id }) ?? 0)
                }
                .padding(.horizontal, sectionPadding)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            Spacer()
            
            PageIndicator(numberOfPages: onboardingItems.count,
                         currentPage: viewModel.currentPage)
            
            OnboardingButton(
                isLastPage: viewModel.isLastPage,
                onNextTapped: viewModel.handleNextButton,
                onPreviousTapped: viewModel.handlePreviousButton,
                showPreviousButton: viewModel.showPreviousButton
            )
        }
        .safeAreaPadding(.horizontal, safeArea)
    }
}

#Preview {
    OnboardingView()
}
