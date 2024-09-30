//
//  HomeViewModel.swift
//  Breesix
//
//  Created by Rangga Biner on 30/09/24.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var currentDate: Date
    
    init() {
        self.currentDate = Date()
        setupDateUpdater()
    }
    
    private func setupDateUpdater() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.currentDate = Date()
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: currentDate)
    }
}
