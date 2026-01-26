import SwiftUI

/// Compact inline view for entering blood pressure readings
struct CompactBloodPressureEntryView: View {
    @Binding var systolicInput: String
    @Binding var diastolicInput: String
    let isHealthKitAvailable: Bool
    let isLoadingHealthKit: Bool
    let healthKitTimestamp: String?
    let validationError: String?
    let showSaveSuccess: Bool
    let onImportFromHealthKit: () -> Void
    let onSave: () -> Void
    let onDone: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var focusedField: Field?

    enum Field {
        case systolic
        case diastolic
    }

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            header

            bloodPressureInputFields

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

    // MARK: - Header

    private var header: some View {
        HStack {
            Image(systemName: "heart.circle.fill")
                .foregroundStyle(Color.hrtRoseFallback)
                .font(.title3)

            Text("Blood Pressure")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)

            Spacer()

            Button(action: onDone) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
            .accessibilityLabel("Close blood pressure entry")
        }
    }

    // MARK: - Input Fields

    private var bloodPressureInputFields: some View {
        HStack(alignment: .center, spacing: HRTSpacing.sm) {
            VStack(spacing: HRTSpacing.xs) {
                Text("Systolic")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                TextField("120", text: $systolicInput)
                    .keyboardType(.numberPad)
                    .font(.hrtMetricMediumLight)
                    .multilineTextAlignment(.center)
                    .padding(HRTSpacing.sm)
                    .frame(height: 56)
                    .background(Color.hrtBackgroundSecondaryFallback)
                    .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                    .focused($focusedField, equals: .systolic)
                    .accessibilityLabel("Systolic blood pressure")
                    .accessibilityHint("Enter the top number")
            }

            Text("/")
                .font(.hrtTitle2)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .accessibilityHidden(true)

            VStack(spacing: HRTSpacing.xs) {
                Text("Diastolic")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                TextField("80", text: $diastolicInput)
                    .keyboardType(.numberPad)
                    .font(.hrtMetricMediumLight)
                    .multilineTextAlignment(.center)
                    .padding(HRTSpacing.sm)
                    .frame(height: 56)
                    .background(Color.hrtBackgroundSecondaryFallback)
                    .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                    .focused($focusedField, equals: .diastolic)
                    .accessibilityLabel("Diastolic blood pressure")
                    .accessibilityHint("Enter the bottom number")
            }

            Text("mmHg")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .accessibilityHidden(true)
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
        .accessibilityLabel(isLoadingHealthKit ? "Importing blood pressure from Health" : "Import blood pressure from Health app")
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

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            focusedField = nil
            onSave()
        } label: {
            Text("Save Blood Pressure")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .disabled(systolicInput.isEmpty || diastolicInput.isEmpty)
        .accessibilityLabel("Save blood pressure button")
        .accessibilityHint("Tap to save your blood pressure reading")
    }

    // MARK: - Success Feedback

    private var successFeedback: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)
            Text("Blood pressure saved!")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtGoodFallback)
        }
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Blood pressure saved successfully")
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
    CompactBloodPressureEntryView(
        systolicInput: .constant(""),
        diastolicInput: .constant(""),
        isHealthKitAvailable: true,
        isLoadingHealthKit: false,
        healthKitTimestamp: nil,
        validationError: nil,
        showSaveSuccess: false,
        onImportFromHealthKit: {},
        onSave: {},
        onDone: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
