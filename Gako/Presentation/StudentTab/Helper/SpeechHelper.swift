//
//  SpeechHelper.swift
//  Gako
//
//  Created by Kevin Fairuz on 19/11/24.
//
import SwiftUI
import Speech

enum SpeechHelper {
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                let isAuthorized = authStatus == .authorized
                completion(isAuthorized)
            }
        }
    }
    
    static func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil,
                                      from: nil,
                                      for: nil)
    }
}
