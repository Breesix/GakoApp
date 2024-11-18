//
//  Status+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 18/11/24.
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
}
