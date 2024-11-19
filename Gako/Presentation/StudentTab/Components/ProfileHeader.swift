//
//  ProfileHeader.swift
//  Breesix
//
//  Created by Akmal Hakim on 15/10/24.
//

import SwiftUI

struct ProfileHeader: View {
    // MARK: - Constants
    private let imageSize = UIConstants.Profile.headerImageSize
    private let spacing = UIConstants.Profile.headerSpacing
    private let textColor = UIConstants.Profile.textColor
    private let placeholderColor = UIConstants.Profile.placeholderImageColor
    
    // MARK: - Properties
    let student: Student
    
    var body: some View {
        VStack(spacing: 0) {
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

#Preview {
    ProfileHeader(student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
}
