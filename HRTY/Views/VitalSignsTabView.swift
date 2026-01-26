import SwiftUI
import SwiftData

/// Tab view containing all vital signs entry sections in a Control Center-style grid
struct VitalSignsTabView: View {
    @Bindable var viewModel: TodayViewModel

    var body: some View {
        VitalSignsGridView(viewModel: viewModel)
    }
}

#Preview {
    VitalSignsTabView(viewModel: TodayViewModel())
        .modelContainer(for: DailyEntry.self, inMemory: true)
        .padding()
        .background(Color.hrtBackgroundFallback)
}
