//
//  InputType.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//
import Foundation

enum InputType {
    case voice
    case text
    
    var name: String {
        switch self {
        case .voice: return "Voice"
        case .text: return "Text"
        }
    }
}

