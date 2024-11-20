//
//  SummryDailyCard.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

import SwiftUI

struct SummryDailyCard: View {
    let student: Student
    let selectedDate: Date
    
    var dailySummaries: [Summary] {
        student.summaries.filter {
            Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }
    var body: some View {
        VStack {
            HStack {
                Text("Ringkasan")
                
                
            }
            
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
                        .lineLimit(2)
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
    }
}

//#Preview {
//    SummryDailyCard(student: Student, selectedDate: Date)
//}
