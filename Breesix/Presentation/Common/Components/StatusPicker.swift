//
//  StatusPicker.swift
//  Breesix
//
//  Created by Rangga Biner on 01/11/24.
//

import SwiftUI

struct StatusPicker: View {
    @Binding var status: Bool?
    var onStatusChange: (Bool?) -> Void
    
    var body: some View {
        Menu {
            Button("Mandiri") {
                status = true
                onStatusChange(true)
            }
            Button("Dibimbing") {
                status = false
                onStatusChange(false)
            }
            Button("Tidak Melakukan") {
                status = nil
                onStatusChange(nil)
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
        case true:
            return "Mandiri"
        case false:
            return "Dibimbing"
        case nil:
            return "Tidak Melakukan"
        default:
            return "Status"
        }
    }
}

#Preview {
    StatusPicker(
        status: .constant(nil),
        onStatusChange: { _ in print("changed") }
    )
}
