//
//  ButtonOnboarding.swift
//  Breesix
//
//  Created by Kevin Fairuz on 05/11/24.
//

import SwiftUI

struct ButtonOnboarding: View {
    @Binding var currentPage: Int
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    var body: some View {
               VStack {
                   HStack(spacing: 20) {
                    
                       if currentPage > 0 {
                           Button(action: {
                               withAnimation {
                                   currentPage -= 1
                               }
                           }) {
                               Text("Sebelumnya")
                                   .foregroundColor(.black)
                                   .fontWeight(.semibold)
                                   .padding()
                                   .frame(maxWidth: .infinity)
                                   .background(Color.white)
                                   .cornerRadius(10)
                           }
                       }
                       
          
                       Button(action: {
                           if currentPage == onboarding.count - 1 {
                               
                               isOnboarding = false
                           } else {
                             
                               withAnimation {
                                   currentPage += 1
                               }
                           }
                       }) {
                           Text(currentPage == onboarding.count - 1 ? "Mengerti" : "Lanjut")
                               .foregroundColor(.white)
                               .fontWeight(.semibold)
                               .padding()
                               .frame(maxWidth: .infinity)
                               .background(.buttonPrimaryOnBg)
                               .cornerRadius(10)
                       }
                   }
                   .padding(.horizontal)
                   .padding(.bottom, 30)
               }
       }
   }


