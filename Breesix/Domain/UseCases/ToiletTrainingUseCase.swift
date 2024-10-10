//
//  ToiletTrainingUseCase.swift
//  Breesix
//
//  Created by Akmal Hakim on 02/10/24.
//

import Foundation

protocol ToiletTrainingUseCase {
    func fetchToiletTrainings(_ student: Student) async throws -> [ToiletTraining]
    func addToiletTraining(_ training: ToiletTraining, for student: Student) async throws
    func updateToiletTraining(_ training: ToiletTraining) async throws
    func deleteToiletTraining(_ training: ToiletTraining, from student: Student) async throws
}
