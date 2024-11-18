//
//  View+Toast.swift
//  Gako
//
//  Created by Rangga Biner on 18/11/24.
//

import SwiftUI

extension View {
    func toastView(toast: Binding<Toast?>) -> some View {
        self.modifier(ToastModifier(toast: toast))
    }
}
