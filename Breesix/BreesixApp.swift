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
    
    init() {
        do {
            container = try ModelContainer(for: Student.self, Activity.self)
        } catch {
            fatalError("Failed to create ModelContainer for Student and Activity: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            let context = container.mainContext
            
            let studentDataSource = StudentDataSourceImpl(context: context)
            let studentRepository = StudentRepositoryImpl(dataSource: studentDataSource)
            let studentUseCase = StudentUseCaseImpl(repository: studentRepository)
            
            let activityDataSource = ActivityDataSourceImpl(context: context)
            let activityRepository = ActivityRepositoryImpl(activityDataSource: activityDataSource)
            let activityUseCase = ActivityUseCaseImpl(repository: activityRepository)
            
            let toiletTrainingDataSource = ToiletTrainingDataSourceImpl(context: context)
            let toiletTrainingRepository = ToiletTrainingRepositoryImpl(toiletTrainingDataSource: toiletTrainingDataSource)
            let toiletTrainingUseCase = ToiletTrainingUseCaseImpl(repository: toiletTrainingRepository)
            
            let viewModel = StudentListViewModel(studentUseCases: studentUseCase, activityUseCases: activityUseCase, toiletTrainingUseCases: toiletTrainingUseCase)
            
            MainTabView(studentListViewModel: viewModel)
        }
        .modelContainer(container)
    }
}
