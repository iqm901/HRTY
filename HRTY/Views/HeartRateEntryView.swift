import SwiftUI

/// View for entering heart rate readings with manual input and HealthKit import
struct HeartRateEntryView: View {
    @Binding var heartRateInput: String
    let isHealthKitAvailable: Bool
    let isLoadingHealthKit: Bool
    let healthKitTimestamp: String?
    let validationError: String?
    let showSaveSuccess: Bool
    let onImportFromHealthKit: () -> Void
    let onSave: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isFieldFocused: Bool

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            sectionHeader

            heartRateInputField

            if let timestamp = healthKitTimestamp {
                healthKitTimestampView(timestamp)
            }

            if isHealthKitAvailable {
                importFromHealthButton
            }

            if let error = validationError {
                validationErrorView(error)
            }

            saveButton

            if showSaveSuccess {
                successFeedback
            }
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .animation(HRTAnimation.standard, value: showSaveSuccess)
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

    // MARK: - Input Field

    private var heartRateInputField: some View {
        HStack(spacing: HRTSpacing.sm) {
            TextField("72", text: $heartRateInput)
                .keyboardType(.numberPad)
                .font(.hrtMetricMedium)
                .multilineTextAlignment(.center)
                .padding(HRTSpacing.md)
                .frame(height: 70)
                .background(Color.hrtBackgroundSecondaryFallback)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                .focused($isFieldFocused)
                .accessibilityLabel("Heart rate input")
                .accessibilityHint("Enter your resting heart rate in beats per minute")

            Text("bpm")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
    }

    // MARK: - HealthKit Import

    private var importFromHealthButton: some View {
        Button {
            onImportFromHealthKit()
        } label: {
            HStack(spacing: HRTSpacing.sm) {
                if isLoadingHealthKit {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(Color.hrtPinkFallback)
                        .scaleEffect(healthKitIconScale)
                } else {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(Color.hrtPinkFallback)
                        .imageScale(healthKitImageScale)
                }
                Text(isLoadingHealthKit ? "Importing..." : "Import from Health")
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextFallback)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, healthKitButtonVerticalPadding)
            .background(Color.hrtBackgroundSecondaryFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        }
        .disabled(isLoadingHealthKit)
        .accessibilityLabel(isLoadingHealthKit ? "Importing heart rate from Health" : "Import heart rate from Health app")
    }

    private func healthKitTimestampView(_ text: String) -> some View {
        HStack(spacing: HRTSpacing.xs) {
            Image(systemName: "heart.fill")
                .foregroundStyle(Color.hrtPinkFallback)
                .imageScale(.small)
            Text(text)
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }

    private func validationErrorView(_ error: String) -> some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color.hrtAlertFallback)
            Text(error)
                .font(.hrtFootnote)
                .foregroundStyle(Color.hrtAlertFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(error)")
    }

    private var saveButton: some View {
        Button {
            isFieldFocused = false
            onSave()
        } label: {
            Text("Save Heart Rate")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .disabled(heartRateInput.isEmpty)
        .accessibilityLabel("Save heart rate button")
        .accessibilityHint("Tap to save your heart rate reading")
    }

    private var successFeedback: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)
            Text("Heart rate saved!")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtGoodFallback)
        }
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Heart rate saved successfully")
    }

    // MARK: - Dynamic Type Support

    private var healthKitIconScale: CGFloat {
        HRTDynamicTypeScaling.progressIndicatorScale(for: dynamicTypeSize)
    }

    private var healthKitImageScale: Image.Scale {
        HRTDynamicTypeScaling.buttonIconScale(for: dynamicTypeSize)
    }

    private var healthKitButtonVerticalPadding: CGFloat {
        HRTDynamicTypeScaling.secondaryButtonVerticalPadding(for: dynamicTypeSize)
    }
}

#Preview {
    HeartRateEntryView(
        heartRateInput: .constant(""),
        isHealthKitAvailable: true,
        isLoadingHealthKit: false,
        healthKitTimestamp: nil,
        validationError: nil,
        showSaveSuccess: false,
        onImportFromHealthKit: {},
        onSave: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("With Data") {
    HeartRateEntryView(
        heartRateInput: .constant("72"),
        isHealthKitAvailable: true,
        isLoadingHealthKit: false,
        healthKitTimestamp: "from Health 2 hours ago",
        validationError: nil,
        showSaveSuccess: false,
        onImportFromHealthKit: {},
        onSave: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Success") {
    HeartRateEntryView(
        heartRateInput: .constant("72"),
        isHealthKitAvailable: true,
        isLoadingHealthKit: false,
        healthKitTimestamp: nil,
        validationError: nil,
        showSaveSuccess: true,
        onImportFromHealthKit: {},
        onSave: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
