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
            MedicationPeriod.self,
            AlertEvent.self,
            VitalSignsEntry.self,
            SymptomCheckInProgress.self,
            ClinicalProfile.self,
            HeartValveCondition.self,
            CoronaryProcedure.self,
            SodiumEntry.self,
            SodiumTemplate.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Schema migration failed (e.g., type changed from Double to String)
            // Delete the old database and create a fresh one
            // This is acceptable for V1 with no cloud sync - user data is on-device only
            print("ModelContainer creation failed, attempting recovery: \(error)")

            // Try to delete the existing store
            let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
            let walURL = storeURL.appendingPathExtension("wal")
            let shmURL = storeURL.appendingPathExtension("shm")

            do {
                let fileManager = FileManager.default
                for url in [storeURL, walURL, shmURL] {
                    if fileManager.fileExists(atPath: url.path) {
                        try fileManager.removeItem(at: url)
                    }
                }
                // Retry creating the container
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create or recover ModelContainer: \(error)")
            }
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
