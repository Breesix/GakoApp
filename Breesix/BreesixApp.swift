//
//  BreesixApp.swift
//  Breesix
//
//  Created by Rangga Biner on 19/09/24.
//

import SwiftUI
import SwiftData

@main
struct BreesixApp: App {
    let container: ModelContainer
    let summarizationService: SummarizationService
    let apiKey = "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"
    
    init() {
        do {
            container = try ModelContainer(for: Student.self, Activity.self, ToiletTraining.self)
            summarizationService = SummarizationService(apiToken: apiKey)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            let context = container.mainContext
            
            let studentDataSource = StudentDataSourceImpl(context: context)
            let studentRepository = StudentRepositoryImpl(dataSource: studentDataSource)
            let studentUseCase = StudentUseCase(repository: studentRepository)
            
            let activityRepository = ActivityRepositoryImpl(context: context)
            let activityUseCase = ActivityUseCase(repository: activityRepository)
            
            let toiletTrainingRepository = ToiletTrainingRepositoryImpl(context: context)
            let toiletTrainingUseCase = ToiletTrainingUseCase(repository: toiletTrainingRepository)
            
            let viewModel = StudentListViewModel(
                studentUseCases: studentUseCase,
                activityUseCases: activityUseCase,
                toiletTrainingUseCases: toiletTrainingUseCase,
                summarizationService: summarizationService
            )
            
            MainTabView(studentListViewModel: viewModel)
        }
        .modelContainer(container)
    }
}
