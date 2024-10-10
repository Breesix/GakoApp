//
//  ToiletTrainingRepository.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation

protocol ToiletTrainingRepository {
    func addToiletTraining(_ training: ToiletTraining, for student: Student) async throws
    func getToiletTrainingsForStudent(_ student: Student) async throws -> [ToiletTraining]
    func updateToiletTraining(_ training: ToiletTraining) async throws
    func deleteToiletTraining(_ training: ToiletTraining, from student: Student) async throws
}
