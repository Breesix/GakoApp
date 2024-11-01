//
//  ProfileHeader 2.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/10/24.
//


import SwiftUI

struct ProfileHeaderPreview: View {
    let student: Student
    let hasDefaultActivities: Bool
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let imageData = student.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 47, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 47, height: 50)
                    .foregroundColor(Color.bgSecondary)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(student.fullname)
                    .fontWeight(.semibold)
                    .font(.body)
                    .foregroundColor(.labelPrimaryBlack)
                
                
                Text(student.nickname)
                    .fontWeight(.regular)
                    .font(.subheadline)
                    .foregroundColor(.labelPrimaryBlack)
                
            }
            Spacer()
            if hasDefaultActivities {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orangeClickAble)
                    .frame(alignment: .trailing)
            }
            
        }
        
    }
}

#Preview {
    ProfileHeaderPreview(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), hasDefaultActivities: true)
}
