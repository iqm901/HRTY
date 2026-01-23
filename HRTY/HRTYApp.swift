import SwiftUI
import SwiftData

@main
struct HRTYApp: App {
    // Initialize NotificationService early to ensure delegate is set up
    // before handling notification responses from app launch
    private let notificationService = NotificationService.shared

    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

    init() {
        // Configure global UI appearance with pink accent
        let pinkColor = UIColor(red: 0.95, green: 0.40, blue: 0.50, alpha: 1.0)

        // Tab bar appearance
        UITabBar.appearance().tintColor = pinkColor

        // Navigation bar appearance
        UINavigationBar.appearance().tintColor = pinkColor
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            DailyEntry.self,
            SymptomEntry.self,
            DiureticDose.self,
            Medication.self,
            AlertEvent.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingContainerView {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .tint(Color.hrtPinkFallback)
        }
        .modelContainer(sharedModelContainer)
    }
}
