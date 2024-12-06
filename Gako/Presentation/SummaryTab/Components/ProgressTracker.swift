//
//  ProgressTracker.swift
//  Gako
//
//  Created by Rangga Biner on 13/11/24.
//
//  Description: A view that displays the progress tracker in the curhat view.
//  Usage: Use this view to display the progress tracker in the curhat view.    

import SwiftUI

struct ProgressTracker: View {
    var firstColor: Color
    var secondColor: Color
    var thirdColor: Color
    
    var body: some View {
        HStack (spacing: 4) {
            Text("1")
                .padding(11)
                .background(firstColor)
                .clipShape(.circle)
            HStack (spacing: 2) {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(secondColor)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(secondColor)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(secondColor)
            }
            Text("2")
                .padding(11)
                .background(secondColor)
                .clipShape(.circle)
            HStack (spacing: 2) {
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(thirdColor)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(thirdColor)
                Circle()
                    .frame(width: 5, height: 5)
                    .foregroundStyle(thirdColor)
            }
            Text("3")
                .padding(11)
                .background(thirdColor)
                .clipShape(.circle)
        }
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
    }
}


#Preview {
    ProgressTracker(firstColor: .bgSecondary, secondColor: .bgAccent, thirdColor: .bgMain)
}
