//
//  RootView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 21/09/24.
//

import SwiftUI

struct RootView: View {
    
    @ObservedObject var authViewModel: AuthenticationViewModel = AuthenticationViewModel()
    @State private var showSignInView: Bool = false
    @StateObject private var viewModel = StudentViewModel()
    @State private var selectedTab: Tab = .home
    let mockChild = Student(
        id: "123",
        nisn: "1221432423",
        name: "John Doe",
        gender: "Man",
        birthdate: Date(timeIntervalSince1970: 946684800), // Example: January 1, 2000
        background: "Student",
        emergencyContact: "08621312312312",
        autismLevel: "Intermediate",
        likes: "Sport",
        dislikes: "Vegetable",
        skills: "BasketBall",
        imageUrl: nil
    )
    
    enum Tab {
        case home
        case murid
        case document
        case profile
    }
    
    var body: some View {
        ZStack {
            Group {
                NavigationStack {
                    switch authViewModel.authState {
                    case .Initialize:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    case .Login:
                        TabView(selection: $selectedTab) {
                            HomeView()
                                .tabItem{
                                    Label("Home", systemImage: "house")
                                }
                                .tag(Tab.home)
                            
                            LogDailyActivityView(student: mockChild) // Replace with your actual document view
                                .tabItem {
                                    Label("Daftar Murid", systemImage: "person.2.fill")
                                }
                                .tag(Tab.document)
                            LogDailyActivityView(student: mockChild) // Replace with your actual document view
                                .tabItem {
                                    Label("Documents", systemImage: "book.pages.fill")
                                }
                                .tag(Tab.document)
                            
                            TeacherProfileView(showSignInView: $showSignInView) // Replace with your actual profile view
                                .tabItem {
                                    Label("Profile", systemImage: "person.crop.circle")
                                }
                                .tag(Tab.profile)
                        }
                    case .Logout:
                        // Optionally handle logout state if needed
                        EmptyView()
                    }
                }
                .onAppear {
                    Task {
                        do {
                            let authUser = try AuthenticationManager.shared.getAuthenticationUser()
                            // Update auth state based on whether the user is authenticated
                            authViewModel.authState = authUser != nil ? .Login : .Logout
                            
                        } catch {
                            authViewModel.authState = .Logout
                        }
                        
                    }
                    
                }
            }
        }
        .fullScreenCover(isPresented: .constant(authViewModel.authState == .Logout)) {
            NavigationStack {
                AuthenticationView(showSigInView: .constant(false)) // Present the authentication view
            }
        }
    }
}

#Preview {
    RootView()
}

