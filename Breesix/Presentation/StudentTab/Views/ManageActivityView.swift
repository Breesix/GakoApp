//  ManageActivityView.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.

import SwiftUI
import Mixpanel

struct ManageActivityView: View {
    @State private var activityText: String
    @State private var showAlert: Bool = false
    @State private var selectedStatus: Status = .dibimbing
    
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    let onSave: (Activity) async -> Void
    let onUpdate: (Activity) -> Void
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    
    enum Mode: Equatable {
        case add
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
    
    init(mode: Mode,
         student: Student,
         selectedDate: Date,
         onDismiss: @escaping () -> Void,
         onSave: @escaping (Activity) async -> Void,
         onUpdate: @escaping (Activity) -> Void) {
        self.mode = mode
        self.student = student
        self.selectedDate = selectedDate
        self.onDismiss = onDismiss
        self.onSave = onSave
        self.onUpdate = onUpdate
        
        switch mode {
        case .add:
            _activityText = State(initialValue: "")
        case .edit(let activity):
            _activityText = State(initialValue: activity.activity)
            _selectedStatus = State(initialValue: activity.status)
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(mode == .add ? "Tambah Aktivitas" : "Edit Aktivitas")
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
                    
                    if mode == .add {
                        StatusMenu(selectedStatus: $selectedStatus)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 34.5)
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(mode == .add ? "Tambah Aktivitas" : "Edit Aktivitas")
                        .foregroundStyle(.labelPrimaryBlack)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { onDismiss() }) {
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
    
    private func saveActivity() {
        switch mode {
        case .add:
            let newActivity = Activity(
                activity: activityText,
                createdAt: selectedDate,
                status: selectedStatus,
                student: student
            )
            
            trackActivityCreation(newActivity)
            
            Task {
                await onSave(newActivity)
                onDismiss()
            }
            
        case .edit(let activity):
            var updatedActivity = activity
            updatedActivity.activity = activityText
            onUpdate(updatedActivity)
            onDismiss()
        }
    }
    
    private func trackActivityCreation(_ activity: Activity) {
        let properties: [String: MixpanelType] = [
            "student_id": student.id.uuidString,
            "activity_text_length": activityText.count,
            "status": selectedStatus.rawValue,
            "created_at": selectedDate.timeIntervalSince1970,
            "screen": "add_activity",
            "timestamp": Date().timeIntervalSince1970
        ]
        analytics.trackEvent("Activity Created", properties: properties)
    }
}

struct StatusMenu: View {
    @Binding var selectedStatus: Status
    
    var body: some View {
        Menu {
            Button("Mandiri") { selectedStatus = .mandiri }
            Button("Dibimbing") { selectedStatus = .dibimbing }
            Button("Tidak Melakukan") { selectedStatus = .tidakMelakukan }
        } label: {
            HStack(spacing: 9) {
                Text(selectedStatus.displayText)
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

private extension Status {
    var displayText: String {
        switch self {
        case .mandiri: return "Mandiri"
        case .dibimbing: return "Dibimbing"
        case .tidakMelakukan: return "Tidak Melakukan"
        }
    }
}

#Preview {
    ManageActivityView(
        mode: .add,
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        selectedDate: .now,
        onDismiss: { print("dismissed") },
        onSave: { _ in print("saved") },
        onUpdate: { _ in print("updated") }
    )
}
