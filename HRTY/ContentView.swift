import SwiftUI

enum Tab: Hashable, CaseIterable {
    case today
    case trends
    case medications
    case learn
    case myHeart
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

            LearnView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(Tab.learn)
                .accessibilityIdentifier("learnTab")

            MyHeartView()
                .tabItem {
                    Label("My Heart", systemImage: "heart.circle")
                }
                .tag(Tab.myHeart)
                .accessibilityIdentifier("myHeartTab")

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
        .tint(Color.hrtPinkFallback)
        .onReceive(NotificationCenter.default.publisher(for: .navigateToTodayTab)) { _ in
            selectedTab = .today
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToMyHeartTab)) { _ in
            selectedTab = .myHeart
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToExportTab)) { _ in
            selectedTab = .export
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToSettingsTab)) { _ in
            selectedTab = .settings
        }
    }
}

#Preview {
    ContentView()
}
