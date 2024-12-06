//
//  SummaryDailyCard.swift
//  Gako
//
//  Created by Rangga Biner on 24/10/24.
//
//  Description: A view that displays the daily summary for a student.
//  Usage: Use this view to show a summary of a student's activities for a specific day.

import SwiftUI

struct SummaryDailyCard: View {
    let student: Student
    let selectedDate: Date
    
    var dailySummaries: [Summary] {
        student.summaries.filter {
            Calendar.current.isDate($0.createdAt, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Ringkasan")
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
                HStack {
                    Image(systemName: "sparkles")
                    Text("Dihasilkan oleh AI")
                }
                .padding(.horizontal, 4)
                .fontWeight(.semibold)
                .font(.footnote)
                .frame(width: 162, height: 26)
                .background(.green4002)
                .cornerRadius(82)
                .foregroundStyle(.green400)
            }
            
            if dailySummaries.isEmpty {
                Text("Tidak ada rangkuman pada hari ini")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            } else {
                ForEach(dailySummaries, id: \.id) { summary in
                    Text(summary.summary)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .padding([.top, .bottom], 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 19)
        .padding(.bottom, 16)
        .background(.white)
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    SummaryDailyCard(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), selectedDate: Date.now)
}
