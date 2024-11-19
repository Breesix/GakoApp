//
//  SaveLoadingView.swift
//  Gako
//
//  Created by Rangga Biner on 07/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A view that display loading view
//  Usage: Use this view to display loading 
//

import SwiftUI

struct SaveLoadingView: View {
    let progress: Double
    @State private var animatedProgress: Double = 0.0
    
    var totalProgress: CGFloat = UIConstants.SaveLoadingView.totalProgress
    var shadowRadius: CGFloat = UIConstants.SaveLoadingView.shadowRadius
    var imageSize: CGFloat = UIConstants.SaveLoadingView.imageSize
    var progressBarWidth: CGFloat = UIConstants.SaveLoadingView.progressBarWidth
    var containerCornerRadius: CGFloat = UIConstants.SaveLoadingView.containerCornerRadius
    var horizontalPadding: CGFloat = UIConstants.SaveLoadingView.horizontalPadding
    var verticalSpacing: CGFloat = UIConstants.SaveLoadingView.verticalSpacing
    var animationDuration: CGFloat = UIConstants.SaveLoadingView.animationDuration
    var overlayColor: Color = UIConstants.SaveLoadingView.overlayColor
    var containerColor: Color = UIConstants.SaveLoadingView.containerColor
    var progressBarTint: Color = UIConstants.SaveLoadingView.progressBarTint
    var titleColor: Color = UIConstants.SaveLoadingView.titleColor
    var subtitleColor: Color = UIConstants.SaveLoadingView.subtitleColor
    var expressionsImage: String = UIConstants.SaveLoadingView.expressionsImage
    var title: String = UIConstants.SaveLoadingView.title
    var subtitle: String = UIConstants.SaveLoadingView.subtitle
    
    var body: some View {
        ZStack {
            overlayColor
                .ignoresSafeArea()
            
            VStack(spacing: verticalSpacing) {
                Image(expressionsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize)
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(titleColor)
                
                ProgressView(value: animatedProgress, total: totalProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(width: progressBarWidth)
                    .tint(progressBarTint)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(subtitleColor)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: containerCornerRadius)
                    .fill(containerColor)
                    .shadow(radius: shadowRadius)
            )
            .padding(.horizontal, horizontalPadding)
        }
        .onChange(of: progress) {
            withAnimation(.easeInOut(duration: animationDuration)) {
                animatedProgress = progress
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: animationDuration)) {
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

