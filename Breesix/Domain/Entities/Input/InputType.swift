//
//  InputType.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//
import Foundation

enum InputType: String {
    case voice = "Voice"
    case text = "Text"
    
    var name: String {
        return self.rawValue
    }
}



