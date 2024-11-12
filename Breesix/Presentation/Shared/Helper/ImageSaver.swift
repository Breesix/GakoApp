// ImageSaver.swift
import UIKit

public class ImageSaver: NSObject {
    public static let shared = ImageSaver()
    private override init() {}
    
    private var completionHandler: ((Error?) -> Void)?
    
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
    
    @objc private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer?) {
        completionHandler?(error)
        completionHandler = nil
    }
}
