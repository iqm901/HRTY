import SwiftUI

/// View for entering blood pressure readings (systolic/diastolic)
struct BloodPressureEntryView: View {
    @Binding var systolicInput: String
    @Binding var diastolicInput: String
    let isHealthKitAvailable: Bool
    let isLoadingHealthKit: Bool
    let healthKitTimestamp: String?
    let validationError: String?
    let showSaveSuccess: Bool
    let onImportFromHealthKit: () -> Void
    let onSave: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var focusedField: Field?

    enum Field {
        case systolic
        case diastolic
    }

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            sectionHeader

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

    // MARK: - Section Header

    private var sectionHeader: some View {
        HStack {
            Image(systemName: "heart.circle.fill")
                .foregroundStyle(Color.hrtPinkFallback)
            Text("Blood Pressure")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Blood pressure section")
    }

    // MARK: - Input Fields

    private var bloodPressureInputFields: some View {
        HStack(spacing: HRTSpacing.md) {
            VStack(spacing: HRTSpacing.xs) {
                Text("Systolic")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                TextField("120", text: $systolicInput)
                    .keyboardType(.numberPad)
                    .font(.hrtMetricMedium)
                    .multilineTextAlignment(.center)
                    .padding(HRTSpacing.md)
                    .frame(height: 60)
                    .background(Color.hrtBackgroundSecondaryFallback)
                    .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                    .focused($focusedField, equals: .systolic)
                    .accessibilityLabel("Systolic blood pressure")
                    .accessibilityHint("Enter the top number in millimeters of mercury")
            }

            Text("/")
                .font(.hrtTitle2)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .padding(.top, 20)

            VStack(spacing: HRTSpacing.xs) {
                Text("Diastolic")
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                TextField("80", text: $diastolicInput)
                    .keyboardType(.numberPad)
                    .font(.hrtMetricMedium)
                    .multilineTextAlignment(.center)
                    .padding(HRTSpacing.md)
                    .frame(height: 60)
                    .background(Color.hrtBackgroundSecondaryFallback)
                    .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                    .focused($focusedField, equals: .diastolic)
                    .accessibilityLabel("Diastolic blood pressure")
                    .accessibilityHint("Enter the bottom number in millimeters of mercury")
            }

            Text("mmHg")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .padding(.top, 20)
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
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 0.8
        case .large, .xLarge:
            return 0.9
        case .xxLarge, .xxxLarge:
            return 1.0
        case .accessibility1, .accessibility2:
            return 1.1
        case .accessibility3, .accessibility4, .accessibility5:
            return 1.2
        @unknown default:
            return 0.9
        }
    }

    private var healthKitImageScale: Image.Scale {
        dynamicTypeSize.isAccessibilitySize ? .large : .medium
    }

    private var healthKitButtonVerticalPadding: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium:
            return 12
        case .large, .xLarge:
            return 14
        case .xxLarge, .xxxLarge:
            return 16
        case .accessibility1, .accessibility2:
            return 18
        case .accessibility3, .accessibility4, .accessibility5:
            return 20
        @unknown default:
            return 14
        }
    }
}

#Preview {
    BloodPressureEntryView(
        systolicInput: .constant(""),
        diastolicInput: .constant(""),
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
