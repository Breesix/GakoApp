//
//  StudentHeaderView.swift
//  Breesix
//
//  Created by Akmal Hakim on 10/10/24.
//

import SwiftUI

struct StudentHeaderView: View {
    let student: Student
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if let imageData = student.imageData {
                Image(uiImage: UIImage(data: imageData)!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text(student.nickname)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(student.fullname)
                    .font(.subheadline)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.leading, 16)
        .padding(.trailing, 32)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
    }
}
