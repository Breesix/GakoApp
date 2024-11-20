//
//  ProfileHeader.swift
//  Gako
//
//  Created by Akmal Hakim on 15/10/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A header component that displays student profile summary
//  Usage: Use this view to show student's image and name at the top of screens
//

import SwiftUI

struct ProfileHeader: View {
    // MARK: - Constants
    private let imageSize = UIConstants.ProfileHeader.headerImageSize
    private let spacing = UIConstants.ProfileHeader.headerSpacing
    private let textColor = UIConstants.ProfileHeader.textColor
    private let placeholderColor = UIConstants.ProfileHeader.placeholderImageColor
    private let defaultSpacing = UIConstants.ProfileHeader.defaultSpacing
    
    // MARK: - Properties
    let student: Student
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: defaultSpacing) {
            HStack(alignment: .center, spacing: spacing) {
                if let imageData = student.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                } else {
                    Image(systemName: UIConstants.Profile.placeholderIcon)
                        .resizable()
                        .frame(width: imageSize, height: imageSize)
                        .foregroundColor(placeholderColor)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(student.fullname)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor)
                    
                    Text(student.nickname)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .foregroundColor(textColor)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ProfileHeader(student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
}
