//  AddUnsavedActivity.swift
//  Breesix
//
//  Created by Rangga Biner on 13/10/24.
//

import SwiftUI
import Mixpanel

struct AddUnsavedActivityView: View {
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    
    let onSaveActivity: (UnsavedActivity) -> Void
    let analytics: InputAnalyticsTracking = InputAnalyticsTracker.shared
    @State private var activityText: String = ""
    @State private var selectedStatus: Status = .tidakMelakukan
    @State private var showAlert: Bool = false
    
    
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Tambah Aktivitas")
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
                .padding(.top, 8)
                
                Spacer()
            }
            .padding(.top, 34.5)
            .padding(.horizontal, 16)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Tambah Aktivitas")
                        .foregroundStyle(.labelPrimaryBlack)
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(.top, 27)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        onDismiss()
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
                            saveNewActivity()
                        }
                    }, label: {
                        Text("Simpan")
                            .font(.body)
                            .fontWeight(.medium)
                    })
                    .padding(.top, 27)
                }
            }
            .alert("Peringatan", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("aktivitas tidak boleh kosong")
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





#Preview {
    AddUnsavedActivityView(
        student: .init(fullname: "Rangga Biner", nickname: "Rangga"),
        selectedDate: .now,
        onDismiss: {
            print("Dismissed")
        },
        onSaveActivity: { _ in
            print("saved activity")
        }
    )
}
