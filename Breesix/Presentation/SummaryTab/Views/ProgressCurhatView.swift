//
//  ProgressCurhatView.swift
//  Breesix
//
//  Created by Rangga Biner on 13/11/24.
//

import SwiftUI

struct ProgressCurhatView: View {
    @State private var firstColor: Color = .bgAccent
    @State private var secondColor: Color = .bgMain
    @State private var thirdColor: Color = .bgMain
    @State private var isToggleOn = false
    @State private var isShowingDatePicker = false
    @Binding var selectedDate: Date


    var body: some View {
        VStack (spacing: 12) {
            HStack {
                ProgressTracker(firstColor: firstColor, secondColor: secondColor, thirdColor: thirdColor)
                Spacer()
                DatePickerButton(isShowingDatePicker: $isShowingDatePicker, selectedDate: $selectedDate)
            }
            TitleProgressCard(title: "Apakah semua Murid hadir?", subtitle: "Pilih murid Anda yang hadir untuk mengikuti aktivitas hari ini.")
            Toggle("Semua murid hadir hari ini", isOn: $isToggleOn)
                .font(.callout)
                .fontWeight(.semibold)
                .tint(.bgAccent)
            Spacer()
            HStack {
                Button {
                    print("clicked")
                } label: {
                    Text("Batal")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.white)
                        .cornerRadius(12)
                }
                
                Button {
                    print("clicked")
                } label: {
                    Text("Lanjut")
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(.orangeClickAble)
                        .cornerRadius(12)
                }
                
            }
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(.labelPrimaryBlack)
        }
        .padding(.horizontal, 16)
        .background(.white)
    }
}

#Preview {
    ProgressCurhatView(selectedDate: .constant(.now))
}
