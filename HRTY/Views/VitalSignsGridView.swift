import SwiftUI
import SwiftData

/// Control Center-style 2x2 grid for vital signs entry with inline expansion
struct VitalSignsGridView: View {
    @Bindable var viewModel: TodayViewModel
    @Environment(\.modelContext) private var modelContext

    @State private var expandedTile: VitalSignType?
    @AppStorage(AppStorageKeys.weightUnit) private var weightUnit: String = "lbs"
    @AppStorage(AppStorageKeys.showStreakCard) private var showStreakCard: Bool = true

    private let gridColumns = [
        GridItem(.flexible(), spacing: HRTSpacing.sm),
        GridItem(.flexible(), spacing: HRTSpacing.sm)
    ]

    var body: some View {
        VStack(spacing: HRTSpacing.sm) {
            if showStreakCard {
                streakMessageCard
            }

            if let expanded = expandedTile {
                expandedContent(for: expanded)
                    .transition(scaleTransition(for: expanded))

                collapsedTilesRow(excluding: expanded)
            } else {
                gridContent
            }

            // Educational tip for weight monitoring
            if expandedTile == .weight || expandedTile == nil {
                weightTipFooter
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: expandedTile)
    }

    // MARK: - Educational Footer

    private var weightTipFooter: some View {
        Text(EducationContent.Weight.techniqueTip)
            .font(.hrtFootnote)
            .foregroundStyle(Color.hrtTextTertiaryFallback)
            .multilineTextAlignment(.center)
            .padding(.horizontal, HRTSpacing.md)
            .padding(.top, HRTSpacing.xs)
    }

    // MARK: - Streak Message Card

    private var streakMessageCard: some View {
        HStack(alignment: .center, spacing: HRTSpacing.sm) {
            // Plus icon for streak
            if viewModel.currentStreak > 0 {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.hrtPinkFallback)
            }

            Text(viewModel.streakMessage)
                .font(.hrtSubheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            Button {
                withAnimation {
                    showStreakCard = false
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                    .padding(6)
                    .background(Color.hrtTextTertiaryFallback.opacity(0.15))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Dismiss streak message")
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Custom Transition

    private func scaleTransition(for type: VitalSignType) -> AnyTransition {
        .scale(scale: 0.01, anchor: type.gridAnchor)
        .combined(with: .opacity)
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
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            expandedTile = type
                        }
                    },
                    weightGain: weightGain,
                    heartRateValue: heartRateValue,
                    systolicBP: systolicBP,
                    diastolicBP: diastolicBP,
                    oxygenSaturationValue: oxygenSaturationValue,
                    displayUnit: displayUnit(for: type)
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
                    viewModel.saveWeight(context: modelContext, unit: weightUnit)
                    collapseAfterSave()
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
                    collapseAfterSave()
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
                    collapseAfterSave()
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
                    collapseAfterSave()
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
                    },
                    weightGain: weightGain,
                    heartRateValue: heartRateValue,
                    systolicBP: systolicBP,
                    diastolicBP: diastolicBP,
                    oxygenSaturationValue: oxygenSaturationValue,
                    displayUnit: displayUnit(for: type)
                )
            }
        }
    }

    // MARK: - Helper Methods

    /// Collapses the expanded tile immediately with smooth shrink-to-corner animation
    private func collapseAfterSave() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            expandedTile = nil
        }
    }

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

    private let lbsToKg = 0.453592

    private func lastValue(for type: VitalSignType) -> String? {
        switch type {
        case .weight:
            return formattedWeight
        case .bloodPressure:
            return viewModel.todayBPValue
        case .heartRate:
            return viewModel.todayHRValue
        case .oxygenSaturation:
            return viewModel.todaySpO2Value
        }
    }

    /// Weight formatted in the user's preferred unit
    private var formattedWeight: String? {
        guard let weightInLbs = viewModel.todayEntry?.weight else { return nil }
        if weightUnit == "kg" {
            let weightInKg = weightInLbs * lbsToKg
            return String(format: "%.1f", weightInKg)
        } else {
            return String(format: "%.1f", weightInLbs)
        }
    }

    /// Returns the display unit for a vital sign type
    /// Weight uses user's preference; others use their default unit
    private func displayUnit(for type: VitalSignType) -> String? {
        switch type {
        case .weight:
            return weightUnit
        default:
            return nil // Use default unit from VitalSignType
        }
    }

    // MARK: - Raw Values for Status Indicators

    private var weightGain: Double? {
        guard let current = viewModel.todayEntry?.weight,
              let previous = viewModel.previousWeight else {
            return nil
        }
        return current - previous
    }

    private var systolicBP: Int? {
        viewModel.todayEntry?.vitalSigns?.systolicBP
    }

    private var diastolicBP: Int? {
        viewModel.todayEntry?.vitalSigns?.diastolicBP
    }

    private var heartRateValue: Int? {
        viewModel.todayEntry?.vitalSigns?.heartRate
    }

    private var oxygenSaturationValue: Int? {
        viewModel.todayEntry?.vitalSigns?.oxygenSaturation
    }
}

#Preview {
    VitalSignsGridView(viewModel: TodayViewModel())
        .modelContainer(for: DailyEntry.self, inMemory: true)
        .padding()
        .background(Color.hrtBackgroundFallback)
}
