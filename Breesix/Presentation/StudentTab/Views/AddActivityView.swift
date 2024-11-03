//  AddActivity.swift
//  Breesix
//
//  Created by Rangga Biner on 04/10/24.

import SwiftUI

struct AddActivityView: View {
    let student: Student
    let selectedDate: Date
    let onDismiss: () -> Void
    let onSave: (Activity) async -> Void
    
    @State private var activityText: String = ""
    @State private var selectedStatus: Bool?
    @State private var showAlert = false
    
    var body: some View {
        NavigationView {
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
                        selectedStatus = true
                    }
                    Button("Dibimbing") {
                        selectedStatus = false
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
                Text("Aktivitas tidak boleh kosong")
            }
        }
    }
    
    private func getStatusText() -> String {
        if let isIndependent = selectedStatus {
            return isIndependent ? "Mandiri" : "Dibimbing"
        }
        return "Status"
    }

    private func saveNewActivity() {
        let newActivity = Activity(
            activity: activityText,
            createdAt: selectedDate,
            isIndependent: selectedStatus ?? false,
            student: student
        )
        Task {
            await onSave(newActivity)
            onDismiss()
        }
    }
}

#Preview {
    AddActivityView(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), selectedDate: .now, onDismiss: {
        print("dismissed")
    }, onSave: { _ in
        print("saved")
    })
}
