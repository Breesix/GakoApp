//
//  ProfileHeader 2.swift
//  Breesix
//
//  Created by Kevin Fairuz on 22/10/24.
//


import SwiftUI

struct ProfileHeaderPreview: View {
    let student: Student
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Profile Image
            if let imageData = student.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 64, height: 64)
                    .background(Color.green.opacity(0.2))
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 64, height: 64)
                    .foregroundColor(.black)
                    .background(Color.green)
                    .clipShape(Circle())
            }
            
            // Name and Nickname
            VStack(alignment: .leading, spacing: 4) {
                Text(student.fullname)
                    .fontWeight(.semibold)
                    .font(.title3)
                    .foregroundColor(.black)
                
                Text(student.nickname)
                    .fontWeight(.regular)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
