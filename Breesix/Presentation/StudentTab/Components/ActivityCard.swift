//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI


struct ActivityCardView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @State var activities: [Activity] // Use @State to enable updates
    let notes: [Note]
    let onAddNote: () -> Void
    let onAddActivity: () -> Void
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let student: Student
    
    @State private var isShowingNewActivity = false
    @State private var editingActivity: Activity?

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            ActivitySection(
                activities: $activities,
                onEditActivity: { activity in
                    // Show sheet to edit activity
                    editingActivity = activity
                    isShowingNewActivity = true
                },
                onDeleteActivity: { activity in
                    activities.removeAll(where: { $0.id == activity.id })
                },
                onAddActivity: {
                    // Show sheet to add a new activity
                    editingActivity = Activity(id: UUID(), activity: "", createdAt: Date(), isIndependent: false, student: student )
                    isShowingNewActivity = true
                }
            )
            
            NoteSection(
                notes: notes,
                onEditNote: onEditNote,
                onDeleteNote: onDeleteNote,
                onAddNote: onAddNote
            )
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .sheet(isPresented: $isShowingNewActivity) {
            if let activity = editingActivity {
                NewActivityView(
                    viewModel: viewModel, // Pass your view model
                    student: Student(id: UUID(), fullname: "", nickname: ""), // Pass your student
                    selectedDate: Date(),
                    onDismiss: {
                        isShowingNewActivity = false
                    }
                )
            }
        }
    }
}




struct ActivitySection: View {
    @Binding var activities: [Activity] 
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onAddActivity: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if activities.isEmpty {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach($activities, id: \.id) { $activity in // Pass Binding to ActivityRow
                    ActivityRow(activity: $activity, onEdit: {_ in 
                        onEditActivity(activity) // Passing the activity object back to the parent
                    }, onDelete: {_ in 
                        onDeleteActivity(activity) // Trigger delete
                    })
                }
            }
            
            Button(action: onAddActivity) { // This button calls the add activity action
                Label("Tambah Aktivitas", systemImage: "plus.app.fill")
            }
            .buttonStyle(.bordered)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green, lineWidth: 0.5)
        )
    }
}





struct ActivityRow: View {
    @Binding var activity: Activity // Use Binding to reflect changes
    let onEdit: (Activity) -> Void
    let onDelete: (Activity) -> Void
    
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack {
                Text(activity.activity)
                    .font(.callout)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            
            if let status = activity.isIndependent {
                HStack {
                    
                    Picker("Status", selection: $activity.isIndependent) {
                        Text("Mandiri").tag(true as Bool?)
                        Text("Dibimbing").tag(false as Bool?)
                    }
                    .pickerStyle(MenuPickerStyle()) 
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)

                    Spacer()

                    // Delete Button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Image("custom.trash.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34)
                    }
                    .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                        Button("Hapus", role: .destructive) {
                            onDelete(activity) // Delete confirmed
                        }
                        Button("Batal", role: .cancel) { }
                    } message: {
                        Text("Apakah kamu yakin ingin menghapus aktivitas ini?")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contextMenu {
            Button("Edit") { onEdit(activity) }
            Button("Hapus", role: .destructive) {
                showDeleteAlert = true // Show alert for context menu delete
            }
        }
    }
}

    

struct NoteDetailRow: View {
    let note: Note
    let onEdit: (Note) -> Void
    let onDelete: (Note) -> Void
    
    @State private var showDeleteAlert = false
    
    var body: some View {
        HStack {
            Text(note.note)
                .font(.subheadline)
                .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(8)
                .contextMenu {
                    Button("Edit") { onEdit(note) }
                }
            
            Spacer()
            
            Button(action: {
                showDeleteAlert = true
            }) {
                Image("custom.trash.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34)
            }
            .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                Button("Hapus", role: .destructive) {
                    onDelete(note) // Delete confirmed
                }
                Button("Batal", role: .cancel) { }
            } message: {
                Text("Apakah kamu yakin ingin menghapus catatan ini?")
            }
        }
    }
}

