//
//  StudentSummaryCard.swift
//  Breesix
//
//  Created by Rangga Biner on 24/10/24.
//

import SwiftUI

struct StudentSummaryCard: View {
    let student: Student
    let selectedDate: Date
    
    var dailySummaries: [Summary] {
        student.summaries.filter {
            Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if let imageData = student.imageData {
                    Image(uiImage: UIImage(data: imageData)!)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                        .background(.green600)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(.green600, lineWidth: 1)
                        }
                }
                Text(student.fullname)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .padding(8)
            }
            .font(.body)
            .fontWeight(.semibold)
            
            if dailySummaries.isEmpty {
                Text("Tidak ada rangkuman pada hari ini")
                    .font(.footnote)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .background(.cardFieldBG)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                ForEach(dailySummaries, id: \.id) { summary in
                    Text(summary.summary)
                        .font(.footnote)
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .background(.cardFieldBG)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.cardFieldStroke, lineWidth: 1)
                        )
                }
            }
        }
        .foregroundStyle(.labelPrimaryBlack)
        .padding(12)
        .background(.white)
        .cornerRadius(12)
    }
}

#Preview {
    StudentSummaryCard(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), selectedDate: Date.now)
}
