import SwiftUI
import SwiftData

@main
struct HRTYApp: App {
    // Initialize NotificationService early to ensure delegate is set up
    // before handling notification responses from app launch
    private let notificationService = NotificationService.shared

    @AppStorage(AppStorageKeys.hasCompletedOnboarding) private var hasCompletedOnboarding = false

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
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingContainerView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
