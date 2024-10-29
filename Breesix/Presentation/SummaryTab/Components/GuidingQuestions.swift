//
//  GuidingQuestions.swift
//  Breesix
//
//  Created by Rangga Biner on 29/10/24.
//

import SwiftUI

struct GuidingQuestions: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 8){
            Text("Apa saja kegiatan murid Anda di sekolah hari ini?")
            Text("Bagaimana murid Anda mengikuti kegiatan pada hari ini?")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.subheadline)
        .fontWeight(.semibold)
        .foregroundStyle(.labelDisabled)
    }
}
#Preview {
    GuidingQuestions()
}

