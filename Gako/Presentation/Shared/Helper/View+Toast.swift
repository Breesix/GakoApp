//
//  View+Toast.swift
//  Gako
//
//  Created by Rangga Biner on 18/11/24.
//
//  Description: View extension for adding toast notification functionality
//  Usage: Apply the toastView modifier to display toast notifications in any SwiftUI View
//

import SwiftUI

extension View {
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}
