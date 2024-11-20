//
//  Status+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 18/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Extension for Status enum providing CaseIterable conformance and text representation
//  Usage: Use this extension to get all possible status cases and their string representations
//

import Foundation

extension Status: CaseIterable {
    static var allCases: [Status] = [.mandiri, .dibimbing, .tidakMelakukan]
    
    var text: String {
        switch self {
        case .mandiri: return "Mandiri"
        case .dibimbing: return "Dibimbing"
        case .tidakMelakukan: return "Tidak Melakukan"
        }
    }
    
    var displayText: String {
        switch self {
        case .mandiri: return UIConstants.ManageActivity.mandiriText
        case .dibimbing: return UIConstants.ManageActivity.dibimbingText
        case .tidakMelakukan: return UIConstants.ManageActivity.tidakMelakukanText
        }
    }

}
