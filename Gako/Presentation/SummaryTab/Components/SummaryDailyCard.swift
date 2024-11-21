//
//  SummryDailyCard.swift
//  Gako
//
//  Created by Kevin Fairuz on 20/11/24.
//

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
        VStack(alignment: .leading, spacing: 12){
            HStack {
                Text("Ringkasan")
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
                HStack {
                    Image(systemName: "sparkles")
                    Text("Dihasilkan oleh AI")
                    
                }
                .padding(.horizontal,4)
                .fontWeight(.semibold)
                .font(.footnote)
                .frame(width: 162, height: 26)
                .background(.green4002)
                .cornerRadius(82)
                .foregroundStyle(.green400)
            }
            
            if dailySummaries.isEmpty {
                Text("Tidak ada rangkuman pada hari ini")
//                    .font(.subheadline)
//                    .fontWeight(.regular)
                    .foregroundColor(Color.labelSecondaryBlack)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
            } else {
                ForEach(dailySummaries, id: \.id) { summary in
                    Text(summary.summary)
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .padding([.top, .bottom],8)
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
