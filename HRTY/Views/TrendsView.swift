import SwiftUI

struct TrendsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Your Health Trends")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Trends")
        }
    }
}

#Preview {
    TrendsView()
}
