//
//  StudentSummaryCard.swift
//  Breesix
//
//  Created by Rangga Biner on 24/10/24.
//

import SwiftUI

struct StudentSummaryCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                Text("Rangga Hadi Putra")
                    .font(.body)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 24))
            }
            Text("Menjalankan semua aktivitas dengan baik")
                .font(.footnote)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)
        }
    }
}

#Preview {
    StudentSummaryCard()
}
