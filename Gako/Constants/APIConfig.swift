//
//  APIConfig.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//

import Foundation
import CryptoKit

// MARK: - APIConfig
struct APIConfig {
    // MARK: - Token Configuration
    private static let encryptedToken = "YOUR_ENCRYPTED_TOKEN"
    private static let encryptionKey = "YOUR_ENCRYPTION_KEY"
    
    // MARK: - API Tokens
    static var openAIToken: String {
//        #if DEBUG
            return "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"
//        #else
//            return decryptToken(encryptedToken, using: encryptionKey)
//        #endif
    }
    
    static var mixPanelToken: String {
//        #if DEBUG
            return "ba390a7e93c95c0a3b12106167786225"
//        #else
//            return decryptToken(encryptedToken, using: encryptionKey)
//        #endif
    }
    
    // MARK: - API Endpoints
    static let baseURL = "https://api.openai.com/v1"
    static let completionsEndpoint = "\(baseURL)/completions"
    static let chatEndpoint = "\(baseURL)/chat/completions"
    
    // MARK: - Environment
    static let environment: AppEnvironment = {
        #if DEBUG
            return .development
        #else
            return .production
        #endif
    }()
    
    // MARK: - Encryption/Decryption
    private static func encryptToken(_ token: String, using key: String) -> String? {
        guard let keyData = key.data(using: .utf8),
              let tokenData = token.data(using: .utf8) else {
            return nil
        }
        
        let symmetricKey = SymmetricKey(data: keyData)
        
        do {
            let sealedBox = try AES.GCM.seal(tokenData, using: symmetricKey)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    private static func decryptToken(_ encrypted: String, using key: String) -> String {
        // In production, implement proper decryption
        // This is just a basic example
        guard let keyData = key.data(using: .utf8),
              let encryptedData = Data(base64Encoded: encrypted) else {
            return "Invalid Token"
        }
        
        let symmetricKey = SymmetricKey(data: keyData)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            if let decryptedString = String(data: decryptedData, encoding: .utf8) {
                return decryptedString
            }
        } catch {
            print("Decryption error: \(error)")
        }
        
        return "Decryption Failed"
    }
}

// MARK: - Environment Enum
enum AppEnvironment {
    case development
    case staging
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "https://api-dev.openai.com/v1"
        case .staging:
            return "https://api-staging.openai.com/v1"
        case .production:
            return "https://api.openai.com/v1"
        }
    }
    
    var isDebug: Bool {
        switch self {
        case .development, .staging:
            return true
        case .production:
            return false
        }
    }
}

// MARK: - API Configuration
extension APIConfig {
    struct Configuration {
        static let timeoutInterval: TimeInterval = 30
        static let maxRetries = 3
        static let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    }
    
    struct Headers {
        static func defaultHeaders(token: String) -> [String: String] {
            [
                "Authorization": "Bearer \(token)",
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        }
    }
}

// MARK: - API Endpoints Enum
enum APIEndpoints {
    case chat
    case completions
    case models
    
    var path: String {
        switch self {
        case .chat:
            return "/chat/completions"
        case .completions:
            return "/completions"
        case .models:
            return "/models"
        }
    }
    
    var url: URL? {
        URL(string: APIConfig.baseURL + path)
    }
}
