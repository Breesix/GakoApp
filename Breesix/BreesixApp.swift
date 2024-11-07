//
//  BreesixApp.swift
//  Breesix
//
//  Created by Rangga Biner on 19/09/24.
//

import SwiftUI
import SwiftData
import Speech
import Mixpanel


@main
struct BreesixApp: App {
    let container: ModelContainer
    @State private var showTabBar: Bool = true
    @AppStorage("isOnboarding") private var isOnboarding: Bool = true
    private let analyticsService = InputAnalyticsTracker.shared
    
    init() {
        Mixpanel.initialize(token: APIConfig.mixPanelToken, trackAutomaticEvents: true)
        
        // Enable logging for development
#if DEBUG
        Mixpanel.mainInstance().loggingEnabled = true
#endif
        
        // Set default properties
        Mixpanel.mainInstance().registerSuperProperties([
            "device_model": UIDevice.current.model,
            "ios_version": UIDevice.current.systemVersion,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ])
        do {
            container = try ModelContainer(for: Student.self, Note.self, Activity.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isOnboarding {
                    OnboardingView()
                        .transition(.opacity)
                } else {
                    mainContent
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: isOnboarding)
        }
        .modelContainer(container)

    }
    
    
    
    @ViewBuilder
    private var mainContent: some View {
        let context = container.mainContext
        
        let studentDataSource = StudentDataSourceImpl(context: context)
        let studentRepository = StudentRepositoryImpl(dataSource: studentDataSource)
        let studentUseCase = StudentUseCaseImpl(repository: studentRepository)
        
        let noteDataSource = NoteDataSourceImpl(context: context)
        let noteRepository = NoteRepositoryImpl(dataSource: noteDataSource)
        let noteUseCases = NoteUseCaseImpl(repository: noteRepository)
        
        let activityDataSource = ActivityDataSourceImpl(context: context)
        let activityRepository = ActivityRepositoryImpl(dataSource: activityDataSource)
        let activityUseCase = ActivityUseCaseImpl(repository: activityRepository)
        
        let summaryDataSource = SummaryDataSourceImpl(context: context)
        let summaryRepository = SummaryRepositoryImpl(dataSource: summaryDataSource)
        let summaryUseCase = SummaryUseCaseImpl(repository: summaryRepository)
        
        let summaryService = SummaryService(summaryUseCase: summaryUseCase)
        let summaryLlamaService = SummaryLlamaService(
            apiKey: "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",
            summaryUseCase: summaryUseCase
        )
        
        let studentViewModel = StudentViewModel(studentUseCases: studentUseCase)
        
        let noteViewModel = NoteViewModel(studentViewModel: studentViewModel, noteUseCases: noteUseCases)
        
        let activityViewModel = ActivityViewModel(studentViewModel: studentViewModel, activityUseCases: activityUseCase)
        
        let summaryViewModel = SummaryViewModel(studentViewModel: studentViewModel, summaryUseCase: summaryUseCase, summaryService: summaryService, summaryLlamaService: summaryLlamaService)
        
        MainTabView(studentViewModel: studentViewModel, noteViewModel: noteViewModel, activityViewModel: activityViewModel, summaryViewModel: summaryViewModel)
            .onAppear {
                // Track launch event using AnalyticsService
                analyticsService.trackEvent(
                    "App Launched",
                    properties: [
                        "timestamp": Date().timeIntervalSince1970,
                        "is_first_launch": !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
                    ]
                )
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            }
            .onDisappear {
                Mixpanel.mainInstance().flush()
            }
            .accentColor(.accent)
    }
}
