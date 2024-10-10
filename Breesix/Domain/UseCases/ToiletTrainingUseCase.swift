//
//  ToiletTrainingUseCase.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation

struct ToiletTrainingUseCase {
    let repository: ToiletTrainingRepository
    
    func addTraining(_ training: ToiletTraining, for student: Student) async throws {
        try await repository.addToiletTraining(training, for: student)
    }

    func getTrainingForStudent(_ student: Student) async throws -> [ToiletTraining] {
        return try await repository.getToiletTrainingsForStudent(student)
    }

    func updateTrainingProgress(_ training: ToiletTraining) async throws {
        try await repository.updateToiletTraining(training)
    }
    
    func deleteTrainingProgress(_ training: ToiletTraining, from student: Student) async throws {
        try await repository.deleteToiletTraining(training, from: student)
    }
}
