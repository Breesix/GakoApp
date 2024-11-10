//  ManageActivityView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.

import SwiftUI
import Mixpanel

struct ManageActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var activityText: String = ""
    @State private var showAlert: Bool = false
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    @State private var selectedStatus: Status = .dibimbing
    
    enum Mode: Equatable {
        case add(Student, Date)
        case edit(Activity)
        
        static func == (lhs: Mode, rhs: Mode) -> Bool {
            switch (lhs, rhs) {
            case (.add, .add):
                return true
            case let (.edit(activity1), .edit(activity2)):
                return activity1.id == activity2.id
            default:
                return false
            }
        }
    }
    
    let mode: Mode
    let onSave: (Activity) async -> Void
    
    init(mode: Mode, onSave: @escaping (Activity) async -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        switch mode {
        case .add:
            _activityText = State(initialValue: "")
        case .edit(let activity):
            _activityText = State(initialValue: activity.activity)
        }
    }
    
    private var student: Student {
        switch mode {
        case .add(let student, _):
            return student
        case .edit(let activity):
            // Since student is optional in the Activity class, we need to safely unwrap it
            guard let student = activity.student else {
                // Handle the case where student is nil - you might want to show an error or provide a default
                fatalError("Activity must have an associated student")
            }
            return student
        }
    }
    
    private var selectedDate: Date {
        switch mode {
        case .add(_, let date):
            return date // Menggunakan tanggal yang diteruskan dari DayEditCard
        case .edit(let activity):
            return activity.createdAt
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(isAddMode ? "Tambah Aktivitas" : "Nama Aktivitas")
                    .foregroundStyle(.labelPrimaryBlack)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    ZStack(alignment: .leading) {
                        if activityText.isEmpty {
                            Text("Tuliskan aktivitas murid...")
                                .foregroundStyle(.labelTertiary)
                                .font(.body)
                                .fontWeight(.regular)
                                .padding(.horizontal, 11)
                                .padding(.vertical, 9)
                        }
                        
                        TextField("", text: $activityText)
                            .foregroundStyle(.labelPrimaryBlack)
                            .font(.body)
                            .fontWeight(.regular)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 9)
                    }
                    .background(.cardFieldBG)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.monochrome50, lineWidth: 0.5)
                    )
                    
                    if isAddMode {
                        Menu {
                            Button("Mandiri") {
                                selectedStatus = .mandiri
                            }
                            Button("Dibimbing") {
                                selectedStatus = .dibimbing
                            }
                            Button("Tidak Melakukan") {
                                selectedStatus = .tidakMelakukan
                            }
                        } label: {
                            HStack(spacing: 9) {
                                Text(getStatusText())
                                Image(systemName: "chevron.up.chevron.down")
                            }
                            .font(.body)
                            .fontWeight(.regular)
                            .foregroundColor(.labelPrimaryBlack)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .background(.statusSheet)
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 34.5)
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(isAddMode ? "Tambah Aktivitas" : "Edit Aktivitas")
                        .foregroundStyle(.labelPrimaryBlack)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Kembali")
                        }
                        .font(.body)
                        .fontWeight(.medium)
                    }
                    .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if activityText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            showAlert = true
                        } else {
                            saveActivity()
                        }
                    }) {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 27)
                }
            }
            .alert("Peringatan", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Aktivitas tidak boleh kosong")
            }
        }
    }
    
    private func getStatusText() -> String {
        switch selectedStatus {
        case .mandiri:
            return "Mandiri"
        case .dibimbing:
            return "Dibimbing"
        case .tidakMelakukan:
            return "Tidak Melakukan"
        }
    }
    
    private var isAddMode: Bool {
        switch mode {
        case .add:
            return true
        case .edit:
            return false
        }
    }
    
    private func saveActivity() {
        if isAddMode {
            saveNewActivity()
        } else {
            saveEditedActivity()
        }
    }
    
    private func saveNewActivity() {
        let newActivity = Activity(
            activity: activityText,
            createdAt: selectedDate, // Menggunakan tanggal yang diteruskan
            status: selectedStatus,
            student: student
        )
        
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_text_length": activityText.count,
            "status": selectedStatus.rawValue,
            "created_at": selectedDate.timeIntervalSince1970,
            "screen": "add_activity",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        analytics.trackEvent("Activity Created", properties: properties)
        
        Task {
            await onSave(newActivity)
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func saveEditedActivity() {
           if case .edit(let activity) = mode {
               guard let student = activity.student else { return }
               
               let updatedActivity = Activity(
                   id: activity.id,
                   activity: activityText,
                   createdAt: activity.createdAt, // Mempertahankan tanggal asli
                   status: activity.status,
                   student: student
               )
               
               Task {
                   await onSave(updatedActivity)
                   presentationMode.wrappedValue.dismiss()
               }
           }
       }
}

#Preview {
    ManageActivityView(
        mode: .add(.init(fullname: "Rangga Biner", nickname: "Rangga"), .now)
    ) { _ in }
}
