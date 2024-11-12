// ReportGenerator.swift
import SwiftUI

public enum ReportGeneratorError: Error {
    case failedToGenerateSnapshot
    case emptyContent
}

public class ReportGenerator {
    public static let shared = ReportGenerator()
    
    private init() {}
    
    public func generateReport(
        student: Student,
        activities: [Activity],
        notes: [Note],
        date: Date
    ) -> [UIImage] {
        let reportView = DailyReportTemplate(
            student: student,
            activities: activities,
            notes: notes,
            date: date
        )
        
        let totalPages = calculateRequiredPages(activities: activities, notes: notes)
        var pageSnapshots: [UIImage] = []
        
        // Generate snapshot untuk setiap halaman
        for pageIndex in 0..<totalPages {
            let pageView = reportView.reportPage(pageIndex: pageIndex)
                .frame(width: reportView.a4Width, height: reportView.a4Height)
                .background(.white)
            
            if let pageSnapshot = pageView.asSnapshot() {
                pageSnapshots.append(pageSnapshot)
            }
        }
        
        return pageSnapshots
    }
    
    private func calculateRequiredPages(activities: [Activity], notes: [Note]) -> Int {
        let activitiesPages = ceil(Double(max(0, activities.count - 5)) / 10.0)
        let notesPages = ceil(Double(notes.count) / 5.0)
        return 1 + Int(max(activitiesPages, notesPages))
    }
}

// View Extension untuk mengambil snapshot
public extension View {
    func asSnapshot() -> UIImage? {
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

// ImageSaver Helper
public class ImageSaver: NSObject {
    public static let shared = ImageSaver()
    
    private override init() {}
    
    public func saveImage(_ image: UIImage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), continuation.asOpaquePointer)
        }
    }
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeMutableRawPointer) {
        let continuation = Unmanaged<CheckedContinuation<Void, Error>>.fromOpaque(contextInfo).takeRetainedValue()
        if let error = error {
            continuation.resume(throwing: error)
        } else {
            continuation.resume()
        }
    }
}

// Report Sharing Helper
public class ReportSharing {
    public static let shared = ReportSharing()
    
    private init() {}
    
    public func shareToWhatsApp(image: UIImage) -> UIDocumentInteractionController? {
        guard let imageData = image.pngData() else { return nil }
        let tempFile = FileManager.default.temporaryDirectory.appendingPathComponent("report.jpg")
        try? imageData.write(to: tempFile)
        
        let documentInteractionController = UIDocumentInteractionController(url: tempFile)
        documentInteractionController.uti = "net.whatsapp.image"
        return documentInteractionController
    }
    
    public func createShareSheet(for images: [UIImage]) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: images,
            applicationActivities: nil
        )
    }
}
