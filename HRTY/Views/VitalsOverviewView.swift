import SwiftUI

/// Overview mode showing sparklines for all vital signs stacked vertically
struct VitalsOverviewView: View {
    let viewModel: TrendsViewModel
    @Binding var selectedVital: VitalType

    var body: some View {
        VStack(spacing: HRTSpacing.sm) {
            // Weight sparkline
            VitalSparklineView(
                title: "Weight",
                value: viewModel.formattedCurrentWeight,
                unit: "lbs",
                color: VitalType.weight.color,
                dataPoints: viewModel.weightEntries.map { $0.weight },
                onTap: { selectedVital = .weight }
            )

            // Blood Pressure sparkline
            BloodPressureSparklineView(
                title: "Blood Pressure",
                value: viewModel.formattedCurrentBP,
                unit: "mmHg",
                systolicValues: viewModel.bloodPressureEntries.map { Double($0.systolic) },
                diastolicValues: viewModel.bloodPressureEntries.map { Double($0.diastolic) },
                onTap: { selectedVital = .bloodPressure }
            )

            // Heart Rate sparkline
            VitalSparklineView(
                title: "Heart Rate",
                value: viewModel.currentHeartRate.map { "\($0)" },
                unit: "bpm",
                color: VitalType.heartRate.color,
                dataPoints: viewModel.heartRateEntries.map { Double($0.heartRate) },
                onTap: { selectedVital = .heartRate }
            )

            // Oxygen Saturation sparkline
            VitalSparklineView(
                title: "Oxygen",
                value: viewModel.formattedCurrentO2,
                unit: "%",
                color: VitalType.oxygenSaturation.color,
                dataPoints: viewModel.oxygenSaturationEntries.map { Double($0.percentage) },
                onTap: { selectedVital = .oxygenSaturation }
            )
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Vitals overview")
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedVital: VitalType = .overview

        var body: some View {
            ScrollView {
                VitalsOverviewView(
                    viewModel: TrendsViewModel(),
                    selectedVital: $selectedVital
                )
                .padding()
            }
            .background(Color.hrtBackgroundFallback)
        }
    }

    return PreviewWrapper()
}
