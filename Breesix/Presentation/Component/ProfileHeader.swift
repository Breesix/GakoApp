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
                    .foregroundColor(.white)
                    .background(Color.green)
                    .clipShape(Circle())
            }
            
            // Name and Nickname
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

// Custom shape to round specific corners
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
//struct ProfileHeader: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            Spacer()
//            HStack(alignment: .center) {
//                Image(systemName: "checkmark")
//                  .resizable()
//                  .frame(width: 64, height: 64)
//                  .foregroundColor(.white)
//                  .padding(20)
//                  .background(Color.green)
//                  .clipShape(Circle())
//                VStack(alignment: .leading, spacing: 4) {
//                    // Title3/Emphasized
//                    Text("Muhammad Akmal Al Hakim")
//                        .fontWeight(.semibold)
//                        .font(.title3)
//                      .foregroundColor(.white)
//                      .frame(maxWidth: .infinity, alignment: .topLeading)
//                    Text("Akmal")
//                        .fontWeight(.regular)
//                        .font(.subheadline)
//                      .foregroundColor(.white)
//                      .frame(maxWidth: .infinity, alignment: .topLeading)
//                }
//                .padding(0)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//            .frame(maxWidth: .infinity, alignment: .center)
//        }
//        .padding(.horizontal, 0)
//        .padding(.top, 0)
//        .padding(.bottom, 12)
//        .frame(maxWidth: .infinity, alignment: .topLeading)
//        .background(Color(red: 0.33, green: 0.49, blue: 0.29))
//        .cornerRadius(16)
//        .edgesIgnoringSafeArea(.top)
//        Spacer()
//    }
//}
//
//#Preview {
//    ProfileHeader()
//}
