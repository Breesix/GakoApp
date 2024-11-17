//
//  ProcessingError.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//
import Foundation

enum ProcessingError: Error {
    case noStudentData
    case noContent
    case insufficientInformation
    case apiError

    var localizedDescription: String {
        switch self {
        case .noStudentData:
            return "Tidak ada data murid tersedia."
        case .noContent:
            return "Tidak ada konten dalam respons."
        case .insufficientInformation:
            return "Refleksi tidak mengandung informasi yang cukup tentang aktivitas murid. Mohon berikan detail lebih spesifik."
        case .apiError:
            return "api error"
        }
    }
}
