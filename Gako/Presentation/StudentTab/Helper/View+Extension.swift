//
//  View+Extension.swift
//  Gako
//
//  Created by Rangga Biner on 20/11/24.
//

import SwiftUI

extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                      to: nil,
                                      from: nil,
                                      for: nil)
    }
}
