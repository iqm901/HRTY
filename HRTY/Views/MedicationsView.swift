import SwiftUI

struct MedicationsView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Manage Your Medications")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Medications")
        }
    }
}

#Preview {
    MedicationsView()
}
