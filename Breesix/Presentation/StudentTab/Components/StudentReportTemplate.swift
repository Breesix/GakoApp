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
    
     let a4Width: CGFloat = 595.276
     let a4Height: CGFloat = 841.89
    
    @State private var numberOfPages: Int = 1
    
    func indonesianFormattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateFormat = "EEEE, d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    var body: some View {
        TabView {
            ForEach(0..<calculateRequiredPages(), id: \.self) { pageIndex in
                reportPage(pageIndex: pageIndex)
                    .frame(width: a4Width, height: a4Height)
                    .background(.white)
            }
        }
        .tabViewStyle(.page)
    }
    
    func reportPage(pageIndex: Int) -> some View {
        VStack(spacing: 0) {
            // Header
            reportHeader
            
            if pageIndex == 0 {
                // Student Info
                studentInfo
                
                // Summary Section
                summarySection
                
                // First page activities (max 5)
                if !activities.isEmpty {
                    activitySection(Array(activities.prefix(5)))
                }
            } else {
                // Activities for subsequent pages (max 10 per page)
                let startIndex = 5 + (pageIndex - 1) * 10
                let pageActivities = Array(activities.dropFirst(startIndex).prefix(10))
                if !pageActivities.isEmpty {
                    activitySection(pageActivities)
                }
                
                // Notes section (only shown after all activities)
                if pageActivities.isEmpty {
                    let notesStartIndex = (pageIndex - 1) * 5
                    let pageNotes = Array(notes.dropFirst(notesStartIndex).prefix(5))
                    if !pageNotes.isEmpty {
                        noteSection(notes: pageNotes)
                    }
                }
            }
            
            Spacer()
            
            // Footer
            reportFooter(pageNumber: pageIndex + 1)
        }
    }
    
    private var reportHeader: some View {
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
    }
    
    private var studentInfo: some View {
        ZStack {
            HStack(spacing: 16) {
                if let imageData = student.imageData, let uiImage = UIImage(data: imageData) {
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
            
            HStack {
                Spacer()
                Image("gako_wm")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray.opacity(0.1))
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
    }
    
    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Ringkasan:")
                    .font(.headline)
                    .foregroundStyle(.labelPrimaryBlack)
                Spacer()
            }
            
            if let summary = student.summaries.first(where: { Calendar.current.isDate($0.createdAt, inSameDayAs: date) }) {
                Text(summary.summary)
                    .font(.body)
                    .foregroundStyle(.labelPrimaryBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.monochrome100)
                    .cornerRadius(8)
            } else {
                Text("Tidak ada ringkasan untuk hari ini")
                    .font(.body)
                    .foregroundStyle(.labelPrimaryBlack)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.monochrome100)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
    
    private func activitySection(_ activities: [Activity]) -> some View {
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
                        Text(activity.status.rawValue) 
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
    }
    
    private func noteSection(notes: [Note]) -> some View {
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
    }
    
    private func reportFooter(pageNumber: Int) -> some View {
        HStack {
            Text("Dibagikan melalui Aplikasi GAKO")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text("Halaman \(pageNumber) dari \(calculateRequiredPages())")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
     func calculateRequiredPages() -> Int {
        let activitiesPages = ceil(Double(max(0, activities.count - 5)) / 10.0)
        let notesPages = ceil(Double(notes.count) / 5.0)
        return 1 + Int(max(activitiesPages, notesPages))
    }
}


extension View {
    func snapshot() -> UIImage? {
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
    DailyReportTemplate(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), activities: [.init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))], notes: [.init(note: "Anak ini baik banget", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))], date: .now)
}
