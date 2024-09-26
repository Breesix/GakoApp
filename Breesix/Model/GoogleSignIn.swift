//
//  GoogleSignIn.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift


struct GoogleSignInResult {
    let idToken: String
    let accessToken: String
    let email: String?
    let firstName: String?
    let lastName: String?
    let fullname: String?
    let profileImageUrl: URL?
    
    var displayName: String? {
        fullname ?? firstName ?? lastName
    }
    
    init?(result: GIDSignInResult) {
        guard let idToken = result.user.idToken?.tokenString else {
            return nil
        }
        
        self.idToken = idToken
        self.accessToken = result.user.accessToken.tokenString
        self.email = result.user.profile?.email
        self.firstName = result.user.profile?.givenName
        self.lastName = result.user.profile?.familyName
        self.fullname = result.user.profile?.name
        
        let dimension = round(400 * UIScreen.main.scale)
        
        if result.user.profile?.hasImage == true{
            self.profileImageUrl = result.user.profile?.imageURL(withDimension: UInt(dimension))
        } else {
            self.profileImageUrl = nil
        }
    }
}

