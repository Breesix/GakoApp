//
//  StudentReportTemplate.swift
//  Breesix
//
//  Created by Akmal Hakim on 30/10/24.
//

import SwiftUI

struct DailyReportTemplate: View {
    let student: Student
    let activities: [Activity]
    let notes: [Note]
    let date: Date
    
    // A4 dimensions in points (72 points per inch)
    private let a4Width: CGFloat = 595.276
    private let a4Height: CGFloat = 841.89
    
    func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image("gako_logotype")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Laporan Harian Murid")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.labelPrimary)
                    Text(indonesianFormattedDate(date: date))
                        .font(.body)
                        .italic()
                        .foregroundStyle(.secondary)
                        .foregroundStyle(.labelPrimaryBlack)
                }
            }
            .padding()
            
            // Student Info
            ZStack {
                // Main content
                HStack(spacing: 16) {
                    if let imageData = student.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .inset(by: 1.5)
                                    .stroke(.accent, lineWidth: 3)
                            )
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .foregroundColor(.bgSecondary)
                            .clipShape(Circle())
                    }
                    
                    VStack(alignment: .leading) {
                        Text(student.fullname)
                            .font(.title3)
                            .bold()
                            .foregroundStyle(.labelPrimaryBlack)
                        Text(student.nickname)
                            .font(.body)
                            .foregroundStyle(.labelPrimaryBlack)
                    }
                    
                    Spacer()
                }
                
                // Watermark
                HStack {
                    Spacer()
                    Image("gako_wm") // Replace with your desired image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundColor(.gray.opacity(0.1)) // Adjust opacity as needed
                        .padding(.trailing)
                }
            }
            .padding(.leading)
            .frame(height: 90)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.5)
                    .stroke(.green300, lineWidth: 1)
            )
            .padding(.horizontal)
            
            // Activities Table
            VStack(alignment: .leading, spacing: 8) {
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Aktivitas")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        Spacer()
                        Text("Keterangan")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(.green300)
                    
                    ForEach(activities) { activity in
                        HStack {
                            Text(activity.activity)
                                .foregroundStyle(.labelPrimaryBlack)
                            Spacer()
                            Text(activity.isIndependent ?? true ? "Mandiri" : "Dibimbing")
                                .foregroundStyle(.labelPrimaryBlack)
                        }
                        .padding()
                        Divider()
                    }
                }
                .background(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .inset(by: 0.5)
                        .stroke(.green300, lineWidth: 1)
                )
            }
            .padding()
            
            // Notes
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Catatan:")
                        .font(.headline)
                        .foregroundStyle(.labelPrimaryBlack)
                    Spacer()
                }
                ForEach(notes) { note in
                    Text("• \(note.note)")
                        .font(.body)
                        .foregroundStyle(.labelPrimaryBlack)
                }
            }
            .padding()
            
            Spacer()
            
            Text("Dibagikan melalui Aplikasi GAKO")
                .font(.caption)
                .foregroundColor(.gray)
                .padding()
        }
        .frame(width: a4Width, height: a4Height)
        .background(.white)
    }
}

// Extension to handle sharing
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

#Preview {
    let previewStudent = Student(
        fullname: "John Doe",
        nickname: "Johnny",
        imageData: UIImage(systemName: "akmal")?.pngData()
    )
    
    let previewActivities = [
        Activity(activity: "Menulis", isIndependent: true, student: previewStudent),
        Activity(activity: "Membaca", isIndependent: false, student: previewStudent),
        Activity(activity: "Menggambar", isIndependent: true, student: previewStudent)
    ]
    
    let previewNotes = [
        Note(note: "Anak sangat aktif hari ini", student: previewStudent),
        Note(note: "Berhasil menyelesaikan tugas dengan baik", student: previewStudent)
    ]
    
    return DailyReportTemplate(
        student: previewStudent,
        activities: previewActivities,
        notes: previewNotes,
        date: Date()
    )
}
