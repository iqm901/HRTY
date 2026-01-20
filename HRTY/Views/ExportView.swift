import SwiftUI

struct ExportView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Share with Your Care Team")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                Text("Create a summary to bring to your next appointment.")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Export")
        }
    }
}

#Preview {
    ExportView()
}
