//
//  AuthenticationView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 21/09/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth



struct AuthenticationView: View {
    
    @StateObject private var viewModel = AuthenticationViewModel()
    @Binding var showSigInView: Bool
    
    var body: some View {
        VStack{
            NavigationLink{
                SignInEmailView(showSignInView: $showSigInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark,style: .wide,state: .normal)){
                
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In")
    }
}

#Preview {
    AuthenticationView(showSigInView: .constant(false))
}
