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
        HStack(alignment: .center, spacing: 12) {
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
                    .foregroundColor(.white)
                    .background(Color.green)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(student.fullname)
                    .fontWeight(.semibold)
                    .font(.title3)
                    .foregroundColor(.white)
                
                Text(student.nickname)
                    .fontWeight(.regular)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color(red: 0.43, green: 0.64, blue: 0.32)
                .clipShape(
                    RoundedCorner(radius: 16, corners: [.bottomLeft, .bottomRight])
                )
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
