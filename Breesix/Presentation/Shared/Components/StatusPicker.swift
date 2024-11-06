//
//  StatusPicker.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI
import Mixpanel

struct StatusPicker: View {
    @Binding var status: Status
    var onStatusChange: (Status) -> Void
    
    var body: some View {
        Menu {
            Button("Mandiri") {
                status = .mandiri
                onStatusChange(.mandiri)
            }
            Button("Dibimbing") {
                status = .dibimbing
                onStatusChange(.dibimbing)
            }
            Button("Tidak Melakukan") {
                status = .tidakMelakukan
                onStatusChange(.tidakMelakukan)
            }
        } label: {
            HStack {
                Text(getStatusText())
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
            }
            .font(.body)
            .fontWeight(.regular)
            .foregroundColor(.labelPrimaryBlack)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.cardFieldBG)
            .cornerRadius(8)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.statusStroke, lineWidth: 2)
            }
        }
    }
    
    private func getStatusText() -> String {
        switch status {
        case .mandiri: return "Mandiri"
        case .dibimbing: return "Dibimbing"
        case .tidakMelakukan: return "Tidak Melakukan"
        }
    }
}


//#Preview {
//    StatusPicker(
//        status: .constant(.tidakMelakukan),
//        onStatusChange: { _ in print("changed") }
//    )
//}
