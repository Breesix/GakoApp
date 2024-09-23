//
//  DailyActivityDetaiView.swift
//  Breesix
//
//  Created by Kevin Fairuz on 23/09/24.
//

import SwiftUI

import SwiftUI

struct DailyActivityDetailView: View {
    let dailyActivity: DailyActivity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date: \(dailyActivity.date, style: .date)")
                .font(.title2)
            Text("Full Log:")
                .font(.headline)
            Text(dailyActivity.fullLog)
                .font(.body)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Activity Log")
    }
}

