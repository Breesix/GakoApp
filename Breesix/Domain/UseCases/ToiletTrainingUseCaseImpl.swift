//
//  ToiletTrainingUseCaseImpl.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//


import Foundation

struct ToiletTrainingUseCaseImpl: ToiletTrainingUseCase {
    let repository: ToiletTrainingRepository
    
    func fetchToiletTrainings(_ student: Student) async throws -> [ToiletTraining] {
        return try await repository.fetchToiletTrainings(student)
    }

    func addToiletTraining(_ training: ToiletTraining, for student: Student) async throws {
        try await repository.addToiletTraining(training, for: student)
    }

    func updateToiletTraining(_ training: ToiletTraining) async throws {
        try await repository.updateToiletTraining(training)
    }
    
    func deleteToiletTraining(_ training: ToiletTraining, from student: Student) async throws {
        try await repository.deleteToiletTraining(training, from: student)
    }
}
