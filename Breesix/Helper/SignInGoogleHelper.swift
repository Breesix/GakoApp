//
//  SignInGoogleHelper.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift


final class SignInGoogleHelper {
    
    init(GIDClientID: String) {
        let config = GIDConfiguration(clientID: GIDClientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    @MainActor
    func signIn() async throws -> GoogleSignInResult {
        guard let topVC = Utilities.shared.topViewController() else {
            throw GoogleSignInError.notViewController
        }
        let gidSignResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        
        guard let idToken = gidSignResult.user.idToken?.tokenString else {
            throw GoogleSignInError.badServerResponse
        }
        
        guard let result = GoogleSignInResult(result: gidSignResult) else {
            throw GoogleSignInError.badServerResponse
        }
        
        return result
    }
    

}

enum GoogleSignInError: LocalizedError {
        case notViewController
        case badServerResponse
        
        var errorDescription: String? {
            switch self {
            case .notViewController:
                return "Could not find a view controller to present the Google Sign In UI."
            case .badServerResponse:
                return "Could not get a valid response from the Google Sign In API."
            }
        }
    }
