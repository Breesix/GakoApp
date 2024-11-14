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
    @StateObject private var theme = AppTheme.shared
    @State private var showTabBar: Bool = true
    @AppStorage("isOnboarding") private var isOnboarding: Bool = true
    private let analyticsService = InputAnalyticsTracker.shared
    
    // Tambahkan StateObject untuk ViewModel yang sudah ada
    @StateObject private var studentViewModel: StudentViewModel
    @StateObject private var noteViewModel: NoteViewModel
    @StateObject private var activityViewModel: ActivityViewModel
    @StateObject private var summaryViewModel: SummaryViewModel
    @StateObject private var appColor = AppColor()

    init() {
        Mixpanel.initialize(token: APIConfig.mixPanelToken, trackAutomaticEvents: true)

#if DEBUG
        Mixpanel.mainInstance().loggingEnabled = true
#endif

        Mixpanel.mainInstance().registerSuperProperties([
            "device_model": UIDevice.current.model,
            "ios_version": UIDevice.current.systemVersion,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ])
        
        do {
            container = try ModelContainer(for: Student.self, Note.self, Activity.self)

            let context = container.mainContext

            let studentDataSource = StudentDataSourceImpl(context: context)
            let studentRepository = StudentRepositoryImpl(dataSource: studentDataSource)
            let studentUseCase = StudentUseCaseImpl(repository: studentRepository)
            let initialStudentViewModel = StudentViewModel(studentUseCases: studentUseCase)
            self._studentViewModel = StateObject(wrappedValue: initialStudentViewModel)

            let noteDataSource = NoteDataSourceImpl(context: context)
            let noteRepository = NoteRepositoryImpl(dataSource: noteDataSource)
            let noteUseCases = NoteUseCaseImpl(repository: noteRepository)
            let initialNoteViewModel = NoteViewModel(studentViewModel: initialStudentViewModel, noteUseCases: noteUseCases)
            self._noteViewModel = StateObject(wrappedValue: initialNoteViewModel)

            let activityDataSource = ActivityDataSourceImpl(context: context)
            let activityRepository = ActivityRepositoryImpl(dataSource: activityDataSource)
            let activityUseCase = ActivityUseCaseImpl(repository: activityRepository)
            let initialActivityViewModel = ActivityViewModel(studentViewModel: initialStudentViewModel, activityUseCases: activityUseCase)
            self._activityViewModel = StateObject(wrappedValue: initialActivityViewModel)

            let summaryDataSource = SummaryDataSourceImpl(context: context)
            let summaryRepository = SummaryRepositoryImpl(dataSource: summaryDataSource)
            let summaryUseCase = SummaryUseCaseImpl(repository: summaryRepository)
            let summaryService = SummaryService(summaryUseCase: summaryUseCase)
            let summaryLlamaService = SummaryLlamaService(
                apiKey: "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",
                summaryUseCase: summaryUseCase
            )
            let initialSummaryViewModel = SummaryViewModel(
                studentViewModel: initialStudentViewModel,
                summaryUseCase: summaryUseCase,
                summaryService: summaryService,
                summaryLlamaService: summaryLlamaService
            )
            self._summaryViewModel = StateObject(wrappedValue: initialSummaryViewModel)
            
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
        
        UIApplication.shared.setGlobalTint(AppTheme.shared.accentColor)
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(AppTheme.shared.accentColor)]
        UINavigationBar.appearance().standardAppearance = appearance
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(AppTheme.shared.accentColor)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isOnboarding {
                    OnboardingView()
                        .transition(.opacity)
                } else {
                    mainContent
                }
            }
            .tint(theme.accentColor)
            .accentColor(theme.accentColor)
            .environmentObject(theme)
            .animation(.easeInOut, value: isOnboarding)
            .environmentObject(studentViewModel)
            .environmentObject(noteViewModel)
            .environmentObject(activityViewModel)
            .environmentObject(summaryViewModel)
            .environmentObject(appColor)
            .tint(appColor.tint)
            .accentColor(appColor.tint)
        }
        .modelContainer(container)
        
    }
    
    @ViewBuilder
    private var mainContent: some View {

        MainTabView()
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
            .tint(theme.accentColor)
            .accentColor(theme.accentColor)
        
    }
}

// Buat ButtonStyle custom untuk konsistensi
struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .tint(.accent)
    }
}


