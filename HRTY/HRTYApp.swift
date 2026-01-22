import SwiftUI
import SwiftData

@main
struct HRTYApp: App {
    // Initialize NotificationService early to ensure delegate is set up
    // before handling notification responses from app launch
    private let notificationService = NotificationService.shared

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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
