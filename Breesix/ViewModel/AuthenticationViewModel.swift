//
//  AuthenticationViewModel.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//

import Foundation
import FirebaseAuth
import FirebaseCore

enum AuthState {
    case Initialize
    case Login
    case Logout
}


@MainActor
final class AuthenticationViewModel: ObservableObject {
    @Published var authState: AuthState = .Initialize
    
    
    func signInGoole() async throws{
        
        guard let ClientID = FirebaseApp.app()?.options.clientID else {
            throw GoogleSignInError.notViewController
        }
        let helper = SignInGoogleHelper(GIDClientID: ClientID)
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        self.authState = .Login
        
    
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



