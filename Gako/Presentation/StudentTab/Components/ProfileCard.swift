//
//  ProfileCard.swift
//  Gako
//
//  Created by Rangga Biner on 01/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A card component that displays student profile information with image
//  Usage: Use this view to show student profile details with delete functionality
//

import SwiftUI

struct ProfileCard: View {
    // MARK: - Constants
    private let imageSize = UIConstants.ProfileCard.cardImageSize
    private let spacing = UIConstants.ProfileCard.cardSpacing
    private let borderColor = UIConstants.ProfileCard.borderColor
    private let borderWidth = UIConstants.ProfileCard.borderWidth
    private let borderInset = UIConstants.ProfileCard.borderInset
    private let cornerRadius = UIConstants.ProfileCard.cardCornerRadius
    private let horizontalPadding = UIConstants.ProfileCard.horizontalPadding
    private let verticalPadding = UIConstants.ProfileCard.verticalPadding
    private let spacingMain = UIConstants.ProfileCard.spacing
    private let maxHeight = UIConstants.ProfileCard.maxHeight
    private let minHeight = UIConstants.ProfileCard.minHeight
    private let placeholderIcon = UIConstants.ProfileCard.placeholderIcon
    private let deleteIcon = UIConstants.ProfileCard.deleteIcon
    private let deleteButtonText = UIConstants.ProfileCard.deleteButtonText
    
    
    // MARK: - Properties
    let student: Student
    let onDelete: () -> Void
    @State var showDeleteAlert = false
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: spacingMain) {
            VStack(alignment: .center, spacing: spacing) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: imageSize, height: imageSize)
                    .background(
                        Group {
                            if let imageData = student.imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSize, height: imageSize)
                                    .clipped()
                            } else {
                                Image(systemName: placeholderIcon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: imageSize, height: imageSize)
                                    .foregroundStyle(.bgSecondary)
                            }
                        }
                    )
                    .clipShape(.circle)
                    .overlay(
                        Circle()
                            .inset(by: borderInset)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                
                VStack(alignment: .center, spacing: spacing) {
                    Text(student.nickname)
                        .font(.body)
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: minHeight, maxHeight: maxHeight, alignment: .center)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(.white)
                .cornerRadius(cornerRadius)
            }
        }
        .contextMenu {
            Button(action: handleDelete) {
                Text(deleteButtonText)
                Image(systemName: UIConstants.Profile.deleteIcon)
            }
        }
        .alert("Hapus Profil", isPresented: $showDeleteAlert) {
            Button("Batal", role: .cancel) { }
            Button("Hapus", role: .destructive, action: confirmDelete)
        } message: {
            Text("Apakah Anda yakin ingin menghapus profil ini?")
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileCard(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), onDelete: { print("deleted") })
}
