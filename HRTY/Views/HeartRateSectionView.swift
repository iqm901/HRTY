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
            VStack(spacing: HRTSpacing.md) {
                sectionHeader

                if isLoading {
                    loadingView
                } else if let heartRate = heartRate {
                    heartRateDisplay(heartRate: heartRate)
                } else {
                    noDataView
                }
            }
            .padding(HRTSpacing.md)
            .background(Color.hrtCardFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        }
    }

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack {
            Image(systemName: "heart.fill")
                .foregroundStyle(Color.hrtPinkFallback)
            Text("Resting Heart Rate")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Resting heart rate section")
    }

    // MARK: - Loading View

    private var loadingView: some View {
        HStack(spacing: HRTSpacing.sm) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Loading from Apple Health...")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, HRTSpacing.sm)
        .accessibilityLabel("Loading heart rate data")
    }

    // MARK: - Heart Rate Display

    private func heartRateDisplay(heartRate: String) -> some View {
        VStack(spacing: HRTSpacing.sm) {
            HStack(alignment: .lastTextBaseline, spacing: HRTSpacing.xs) {
                Text(heartRate)
                    .font(.hrtMetricLarge)
                    .foregroundStyle(Color.hrtTextFallback)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Resting heart rate: \(heartRate)")

            if let timestamp = timestamp {
                Text(timestamp)
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .accessibilityLabel("Recorded \(timestamp)")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HRTSpacing.sm)
    }

    // MARK: - No Data View

    private var noDataView: some View {
        VStack(spacing: HRTSpacing.sm) {
            Image(systemName: "heart.slash")
                .font(.hrtTitle2)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("No heart rate data available")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("Your resting heart rate will appear here when recorded by Apple Health.")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HRTSpacing.sm)
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
    .background(Color.hrtBackgroundFallback)
}

#Preview("Loading") {
    HeartRateSectionView(
        heartRate: nil,
        timestamp: nil,
        isLoading: true,
        isAvailable: true
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("No Data") {
    HeartRateSectionView(
        heartRate: nil,
        timestamp: nil,
        isLoading: false,
        isAvailable: true
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
