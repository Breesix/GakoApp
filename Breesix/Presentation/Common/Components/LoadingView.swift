//  LoadingView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 31/10/24.
//

import SwiftUI

struct LoadingView: View {
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
        .onChange(of: progress) { newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = newValue
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3)) {
                animatedProgress = progress
            }
        }
    }
}

// Preview dengan simulasi progress
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview dengan progress 0%
            LoadingView(progress: 0.0)
                .previewDisplayName("Progress 0%")
            
            // Preview dengan progress 50%
            LoadingView(progress: 0.5)
                .previewDisplayName("Progress 50%")
            
            // Preview dengan progress 100%
            LoadingView(progress: 1.0)
                .previewDisplayName("Progress 100%")
        }
    }
}
