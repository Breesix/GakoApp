//
//  DismissKeyboardOnTap.swift
//  Breesix
//
//  Created by Akmal Hakim on 25/10/24.
//

import Foundation
import SwiftUI

extension View {
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                         to: nil,
                                         from: nil,
                                         for: nil)
        }
    }
}
