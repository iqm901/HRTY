import SwiftUI

/// Section view displaying heart rate data from HealthKit on the Today view
struct HeartRateSectionView: View {
    let heartRate: String?
    let timestamp: String?
    let isLoading: Bool
    let isAvailable: Bool

    var body: some View {
        // Only show section if HealthKit is available
        if isAvailable {
            VStack(spacing: 16) {
                sectionHeader

                if isLoading {
                    loadingView
                } else if let heartRate = heartRate {
                    heartRateDisplay(heartRate: heartRate)
                } else {
                    noDataView
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack {
            Image(systemName: "heart.fill")
                .foregroundStyle(.red)
                .font(.system(size: 18))
            Text("Resting Heart Rate")
                .font(.headline)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Resting heart rate section")
    }

    // MARK: - Loading View

    private var loadingView: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading from Apple Health...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
        .accessibilityLabel("Loading heart rate data")
    }

    // MARK: - Heart Rate Display

    private func heartRateDisplay(heartRate: String) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(heartRate)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Resting heart rate: \(heartRate)")

            if let timestamp = timestamp {
                Text(timestamp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Recorded \(timestamp)")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - No Data View

    private var noDataView: some View {
        VStack(spacing: 8) {
            Image(systemName: "heart.slash")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)

            Text("No heart rate data available")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Your resting heart rate will appear here when recorded by Apple Health.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No heart rate data available. Your resting heart rate will appear here when recorded by Apple Health.")
    }
}

#Preview("With Data") {
    HeartRateSectionView(
        heartRate: "62 bpm",
        timestamp: "2 hours ago",
        isLoading: false,
        isAvailable: true
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Loading") {
    HeartRateSectionView(
        heartRate: nil,
        timestamp: nil,
        isLoading: true,
        isAvailable: true
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("No Data") {
    HeartRateSectionView(
        heartRate: nil,
        timestamp: nil,
        isLoading: false,
        isAvailable: true
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
