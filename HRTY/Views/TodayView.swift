import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("How are you feeling today?")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("Your daily check-in takes just a couple of minutes.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
}
