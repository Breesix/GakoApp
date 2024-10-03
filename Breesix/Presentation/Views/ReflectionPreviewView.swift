//
//  ReflectionPreviewView.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import SwiftUI

struct ReflectionPreviewView: View {
    @ObservedObject var viewModel: StudentListViewModel
    @Environment(\.presentationMode) var presentationMode
    let recentActivities: [Activity]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.students) { student in
                    let studentActivities = recentActivities.filter { $0.student?.id == student.id }
                    if !studentActivities.isEmpty {
                        Section(header: Text(student.fullname)) {
                            ForEach(studentActivities.sorted(by: { $0.createdAt > $1.createdAt })) { activity in
                                VStack(alignment: .leading) {
                                    Text(activity.generalActivity)
                                    Text("Tanggal: \(activity.createdAt, formatter: itemFormatter)")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Preview Refleksi")
            .navigationBarItems(trailing: Button("Selesai") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}