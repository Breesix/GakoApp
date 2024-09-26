//
//  AuthenticationManager.swift
//  Breesix
//
//  Created by Kevin Fairuz on 21/09/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
    case apple = "appleID"
}


final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    func getAuthenticationUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    func getProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
                
        }
        return providers
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
    
        
    // AuthenticationManager.swift

    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResult) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        let authDataResult = try await signIn(credential: credential)
        
        // Save teacher profile in Firestore
        let db = Firestore.firestore()
        let teacherData: [String: Any] = [
            "name": tokens.fullname ?? "Unknown", // Use name from Google Sign-In
            "email": tokens.email ?? "Unknown", // Use email from Google Sign-In
            "profileImageUrl": tokens.profileImageUrl?.absoluteString ?? "", // Save profile image URL
            "createdAt": FieldValue.serverTimestamp() // Optional: Timestamp of account creation
        ]
        
        try await db.collection("teachers").document(authDataResult.uid).setData(teacherData, merge: true)
        return authDataResult
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
