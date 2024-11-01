//
//  DailyReportCard.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct DailyReportCard: View {
    @ObservedObject var viewModel: StudentTabViewModel
    let activities: [Activity]
    let notes: [Note]
    let student: Student
    let date: Date
    
    let onAddNote: () -> Void
    let onAddActivity: () -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    
    func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(indonesianFormattedDate(date: date))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)
            }
            .padding(.bottom, 19)
            ActivitySection(
                activities: activities,
                onDeleteActivity: onDeleteActivity,
                onStatusChanged: { activity, newStatus in
                    Task {
                        await viewModel.updateActivityStatus(activity, isIndependent: newStatus)
                    }
                }
            )
            
            AddButton(
                action: onAddActivity,
                backgroundColor: .buttonOncard
            )
            
            Divider()
                .frame(height: 1)
                .background(.tabbarInactiveLabel)
                .padding(.bottom, 20)
            
            
            NoteSection(
                notes: notes,
                onEditNote: onEditNote,
                onDeleteNote: onDeleteNote,
                onAddNote: onAddNote
            )
            AddButton(
                action: onAddNote,
                backgroundColor: .buttonOncard
            )
        }
        
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
