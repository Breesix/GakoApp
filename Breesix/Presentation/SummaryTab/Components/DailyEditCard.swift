//
//  DailyEditCard.swift
//  Breesix
//
//  Created by Rangga Biner on 10/11/24.
//

import SwiftUI

struct DailyEditCard: View {
    let date: Date
    let activities: [Activity]
    let notes: [Note]
    @Binding var editedActivities: [UUID: (String, Status, Date)]
    @Binding var editedNotes: [UUID: (String, Date)]
    let onDeleteActivity: (Activity) -> Void
    let onDeleteNote: (Note) -> Void
    
    @State private var newActivities: [(id: UUID, activity: String, status: Status)] = []
    @State private var newNotes: [(id: UUID, note: String)] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !activities.isEmpty || !newActivities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("AKTIVITAS")
                        .font(.callout)
                        .fontWeight(.bold)
                    ForEach(activities) { activity in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Aktivitas \(activities.firstIndex(of: activity)! + 1)")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .foregroundColor(.labelPrimaryBlack)
                                
                                Spacer()
                                
                                Image("custom.trash.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34)
                                    .onTapGesture {
                                        onDeleteActivity(activity)
                                    }
                            }
                            HStack {
                                TextField("Aktivitas", text: makeValueBinding(for: activity))
                                    .font(.body)
                                    .foregroundColor(.labelPrimaryBlack)
                                    .padding(.vertical, 7)
                                    .padding(.horizontal, 14)
                                    .background(.cardFieldBG)
                                    .cornerRadius(8)
                                
                            }
                            StatusPicker(status: makeStatusBinding(for: activity)) { newStatus in
                                editedActivities[activity.id] = (activity.activity, newStatus, date)
                            }
                        }
                    }
                    ForEach(newActivities, id: \.id) { newActivity in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Aktivitas \(activities.count + newActivities.firstIndex(where: { $0.id == newActivity.id })! + 1)")
                                    .font(.callout)
                                    .fontWeight(.bold)
                                    .foregroundColor(.labelPrimaryBlack)
                                
                                Spacer()
                                
                                Image("custom.trash.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34)
                                    .onTapGesture {
                                        if let index = newActivities.firstIndex(where: { $0.id == newActivity.id }) {
                                            newActivities.remove(at: index)
                                            editedActivities.removeValue(forKey: newActivity.id)
                                        }
                                    }
                                
                            }
                            HStack {
                                TextField("Aktivitas", text: Binding(
                                    get: { editedActivities[newActivity.id]?.0 ?? newActivity.activity },
                                    set: { newValue in
                                        let status = editedActivities[newActivity.id]?.1 ?? newActivity.status
                                        editedActivities[newActivity.id] = (newValue, status, date)
                                    }
                                ))
                                .font(.body)
                                .foregroundColor(.labelPrimaryBlack)
                                .padding(.vertical, 7)
                                .padding(.horizontal, 14)
                                .background(.cardFieldBG)
                                .cornerRadius(8)
                            }
                            
                            StatusPicker(status: Binding(
                                get: { editedActivities[newActivity.id]?.1 ?? newActivity.status },
                                set: { newValue in
                                    let currentText = editedActivities[newActivity.id]?.0 ?? newActivity.activity
                                    editedActivities[newActivity.id] = (currentText, newValue, date)
                                }
                            )) { newStatus in
                                let currentText = editedActivities[newActivity.id]?.0 ?? newActivity.activity
                                editedActivities[newActivity.id] = (currentText, newStatus, date)
                            }
                        }
                    }
                }
            } else {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
            }
            
            Button(action: {
                let newId = UUID()
                newActivities.append((id: newId, activity: "", status: .tidakMelakukan))
                editedActivities[newId] = ("", .tidakMelakukan, date)
            }) {
                Label("Tambah", systemImage: "plus.app.fill")
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .font(.footnote)
            .fontWeight(.regular)
            .foregroundStyle(.buttonPrimaryLabel)
            .background(.buttonOncard)
            .cornerRadius(8)
            
            Divider()
                .frame(height: 1)
                .background(.tabbarInactiveLabel)
                .padding(.vertical, 8)
            
            if !notes.isEmpty || !newNotes.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CATATAN")
                        .font(.callout)
                        .fontWeight(.bold)
                    ForEach(notes) { note in
                        HStack {
                            TextField("Catatan", text: makeNoteBinding(for: note))
                                .font(.body)
                                .foregroundColor(.labelPrimaryBlack)
                                .padding(.vertical, 7)
                                .padding(.horizontal, 14)
                                .background(.cardFieldBG)
                                .cornerRadius(8)
                            
                            Button(action: { onDeleteNote(note) }) {
                                Image("custom.trash.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34)
                            }
                        }
                    }
                    ForEach(newNotes, id: \.id) { newNote in
                        HStack {
                            TextField("Catatan", text: Binding(
                                get: { editedNotes[newNote.id]?.0 ?? newNote.note },
                                set: { editedNotes[newNote.id] = ($0, date) }
                            ))
                            .font(.body)
                            .foregroundColor(.labelPrimaryBlack)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 14)
                            .background(.cardFieldBG)
                            .cornerRadius(8)
                            
                            Button(action: {
                                if let index = newNotes.firstIndex(where: { $0.id == newNote.id }) {
                                    newNotes.remove(at: index)
                                    editedNotes.removeValue(forKey: newNote.id)
                                }
                            }) {
                                Image("custom.trash.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34)
                            }
                        }
                    }
                }
            } else {
                Text("Tidak ada catatan untuk tanggal ini")
                    .foregroundColor(.labelSecondary)
            }
            
            Button(action: {
                let newId = UUID()
                newNotes.append((id: newId, note: ""))
                editedNotes[newId] = ("", date)
            }) {
                Label("Tambah", systemImage: "plus.app.fill")
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 14)
            .font(.footnote)
            .fontWeight(.regular)
            .foregroundStyle(.buttonPrimaryLabel)
            .background(.buttonOncard)
            .cornerRadius(8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(20)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    private func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func makeValueBinding(for activity: Activity) -> Binding<String> {
        Binding(
            get: { editedActivities[activity.id]?.0 ?? activity.activity },
            set: { newValue in
                let status = editedActivities[activity.id]?.1 ?? activity.status
                editedActivities[activity.id] = (newValue, status, date)
            }
        )
    }
    
    private func makeStatusBinding(for activity: Activity) -> Binding<Status> {
        Binding(
            get: { editedActivities[activity.id]?.1 ?? activity.status },
            set: { newValue in
                let text = editedActivities[activity.id]?.0 ?? activity.activity
                editedActivities[activity.id] = (text, newValue, date)
            }
        )
    }
    
    private func makeNoteBinding(for note: Note) -> Binding<String> {
        Binding(
            get: { editedNotes[note.id]?.0 ?? note.note },
            set: { editedNotes[note.id] = ($0, date) }
        )
    }
}
