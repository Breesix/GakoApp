//
//  CustomNavigationBar.swift
//  Breesix
//
//  Created by Kevin Fairuz on 26/10/24.
//


import SwiftUI

struct CustomNavigationPreviewBar: View {
    var title: String
    var action: () -> Void

    var body: some View {
        ZStack {
            Color(.bgMain)
                .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    Text(title)
                        .font(.title)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    Spacer()
                    
                    AddButton(action: action)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .frame(height: 58)
    }
}
