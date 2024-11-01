//
//  SummaryCard.swift
//  Breesix
//
//  Created by Rangga Biner on 24/10/24.
//

import SwiftUI

struct SummaryCard: View {
    let student: Student
    let selectedDate: Date
    
    var dailySummaries: [Summary] {
        student.summaries.filter {
            Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack (spacing: 10) {
                if let imageData = student.imageData {
                    Image(uiImage: UIImage(data: imageData)!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(Color.bgSecondary)
                        .clipShape(Circle())
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
                    .fontWeight(.regular)
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
    SummaryCard(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), selectedDate: Date.now)
}
