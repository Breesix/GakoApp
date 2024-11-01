//
//  ProfileHeader.swift
//  Breesix
//
//  Created by Akmal Hakim on 15/10/24.
//

import SwiftUI

struct ProfileHeader: View {
    let student: Student
    
    var body: some View {
            VStack(spacing: 0) {
                HStack(alignment:.center, spacing: 16) {
                    if let imageData = student.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .foregroundColor(Color.bgSecondary)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(student.fullname)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.labelPrimaryBlack)
                            .fontWeight(.semibold)
                        
                        Text(student.nickname)
                            .font(.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.labelPrimaryBlack)
                    }
                    Spacer()
                }
            }
        }
}

#Preview {
    ProfileHeader(student: .init(fullname: "Rangga Biner", nickname: "Rangga"))
}
