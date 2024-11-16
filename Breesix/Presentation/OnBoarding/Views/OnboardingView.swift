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
                    ForEach(onboardingItems) { item in
                        OnboardingSection(onboardingGako: item)
                            .tag(onboardingItems.firstIndex(where: { $0.id == item.id }) ?? 0)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                PageIndicator(numberOfPages: onboardingItems.count, currentPage: currentPage)
                    .padding(.bottom, 20)
                OnboardingButton(currentPage: $currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
