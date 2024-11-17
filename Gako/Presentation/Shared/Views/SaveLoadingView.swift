//
//  SaveLoadingView.swift
//  Breesix
//
//  Created by Rangga Biner on 07/11/24.
//

import SwiftUI

struct SaveLoadingView: View {
    let progress: Double
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        ZStack {
            Color.white
                .opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("Expressions")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                
                Text("Menyimpan Dokumentasi...")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.labelPrimaryBlack)
                
                ProgressView(value: animatedProgress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: 200)
                    .tint(Color(.orangeClickAble))
                
                Text("Mohon tunggu sebentar")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(radius: 10)
            )
            .padding(.horizontal, 40)
        }
        .onChange(of: progress) {
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = progress
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = progress
            }
        }
    }
}

#Preview {
    ScrollView {
        SaveLoadingView(progress: 0.0)
        SaveLoadingView(progress: 0.5)
        SaveLoadingView(progress: 1.0)
    }
}

