//
//  ActivityRow.swift
//  Breesix
//
//  Created by Rangga Biner on 27/09/24.
//

import SwiftUI

struct ActivityRow: View {
    let activity: Activity

    var body: some View {
        HStack {
            Text(activity.title)
            Spacer()
            VStack(alignment: .trailing) {
                HStack {
                    Text("Dibimbing")
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                }
                HStack {
                    Text("Mandiri")
                    Toggle("", isOn: .constant(false))
                        .labelsHidden()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.black)
    }
}

#Preview {
    ActivityRow(activity: Activity(title: "Menari"))
}
