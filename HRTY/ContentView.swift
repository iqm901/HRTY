import SwiftUI

enum Tab: Hashable {
    case today
    case trends
    case medications
    case export
    case settings
}

struct ContentView: View {
    @State private var selectedTab: Tab = .today

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "heart.text.square")
                }
                .tag(Tab.today)
                .accessibilityIdentifier("todayTab")

            TrendsView()
                .tabItem {
                    Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(Tab.trends)
                .accessibilityIdentifier("trendsTab")

            MedicationsView()
                .tabItem {
                    Label("Medications", systemImage: "pills")
                }
                .tag(Tab.medications)
                .accessibilityIdentifier("medicationsTab")

            ExportView()
                .tabItem {
                    Label("Export", systemImage: "square.and.arrow.up")
                }
                .tag(Tab.export)
                .accessibilityIdentifier("exportTab")

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
                .accessibilityIdentifier("settingsTab")
        }
    }
}

#Preview {
    ContentView()
}
