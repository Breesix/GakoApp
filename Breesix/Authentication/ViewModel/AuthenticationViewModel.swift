//
//  AuthenticationViewModel.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

enum AuthState {
    case Initialize
    case Login
    case Logout
}


@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authState: AuthState = .Initialize
    
    
    func signInGoole() async throws{
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        //gidSignResult.description
        
        guard let idToken: String = gidSignResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignResult.user.accessToken.tokenString
        
    
    }
        
    init() {
        self.checkUserLoggedIn()
    }
    
    func checkUserLoggedIn() {
        Auth.auth().addStateDidChangeListener { auth, user in
            self.authState = user != nil ? .Login : .Logout
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            authState = .Logout
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

}



