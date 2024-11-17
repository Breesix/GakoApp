//
//  TextInputViewModel.swift
//  Breesix
//
//  Created by Kevin Fairuz on 04/11/24.
//

import SwiftUI

class TextInputViewModel: InputViewModel {
    @Published var reflection: String = ""
    
    func startEditing(date: Date) {
        super.startInput(type: .text, date: date)
    }
    
    func completeEditing() {
        super.completeInput(type: .text, text: reflection)
    }
    
    func validateDate(_ date: Date) -> Bool {
        DateValidator.isValidDate(date)
    }
    
    // Additional methods if needed
}
