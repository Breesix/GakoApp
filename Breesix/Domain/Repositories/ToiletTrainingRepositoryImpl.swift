//
//  ToiletTrainingRepositoryImpl.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//
import Foundation
import SwiftData

class ToiletTrainingRepositoryImpl: ToiletTrainingRepository {
    
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }
    
    func addTraining(_ training: ToiletTraining, for student: Student) async throws {
        var StudentTrainings = student.toiletTrainings
                // override the training if it already exists on that date
//        if let index = StudentTrainings.firstIndex(where: { $0.createdAt == training.createdAt }) {
//                    StudentTrainings[index] = training
//                } else {
//                }
        StudentTrainings.append(training)

        try context.save()
    }
    
    func getTrainingForStudent(_ student: Student) async throws -> [ToiletTraining] {
        return student.toiletTrainings
    }
    
    func updateTrainingProgress(_ training: ToiletTraining) async throws {
        try context.save()
    }
    
    func deleteTrainingProgress(_ training: ToiletTraining, from student: Student) async throws {
        student.toiletTrainings.removeAll(where: { $0.id == training.id })
        context.delete(training)
        try context.save()
    }

}
