import SwiftUI

struct ExportView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Export Your Data")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Export")
        }
    }
}

#Preview {
    ExportView()
}
