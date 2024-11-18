//
//  ReportGeneratorError.swift
//  Breesix
//
//  Created by Kevin Fairuz on 12/11/24.
//
//  Description: Snapshot for generate image and share functionality
//  Usage: Use this class for snapshot
//

import SwiftUI

public class SnapshotHelper {
    public static let shared = SnapshotHelper()
    private init() {}
    
    public func generateSnapshot(from view: some View, size: CGSize) -> UIImage? {
        let controller = UIHostingController(rootView: view)
        let view = controller.view
        
        view?.bounds = CGRect(origin: .zero, size: size)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
    
    public func saveImage(_ image: UIImage) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            UIImageWriteToSavedPhotosAlbum(
                image,
                self,
                #selector(saveCompleted),
                nil
            )
            self.completionHandler = { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
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
    
    private var completionHandler: ((Error?) -> Void)?
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        completionHandler?(error)
        completionHandler = nil
    }
}
