import SwiftUI

struct TodayView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Daily Check-In")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Today")
        }
    }
}

#Preview {
    TodayView()
}
