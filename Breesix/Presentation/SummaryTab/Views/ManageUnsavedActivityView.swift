//  AddUnsavedActivity.swift
//  Breesix
//
//  Created by Rangga Biner on 13/10/24.
//

import SwiftUI
import Mixpanel

struct ManageUnsavedActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var activityText: String
    @State private var showAlert: Bool = false
    
<<<<<<< HEAD:Breesix/Presentation/SummaryTab/Views/AddUnsavedActivityView.swift
    let onSaveActivity: (UnsavedActivity) -> Void
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    @State private var activityText: String = ""
    @State private var selectedStatus: Status = .tidakMelakukan
    @State private var showAlert: Bool = false
    
    
    
=======
    enum Mode: Equatable {
        case add(Student, Date)
        case edit(UnsavedActivity)
        
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
    let onSave: (UnsavedActivity) -> Void
    
    init(mode: Mode, onSave: @escaping (UnsavedActivity) -> Void) {
        self.mode = mode
        self.onSave = onSave
        
        switch mode {
        case .add:
            _activityText = State(initialValue: "")
        case .edit(let activity):
            _activityText = State(initialValue: activity.activity)
        }
    }

>>>>>>> develop:Breesix/Presentation/SummaryTab/Views/ManageUnsavedActivityView.swift
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(isAddMode ? "Tambah Aktivitas" : "Nama Aktivitas")
                    .foregroundStyle(.labelPrimaryBlack)
                    .font(.callout)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 8) {
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
    
    private var isAddMode: Bool {
        switch mode {
        case .add: return true
        case .edit: return false
        }
    }
<<<<<<< HEAD:Breesix/Presentation/SummaryTab/Views/AddUnsavedActivityView.swift
    
    private func saveNewActivity() {
        let newActivity = UnsavedActivity(
            activity: activityText,
            createdAt: selectedDate,
            status: selectedStatus,
            studentId: student.id
        )
        
        // Properties untuk tracking
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_text_length": activityText.count,
            "status": selectedStatus.rawValue,
            "created_at": selectedDate.timeIntervalSince1970,
            "screen": "add_activity",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Track event
        analytics.trackEvent("Activity Created", properties: properties)
        
        onSaveActivity(newActivity)
        onDismiss()
    }
}





=======

    private func saveActivity() {
        switch mode {
        case .add(let student, let selectedDate):
            let newActivity = UnsavedActivity(
                activity: activityText,
                createdAt: selectedDate,
                status: .tidakMelakukan,
                studentId: student.id
            )
            onSave(newActivity)
            
        case .edit(let activity):
            let updatedActivity = UnsavedActivity(
                id: activity.id,
                activity: activityText,
                createdAt: activity.createdAt,
                status: activity.status,
                studentId: activity.studentId
            )
            onSave(updatedActivity)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
}

>>>>>>> develop:Breesix/Presentation/SummaryTab/Views/ManageUnsavedActivityView.swift
#Preview {
    ManageUnsavedActivityView(
        mode: .add(.init(fullname: "Rangga Biner", nickname: "Rangga"), .now),
        onSave: { _ in print("saved activity") }
    )
}
