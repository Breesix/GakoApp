//
//  GuidingQuestions.swift
//  Gako
//
//  Created by Rangga Biner on 29/10/24.
//
//  Description: A view that displays guiding questions for the daily report section.
//  Usage: Use this view to display guiding questions in the daily report section.  

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

