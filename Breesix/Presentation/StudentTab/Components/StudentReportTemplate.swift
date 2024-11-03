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
            HStack {
                Image("GAKO")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Laporan Harian Murid")
                        .font(.title2)
                        .bold()
                    Text(indonesianFormattedDate(date: date))
                        .font(.body)
                }
            }
            .padding()
            
            HStack(spacing: 16) {
                if let imageData = student.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                }
                
                VStack(alignment: .leading) {
                    Text(student.fullname)
                        .font(.title3)
                        .bold()
                    Text(student.nickname)
                        .font(.body)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Aktivitas")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Aktivitas")
                        Spacer()
                        Text("Keterangan")
                    }
                    .padding()
                    .background(Color.green.opacity(0.2))
                    
                    ForEach(activities) { activity in
                        HStack {
                            Text(activity.activity)
                            Spacer()
                            Text(activity.status == .mandiri ? "Mandiri" : "Dibimbing")
                        }
                        .padding()
                        Divider()
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Catatan:")
                    .font(.headline)
                
                ForEach(notes) { note in
                    Text("• \(note.note)")
                        .font(.body)
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
        .background(Color.gray.opacity(0.1))
    }
}

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
    DailyReportTemplate(student: .init(fullname: "Rangga Biner", nickname: "Rangga"), activities: [.init(activity: "Menjahit", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))], notes: [.init(note: "Anak ini baik banget", student: .init(fullname: "Rangga Biner", nickname: "Rangga"))], date: .now)
}
