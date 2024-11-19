//
//  ToastModifier.swift
//  Gako
//
//  Created by Rangga Biner on 18/11/24.
//
//  Copyright © 2024 Gako. All rights reserved.
//
//  Description: Custom view modifier for displaying toast notifications in SwiftUI
//  Usage: Apply this modifier to display temporary toast messages with customizable duration
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    mainToastView()
                        .offset(y: 32)
                }
                .animation(.spring(), value: toast)
            )
            .onChange(of: toast) { 
                showToast()
            }
    }
}

private extension ToastModifier {
    @ViewBuilder func mainToastView() -> some View {
        if let toast = toast {
            VStack {
                ToastNotification(message: toast.message, onCancelTapped: dismissToast, style: .success)
                Spacer()
            }
        }
    }
}

private extension ToastModifier {
    func showToast() {
        guard let toast = toast else { return }
        
        if toast.duration > 0 {
            workItem?.cancel()
            let task = DispatchWorkItem {
                dismissToast()
            }
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + toast.duration, execute: task)
        }
    }
    
    func dismissToast() {
        withAnimation {
            toast = nil
        }
        workItem?.cancel()
        workItem = nil
    }
}

