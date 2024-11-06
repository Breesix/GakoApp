//
//  CreateStudentOnboardingView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 05/11/24.
//

import SwiftUI
import DotLottie

struct CreateStudentOnboardingView: View {
    
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
                
                LottieView(lottieFile: onboardingGako.lottie)
                    .padding()
                
                VStack{
                    Text(onboardingGako.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20))
                        .padding(.bottom, 8)
                    
                    Text(onboardingGako.description)
                        .fontWeight(.semibold)
                        .font(.body)
                        .foregroundColor(.black.opacity(0.5))
                        .padding(.horizontal, 16)
                        .frame(maxWidth: 480)
                        .multilineTextAlignment(.center)
                }
                .padding([.bottom,.top], 20)
            }
         
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .padding()
        }
    }
}

struct CreateStudentOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        CreateStudentOnboardingView(onboardingGako: onboarding[0])
    }
}

struct LottieView: View {
    let lottieFile: String
    @State private var isLottieLoaded = false
    
    var body: some View {
        Group {
            if isLottieLoaded {
                DotLottieAnimation(fileName: lottieFile,
                                 config: AnimationConfig(
                                    autoplay: true,
                                    loop: true
                                 ))
                .view()
                .scaleEffect(1.2)
            } else {
                // Fallback view
                ProgressView()
                    .onAppear {
                        checkLottieFile()
                    }
            }
        }
    }
    
    private func checkLottieFile() {
        // Cek file dengan berbagai ekstensi
        let extensions = ["lottie", "json"]
        for ext in extensions {
            if Bundle.main.path(forResource: lottieFile, ofType: ext) != nil {
                isLottieLoaded = true
                return
            }
        }
    }
}
