import SwiftUI

/// View for entering oxygen saturation (SpO2) readings
struct OxygenSaturationEntryView: View {
    @Binding var oxygenInput: String
    let isHealthKitAvailable: Bool
    let isLoadingHealthKit: Bool
    let healthKitTimestamp: String?
    let validationError: String?
    let showSaveSuccess: Bool
    let onImportFromHealthKit: () -> Void
    let onSave: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            sectionHeader

            oxygenInputField

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
            Image(systemName: "lungs.fill")
                .foregroundStyle(Color.hrtPinkFallback)
            Text("Oxygen Saturation")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Oxygen saturation section")
    }

    // MARK: - Input Field

    private var oxygenInputField: some View {
        HStack(spacing: HRTSpacing.sm) {
            TextField("98", text: $oxygenInput)
                .keyboardType(.numberPad)
                .font(.hrtMetricMedium)
                .multilineTextAlignment(.center)
                .padding(HRTSpacing.md)
                .frame(height: 70)
                .background(Color.hrtBackgroundSecondaryFallback)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                .focused($isInputFocused)
                .accessibilityLabel("Oxygen saturation input")
                .accessibilityHint("Enter your oxygen saturation percentage, typically 95 to 100")

            Text("%")
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
        .accessibilityLabel(isLoadingHealthKit ? "Importing oxygen saturation from Health" : "Import oxygen saturation from Health app")
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
            isInputFocused = false
            onSave()
        } label: {
            Text("Save Oxygen Level")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .disabled(oxygenInput.isEmpty)
        .accessibilityLabel("Save oxygen level button")
        .accessibilityHint("Tap to save your oxygen saturation reading")
    }

    private var successFeedback: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)
            Text("Oxygen level saved!")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtGoodFallback)
        }
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Oxygen level saved successfully")
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
    OxygenSaturationEntryView(
        oxygenInput: .constant(""),
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
