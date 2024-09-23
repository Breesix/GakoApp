//
//  SignInEmailView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 21/09/24.
//

import SwiftUI
import FirebaseAuth

final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var name = "" // Add name for profile creation
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty, !name.isEmpty else {
            print("Please provide a name, email, and password.")
            return	
        }
        
        try await AuthenticationManager.shared.createUser(email: email, password: password, name: name)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("Please provide an email and password.")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}




struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    @State private var errorMessage: String = "" // For displaying error messages

    var body: some View {
        VStack {
            // TextFields for inputting email and password
            TextField("Email...", text: $viewModel.email)
                .padding()
                .autocapitalization(.none)
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)

            // Sign Up Button
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        errorMessage = error.localizedDescription // Display the error
                    }
                }
            } label: {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.green) // Make the button green for Sign Up
                    .cornerRadius(10)
            }
            .padding(.bottom, 10)

            // Sign In Button
            Button {
                Task {
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        errorMessage = error.localizedDescription // Display the error
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue) // Different color for Sign In
                    .cornerRadius(10)
            }

            // Display Error Message if any
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}


#Preview {
    SignInEmailView(showSignInView: .constant(false))
}
