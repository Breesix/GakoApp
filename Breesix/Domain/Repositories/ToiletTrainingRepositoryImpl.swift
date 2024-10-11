//
//  ToiletTrainingRepositoryImpl.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//
import Foundation
import SwiftData

class ToiletTrainingRepositoryImpl: ToiletTrainingRepository {
    private let toiletTrainingDataSource: ToiletTrainingDataSource

    init(toiletTrainingDataSource: ToiletTrainingDataSource) {
        self.toiletTrainingDataSource = toiletTrainingDataSource
    }

    func fetchToiletTrainings(_ student: Student) async throws -> [ToiletTraining] {
        return student.toiletTrainings
    }

    func addToiletTraining(_ toiletTraining: ToiletTraining, for student: Student) async throws {
        // override the training if it already exists on that date
        if let index = student.toiletTrainings.firstIndex(where: { $0.createdAt == toiletTraining.createdAt }) {
            student.toiletTrainings[index] = toiletTraining
                } else {
                }
        student.toiletTrainings.append(toiletTraining)

        try await toiletTrainingDataSource.insert(toiletTraining)
    }
        
    func updateToiletTraining(_ toiletTraining: ToiletTraining) async throws {
        try await toiletTrainingDataSource.update(toiletTraining)
    }
    
    func deleteToiletTraining(_ toiletTraining: ToiletTraining, from student: Student) async throws {
        student.toiletTrainings.removeAll(where: { $0.id == toiletTraining.id })
        try await toiletTrainingDataSource.delete(toiletTraining)
    }

}
