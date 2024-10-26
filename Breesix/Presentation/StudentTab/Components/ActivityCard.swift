//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI


struct ActivityCardView: View {
    @ObservedObject var viewModel: StudentTabViewModel
    @State var activities: [Activity]
    let notes: [Note]
    let date: Date
    let onAddNote: () -> Void
    let onAddActivity: () -> Void
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    let student: Student
    
    func indonesianFormattedDate(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "id_ID")
            formatter.dateStyle = .full
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }

    @State private var isShowingNewActivity = false
    @State private var editingActivity: Activity?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(indonesianFormattedDate(date: date))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)
                
                Spacer()
                
                Button("Share", systemImage: "square.and.arrow.up.fill", action: onAddActivity)
                    .frame(width: 34, height: 34)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .foregroundStyle(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .background(Color.buttonOncard)
                    .clipShape(.circle)
            }
            .padding(.bottom, 12)
        
            ActivitySection(
                activities: $activities,
                onEditActivity: { activity in
                    editingActivity = activity
                    isShowingNewActivity = true
                },
                onDeleteActivity: { activity in
                    activities.removeAll(where: { $0.id == activity.id })
                },
                onAddActivity: {
                    editingActivity = Activity(id: UUID(), activity: "", createdAt: Date(), isIndependent: false, student: student )
                    isShowingNewActivity = true
                }
            )
            .padding(.bottom, 16)
            
            Divider()
                .padding(.bottom, 20)
            
            NoteSection(
                notes: notes,
                onEditNote: onEditNote,
                onDeleteNote: onDeleteNote,
                onAddNote: onAddNote
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.white)
        .cornerRadius(20)
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
        VStack(alignment: .leading, spacing: 12) {
            if activities.isEmpty {
                Text("Tidak ada aktivitas untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach($activities, id: \.id) { $activity in
                    ActivityRow(activity: $activity, onEdit: {_ in 
                        onEditActivity(activity)
                    }, onDelete: {_ in 
                        onDeleteActivity(activity)
                    })
                }
            }
            
            Button(action: onAddActivity) {
                Label("Tambah", systemImage: "plus.app.fill")
            }
            .buttonStyle(.bordered)
            .foregroundStyle(Color(red: 0.24, green: 0.24, blue: 0.24))
            .background(Color.buttonOncard)
        }
    }
}





struct ActivityRow: View {
    @Binding var activity: Activity
    let onEdit: (Activity) -> Void
    let onDelete: (Activity) -> Void
    
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
                Text(activity.activity)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(.labelPrimaryBlack)
            
            if let status = activity.isIndependent {
                HStack (spacing: 0) {
                    Picker("Status", selection: $activity.isIndependent) {
                        Text("Mandiri").tag(true as Bool?)
                        Text("Dibimbing").tag(false as Bool?)
                    }
                    .pickerStyle(MenuPickerStyle()) 
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)

                    .padding(.trailing, 8)
                    
                    Button("Hapus", systemImage: "trash.fill", action: {
                        showDeleteAlert = true 
                    })
                    .frame(width: 34, height: 34)
                    .labelStyle(.iconOnly)
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .clipShape(.circle)
                    .alert("Konfirmasi Hapus", isPresented: $showDeleteAlert) {
                        Button("Hapus", role: .destructive) {
                            onDelete(activity)
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

