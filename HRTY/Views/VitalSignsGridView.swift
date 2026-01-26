import SwiftUI
import SwiftData

/// Control Center-style 2x2 grid for vital signs entry with inline expansion
struct VitalSignsGridView: View {
    @Bindable var viewModel: TodayViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var expandedTile: VitalSignType?
    @AppStorage(AppStorageKeys.weightUnit) private var weightUnit: String = "lbs"

    private let gridColumns = [
        GridItem(.flexible(), spacing: HRTSpacing.sm),
        GridItem(.flexible(), spacing: HRTSpacing.sm)
    ]

    var body: some View {
        VStack(spacing: HRTSpacing.sm) {
            if let expanded = expandedTile {
                expandedContent(for: expanded)

                collapsedTilesRow(excluding: expanded)
            } else {
                gridContent
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: expandedTile)
    }

    // MARK: - Grid Content (Normal State)

    private var gridContent: some View {
        LazyVGrid(columns: gridColumns, spacing: HRTSpacing.sm) {
            ForEach(VitalSignType.allCases) { type in
                VitalSignTile(
                    type: type,
                    isCompleted: isCompleted(for: type),
                    lastValue: lastValue(for: type),
                    isExpanded: false,
                    isCollapsed: false,
                    onTap: {
                        withAnimation {
                            expandedTile = type
                        }
                    }
                )
            }
        }
    }

    // MARK: - Expanded Content

    @ViewBuilder
    private func expandedContent(for type: VitalSignType) -> some View {
        switch type {
        case .weight:
            CompactWeightEntryView(
                weightInput: $viewModel.weightInput,
                weightUnit: $weightUnit,
                isHealthKitAvailable: viewModel.isHealthKitAvailable,
                isLoadingHealthKit: viewModel.isLoadingHealthKit,
                healthKitTimestamp: viewModel.healthKitTimestampText,
                healthKitError: viewModel.healthKitError,
                healthKitRecoverySuggestion: viewModel.healthKitRecoverySuggestion,
                validationError: viewModel.validationError,
                showSaveSuccess: viewModel.showSaveSuccess,
                previousWeight: viewModel.previousWeight,
                weightChangeText: viewModel.weightChangeText,
                onImportFromHealthKit: {
                    Task {
                        await viewModel.importWeightFromHealthKit()
                    }
                },
                onSave: {
                    viewModel.saveWeight(context: modelContext)
                },
                onClearHealthKit: {
                    viewModel.clearHealthKitWeight()
                },
                onDone: {
                    withAnimation {
                        expandedTile = nil
                    }
                }
            )

        case .bloodPressure:
            CompactBloodPressureEntryView(
                systolicInput: $viewModel.systolicBPInput,
                diastolicInput: $viewModel.diastolicBPInput,
                isHealthKitAvailable: viewModel.isHealthKitAvailable,
                isLoadingHealthKit: viewModel.isLoadingBPHealthKit,
                healthKitTimestamp: viewModel.bloodPressureHealthKitTimestamp,
                validationError: viewModel.bloodPressureValidationError,
                showSaveSuccess: viewModel.showBPSaveSuccess,
                onImportFromHealthKit: {
                    Task {
                        await viewModel.importBloodPressureFromHealthKit()
                    }
                },
                onSave: {
                    viewModel.saveBloodPressure(context: modelContext)
                },
                onDone: {
                    withAnimation {
                        expandedTile = nil
                    }
                }
            )

        case .heartRate:
            CompactHeartRateEntryView(
                heartRateInput: $viewModel.heartRateInput,
                isHealthKitAvailable: viewModel.isHealthKitAvailable,
                isLoadingHealthKit: viewModel.isLoadingHRHealthKit,
                healthKitTimestamp: viewModel.heartRateHealthKitTimestamp,
                validationError: viewModel.heartRateValidationError,
                showSaveSuccess: viewModel.showHRSaveSuccess,
                onImportFromHealthKit: {
                    Task {
                        await viewModel.importHeartRateFromHealthKit()
                    }
                },
                onSave: {
                    viewModel.saveHeartRate(context: modelContext)
                },
                onDone: {
                    withAnimation {
                        expandedTile = nil
                    }
                }
            )

        case .oxygenSaturation:
            CompactOxygenSaturationEntryView(
                oxygenInput: $viewModel.oxygenSaturationInput,
                isHealthKitAvailable: viewModel.isHealthKitAvailable,
                isLoadingHealthKit: viewModel.isLoadingSpO2HealthKit,
                healthKitTimestamp: viewModel.oxygenSaturationHealthKitTimestamp,
                validationError: viewModel.oxygenSaturationValidationError,
                showSaveSuccess: viewModel.showSpO2SaveSuccess,
                onImportFromHealthKit: {
                    Task {
                        await viewModel.importOxygenSaturationFromHealthKit()
                    }
                },
                onSave: {
                    viewModel.saveOxygenSaturation(context: modelContext)
                },
                onDone: {
                    withAnimation {
                        expandedTile = nil
                    }
                }
            )
        }
    }

    // MARK: - Collapsed Tiles Row

    private func collapsedTilesRow(excluding expandedType: VitalSignType) -> some View {
        HStack(spacing: HRTSpacing.sm) {
            ForEach(VitalSignType.allCases.filter { $0 != expandedType }) { type in
                VitalSignTile(
                    type: type,
                    isCompleted: isCompleted(for: type),
                    lastValue: lastValue(for: type),
                    isExpanded: false,
                    isCollapsed: true,
                    onTap: {
                        withAnimation {
                            expandedTile = type
                        }
                    }
                )
            }
        }
    }

    // MARK: - Helper Methods

    private func isCompleted(for type: VitalSignType) -> Bool {
        switch type {
        case .weight:
            return viewModel.hasEnteredWeightToday
        case .bloodPressure:
            return viewModel.hasEnteredBPToday
        case .heartRate:
            return viewModel.hasEnteredHRToday
        case .oxygenSaturation:
            return viewModel.hasEnteredSpO2Today
        }
    }

    private func lastValue(for type: VitalSignType) -> String? {
        switch type {
        case .weight:
            return viewModel.todayWeightValue
        case .bloodPressure:
            return viewModel.todayBPValue
        case .heartRate:
            return viewModel.todayHRValue
        case .oxygenSaturation:
            return viewModel.todaySpO2Value
        }
    }
}

#Preview {
    VitalSignsGridView(viewModel: TodayViewModel())
        .modelContainer(for: DailyEntry.self, inMemory: true)
        .padding()
        .background(Color.hrtBackgroundFallback)
}
