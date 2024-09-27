//
//  Student.swift
//  Breesix
//
//  Created by Rangga Biner on 24/09/24.
//

import Foundation

struct Student: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let nickname: String
}
