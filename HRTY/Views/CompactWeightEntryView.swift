import SwiftUI

/// Compact inline view for entering weight with lbs/kg unit toggle
struct CompactWeightEntryView: View {
    @Binding var weightInput: String
    @Binding var weightUnit: String
    let isHealthKitAvailable: Bool
    let isLoadingHealthKit: Bool
    let healthKitTimestamp: String?
    let healthKitError: String?
    let healthKitRecoverySuggestion: String?
    let validationError: String?
    let showSaveSuccess: Bool
    let previousWeight: Double?
    let weightChangeText: String?
    let onImportFromHealthKit: () -> Void
    let onSave: () -> Void
    let onClearHealthKit: () -> Void
    let onDone: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isWeightFieldFocused: Bool

    private let lbsToKg = 0.453592
    private let kgToLbs = 2.20462

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            header

            unitToggle

            weightInputField

            if let timestamp = healthKitTimestamp {
                healthKitTimestampView(timestamp)
            }

            if isHealthKitAvailable {
                importFromHealthButton
            }

            if let error = healthKitError {
                healthKitErrorView(error)
            }

            if let error = validationError {
                validationErrorView(error)
            }

            saveButton

            if showSaveSuccess {
                successFeedback
            }

            previousWeightView
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .animation(HRTAnimation.standard, value: showSaveSuccess)
        .animation(HRTAnimation.standard, value: weightUnit)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Image(systemName: "scalemass.fill")
                .foregroundStyle(Color.hrtPinkFallback)
                .font(.title3)

            Text("Weight")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)

            Spacer()

            Button(action: onDone) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
            .accessibilityLabel("Close weight entry")
        }
    }

    // MARK: - Unit Toggle

    private var unitToggle: some View {
        Picker("Unit", selection: $weightUnit) {
            Text("lbs").tag("lbs")
            Text("kg").tag("kg")
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Weight unit")
        .accessibilityHint("Choose between pounds and kilograms")
    }

    // MARK: - Input Field

    private var weightInputField: some View {
        HStack(spacing: HRTSpacing.sm) {
            TextField("Enter weight", text: $weightInput)
                .keyboardType(.decimalPad)
                .font(.hrtMetricMediumLight)
                .multilineTextAlignment(.center)
                .padding(HRTSpacing.md)
                .frame(height: 56)
                .background(Color.hrtBackgroundSecondaryFallback)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
                .focused($isWeightFieldFocused)
                .accessibilityLabel("Weight input")
                .accessibilityHint("Enter your weight in \(weightUnit == "lbs" ? "pounds" : "kilograms")")
                .onChange(of: weightInput) { _, _ in
                    if healthKitTimestamp != nil || healthKitError != nil {
                        onClearHealthKit()
                    }
                }

            Text(weightUnit)
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .frame(width: 40)
        }
    }

    // MARK: - HealthKit Import

    private var importFromHealthButton: some View {
        Button {
            Task {
                onImportFromHealthKit()
            }
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
        .accessibilityLabel(isLoadingHealthKit ? "Importing weight from Health" : "Import weight from Health app")
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
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
    }

    private func healthKitErrorView(_ error: String) -> some View {
        HStack(alignment: .top, spacing: HRTSpacing.sm) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(Color.hrtCautionFallback)
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                Text(error)
                    .font(.hrtFootnote)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                if let suggestion = healthKitRecoverySuggestion {
                    Text(suggestion)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Health import issue: \(error)")
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
            onSave()
            isWeightFieldFocused = false
        } label: {
            Text("Save Weight")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .disabled(weightInput.isEmpty)
        .accessibilityLabel("Save weight button")
        .accessibilityHint("Tap to save your weight entry")
    }

    // MARK: - Success Feedback

    private var successFeedback: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)
            Text("Weight saved!")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtGoodFallback)
        }
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Weight saved successfully")
    }

    // MARK: - Previous Weight

    private var previousWeightView: some View {
        Group {
            if previousWeight == nil {
                Text("This is your first weight entry!")
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            } else if let changeText = weightChangeText {
                HStack(spacing: HRTSpacing.sm) {
                    Image(systemName: weightChangeIcon)
                        .foregroundStyle(weightChangeColor)
                    Text(changeText)
                        .font(.hrtCaption)
                        .foregroundStyle(weightChangeColor)
                }
                .padding(.horizontal, HRTSpacing.sm)
                .padding(.vertical, HRTSpacing.xs)
                .background(weightChangeBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.small))
            }
        }
    }

    private var weightChangeIcon: String {
        guard let text = weightChangeText else { return "equal.circle.fill" }
        if text.contains("up") { return "arrow.up.circle.fill" }
        if text.contains("down") { return "arrow.down.circle.fill" }
        return "equal.circle.fill"
    }

    private var weightChangeColor: Color {
        guard let text = weightChangeText else { return Color.hrtGoodFallback }
        if text.contains("up") { return Color.hrtCautionFallback }
        if text.contains("down") { return Color.hrtTextSecondaryFallback }
        return Color.hrtGoodFallback
    }

    private var weightChangeBackgroundColor: Color {
        guard let text = weightChangeText else { return Color.hrtGoodFallback.opacity(0.15) }
        if text.contains("up") { return Color.hrtCautionFallback.opacity(0.15) }
        if text.contains("down") { return Color.hrtBackgroundSecondaryFallback }
        return Color.hrtGoodFallback.opacity(0.15)
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
    CompactWeightEntryView(
        weightInput: .constant(""),
        weightUnit: .constant("lbs"),
        isHealthKitAvailable: true,
        isLoadingHealthKit: false,
        healthKitTimestamp: nil,
        healthKitError: nil,
        healthKitRecoverySuggestion: nil,
        validationError: nil,
        showSaveSuccess: false,
        previousWeight: 165.0,
        weightChangeText: "Your weight is stable from yesterday",
        onImportFromHealthKit: {},
        onSave: {},
        onClearHealthKit: {},
        onDone: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
