//
//  ProfileCard.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct ProfileCard: View {
    // MARK: - Constants
    private let imageSize = UIConstants.Profile.cardImageSize
    private let spacing = UIConstants.Profile.cardSpacing
    private let borderColor = UIConstants.Profile.borderColor
    private let borderWidth = UIConstants.Profile.borderWidth
    private let borderInset = UIConstants.Profile.borderInset
    private let cornerRadius = UIConstants.Profile.cardCornerRadius
    private let horizontalPadding = UIConstants.Profile.horizontalPadding
    private let verticalPadding = UIConstants.Profile.verticalPadding
    private let spacingMain = UIConstants.Profile.spacing
    private let maxHeight = UIConstants.Profile.maxHeight
    private let minHeight = UIConstants.Profile.minHeight
    
    
    // MARK: - Properties
    let student: Student
    let onDelete: () -> Void
    @State var showDeleteAlert = false
    
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
                                Image(systemName: UIConstants.Profile.placeholderIcon)
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
                Text(UIConstants.Profile.deleteButtonText)
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

#Preview {
    ProfileCard(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), onDelete: { print("deleted") })
}
