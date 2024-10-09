//
//  ToiletTrainingRepository.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation

protocol ToiletTrainingRepository {
    func addTraining(_ training: ToiletTraining, for student: Student) async throws
    func getTrainingForStudent(_ student: Student) async throws -> [ToiletTraining]
    func updateTrainingProgress(_ training: ToiletTraining) async throws
    func deleteTrainingProgress(_ training: ToiletTraining, from student: Student) async throws
}
