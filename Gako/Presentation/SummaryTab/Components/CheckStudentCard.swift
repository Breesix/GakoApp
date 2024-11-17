//
//  CheckStudentCard.swift
//  Breesix
//
//  Created by Rangga Biner on 13/11/24.
//

import SwiftUI

struct CheckStudentCard: View {
    let student: Student
    let onDelete: () -> Void
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .center, spacing: 8) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 104, height: 104)
                    .background(
                        ZStack {
                            Group {
                                if let imageData = student.imageData, let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 104, height: 104)
                                        .clipped()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 104, height: 104)
                                        .foregroundStyle(.bgSecondary)
                                }
                            }
                            .overlay(isSelected ? Circle().foregroundStyle(.bgSecondary.opacity(0.3)) : nil)

                            
                            if isSelected {
                                Image("checkmarkCustom")
                                    .resizable()
                                    .frame(width: 62, height: 62)
                                    .foregroundColor(.white)
                            }
                        }
                    )
                    .clipShape(.circle)
                
                VStack(alignment: .center, spacing: 8) {
                    Text(student.nickname)
                        .font(.body)
                        .foregroundStyle(.black)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 21, maxHeight: 21, alignment: .center)
                }
                .padding(.horizontal, 0)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .top)
                .background(.white)
                .cornerRadius(32)
            }
        }
        .onTapGesture {
            onTap()
        }
        .contextMenu {
            Button(action: onDelete) {
                Text("Delete")
                Image(systemName: "trash")
            }
        }
    }
}

#Preview {
    CheckStudentCard(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), onDelete: { print("deleted") }, isSelected: true, onTap: { print("tapped") } )
}
