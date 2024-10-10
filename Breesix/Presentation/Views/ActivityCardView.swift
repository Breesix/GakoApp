//
//  ActivityCardView.swift
//  Breesix
//
//  Created by Akmal Hakim on 07/10/24.
//

import SwiftUI

struct ActivityCardView: View {
    let toiletTrainings: [ToiletTraining]
    let activities: [Activity]
    let onAddActivity: () -> Void
    let onEditTraining: (ToiletTraining) -> Void
    let onDeleteTraining: (ToiletTraining) -> Void
    let onEditActivity: (Activity) -> Void
    let onDeleteActivity: (Activity) -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            ToiletTrainingSection(
                toiletTrainings: toiletTrainings,
                onEditTraining: onEditTraining,
                onDeleteTraining: onDeleteTraining
            )
            
            GeneralActivitySection(
                activities: activities,
                onEditActivity: onEditActivity,
                onDeleteActivity: onDeleteActivity,
                onAddActivity: onAddActivity
            )
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .background(Color(red: 0.92, green: 0.96, blue: 0.96))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.25)
                .stroke(.green, lineWidth: 0.5)
        )
    }
}

struct ToiletTrainingSection: View {
    let toiletTrainings: [ToiletTraining]
    let onEditTraining: (ToiletTraining) -> Void
    let onDeleteTraining: (ToiletTraining) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Toilet Training")
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, minHeight: 18, maxHeight: 18, alignment: .leading)
            
            if toiletTrainings.isEmpty {
                Text("Tidak ada toilet training untuk tanggal ini")
                    .foregroundColor(.secondary)
            } else {
                ForEach(toiletTrainings, id: \.id) { training in
                    ToiletTrainingRow(training: training, onEdit: onEditTraining, onDelete: onDeleteTraining)
                }
            }
        }
        .padding(.horizontal, 12)
    }
}

struct ToiletTrainingRow: View {
    let training: ToiletTraining
    let onEdit: (ToiletTraining) -> Void
    let onDelete: (ToiletTraining) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let status = training.status {
                HStack {
                    Image(systemName: status ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(status ? "Independent" : "Needs Guidance")
                }
                .foregroundColor(status ? .green : .red)
            }
            VStack {
                Text(training.trainingDetail)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(8)
        }
        .contextMenu {
            Button("Edit") { onEdit(training) }
            Button("Hapus", role: .destructive) { onDelete(training) }
        }
    }
}

import SwiftUI

struct ActivityDetailRow: View {
    let activity: Activity
    let onEdit: (Activity) -> Void
    let onDelete: (Activity) -> Void
    
    var body: some View {
        Text(activity.generalActivity)
            .font(.caption)
            .foregroundColor(Color(red: 0.13, green: 0.13, blue: 0.13))
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(8)
            .contextMenu {
                Button("Edit") { onEdit(activity) }
                Button("Hapus", role: .destructive) { onDelete(activity) }
            }
    }
}
