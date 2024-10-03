//
//  HomeViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var selectedDate: Date
    
    init() {
        self.selectedDate = Date()
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: selectedDate)
    }
}
