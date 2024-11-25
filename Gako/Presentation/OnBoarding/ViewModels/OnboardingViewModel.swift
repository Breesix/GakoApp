//
//  OnboardingViewModel.swift
//  Gako
//
//  Created by Rangga Biner on 17/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: A ViewModel handles the business logic of the onboardingView
//  Usage: Use this viewmodel for OnboardingView
//

import Foundation
import SwiftUI

class OnboardingViewModel: ObservableObject {
    @Published var currentPage: Int = 0
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    let onboardingItems: [Onboarding] = [
        Onboarding(lottie: "tambahMurid", title: "Tambahkan Murid", description: "Tambahkan Murid Anda untuk memudahkan proses dokumentasi."),
        Onboarding(lottie: "inputDokumen", title: "Ceritakan Aktivitas Murid Anda", description: "Ceritakan aktivitas Murid Anda kepada Gako dengan mudah, baik menggunakan metode suara ataupun dengan mengetik secara manual."),
        Onboarding(lottie: "generalisasi", title: "Generalisasikan Cerita Anda", description: "Anda tidak perlu menyebutkan nama Murid Anda satu-persatu. Cukup gunakan istilah umum seperti “Semua Anak”, “Semuanya”, ataupun “Semuanya kecuali...”, Gako mengerti maksud Anda."),
        Onboarding(lottie: "bagikanDokumentasi", title: "Bagikan Dokumentasi", description: "Anda bisa dengan mudah berbagi dokumentasi Murid Anda kepada guru lain ataupun orang tua Murid Anda."),
    ]

    var totalPages: Int {
        onboardingItems.count
    }
    
    var isLastPage: Bool {
        currentPage == totalPages - 1
    }
    
    var showPreviousButton: Bool {
        currentPage > 0
    }
    
    func getIndex(for item: Onboarding) -> Int {
        onboardingItems.firstIndex(where: { $0.id == item.id }) ?? 0
    }
    
    func handleNextButton() {
        if isLastPage {
            isOnboarding = false
        } else {
            currentPage += 1
        }
    }
    
    func handlePreviousButton() {
        currentPage = max(0, currentPage - 1)
    }
}
