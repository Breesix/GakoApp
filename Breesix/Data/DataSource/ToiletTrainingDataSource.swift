//
//  ToiletTrainingDataSource.swift
//  Breesix
//
//  Created by Rangga Biner on 10/10/24.
//

import Foundation

protocol ToiletTrainingDataSource {
    func fetch() async throws -> [ToiletTraining]
    func insert(_ toiletTraining: ToiletTraining) async throws
    func update(_ toiletTraining: ToiletTraining) async throws
    func delete(_ toiletTraining: ToiletTraining) async throws
}
