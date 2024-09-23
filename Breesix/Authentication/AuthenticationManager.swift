//
//  AuthenticationManager.swift
//  Breesix
//
//  Created by Kevin Fairuz on 21/09/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore





final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    func getAuthenticationUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MAKR: SIGN IN EMAIL
extension AuthenticationManager {
    @discardableResult
    func createUser(email: String, password: String, name: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        let teacherID = authDataResult.user.uid
        
        // Save teacher profile in Firestore
        let db = Firestore.firestore()
        let teacherData: [String: Any] = [
            "teacherID": teacherID,
            "name": name,
            "email": email,
            "createdAt": FieldValue.serverTimestamp() // Optional: Timestamp of account creation
        ]
        
        try await db.collection("teachers").document(teacherID).setData(teacherData)
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.reload() // Refresh user to get the latest info
        if !user.isEmailVerified {
            try await sendEmailVerification()
            throw CustomAuthError.emailNotVerified
        }
        
        do {
            try await user.updateEmail(to: email)
        } catch let error as NSError {
            if error.code == AuthErrorCode.operationNotAllowed.rawValue {
                throw CustomAuthError.operationNotAllowed
            } else if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                throw CustomAuthError.emailAlreadyInUse
            } else {
                throw error
            }
        }
    }
    
    private func sendEmailVerification() async throws {
        guard let user = Auth.auth().currentUser else { return }
        try await user.sendEmailVerification()
    }
    
}
// MAKR: SIGN IN SSO
extension AuthenticationManager {
    
    
    func signInWithgGoogle(token: String) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

// Custom error handling
enum CustomAuthError: LocalizedError {
    case emailNotVerified
    case emailAlreadyInUse
    case operationNotAllowed
    
    var errorDescription: String? {
        switch self {
        case .emailNotVerified:
            return "Your email is not verified. Please verify it before making changes."
        case .emailAlreadyInUse:
            return "The email address is already in use by another account."
        case .operationNotAllowed:
            return "Email update is not allowed. Please contact support."
        }
    }
}
