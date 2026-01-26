import SwiftUI

/// Represents the status of a vital sign value for display styling
enum VitalSignStatus {
    case normal
    case caution
    case critical

    var color: Color {
        switch self {
        case .normal:
            return Color.hrtTextFallback
        case .caution:
            return Color.hrtCautionFallback
        case .critical:
            return Color.hrtAlertFallback
        }
    }

    var fontWeight: Font.Weight {
        switch self {
        case .normal, .caution:
            return .regular
        case .critical:
            return .bold
        }
    }

    // MARK: - Static Methods for Determining Status

    /// Determine oxygen saturation status
    static func forOxygenSaturation(_ value: Int) -> VitalSignStatus {
        if value > AlertConstants.oxygenSaturationNormalThreshold {
            return .normal
        } else if value >= AlertConstants.oxygenSaturationCriticalThreshold {
            return .caution
        } else {
            return .critical
        }
    }

    /// Determine heart rate status
    static func forHeartRate(_ value: Int) -> VitalSignStatus {
        if value >= AlertConstants.heartRateNormalLow && value <= AlertConstants.heartRateNormalHigh {
            return .normal
        } else if value < AlertConstants.heartRateCriticalLow || value > AlertConstants.heartRateCriticalHigh {
            return .critical
        } else {
            return .caution
        }
    }

    /// Determine systolic blood pressure status
    static func forSystolicBP(_ value: Int) -> VitalSignStatus {
        if value >= AlertConstants.systolicBPNormalLow && value <= AlertConstants.systolicBPNormalHigh {
            return .normal
        } else if value < AlertConstants.systolicBPCriticalLow || value >= AlertConstants.systolicBPCriticalHigh {
            return .critical
        } else {
            return .caution
        }
    }

    /// Determine diastolic blood pressure status
    static func forDiastolicBP(_ value: Int) -> VitalSignStatus {
        if value >= AlertConstants.diastolicBPNormalLow && value <= AlertConstants.diastolicBPNormalHigh {
            return .normal
        } else if value < AlertConstants.diastolicBPCriticalLow || value >= AlertConstants.diastolicBPCriticalHigh {
            return .critical
        } else {
            return .caution
        }
    }

    /// Determine combined blood pressure status (worst of systolic and diastolic)
    static func forBloodPressure(systolic: Int, diastolic: Int) -> VitalSignStatus {
        let systolicStatus = forSystolicBP(systolic)
        let diastolicStatus = forDiastolicBP(diastolic)

        // Return the more severe status
        if systolicStatus == .critical || diastolicStatus == .critical {
            return .critical
        } else if systolicStatus == .caution || diastolicStatus == .caution {
            return .caution
        } else {
            return .normal
        }
    }

    /// Determine weight gain status
    static func forWeightGain(_ gain: Double) -> VitalSignStatus {
        if gain < AlertConstants.weightGain24hThreshold {
            return .normal
        } else if gain < AlertConstants.weightGain7dThreshold {
            return .caution
        } else {
            return .critical
        }
    }
}

/// Represents the types of vital signs that can be tracked
enum VitalSignType: String, CaseIterable, Identifiable {
    case weight
    case bloodPressure
    case heartRate
    case oxygenSaturation

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .weight: return "scalemass.fill"
        case .bloodPressure: return "heart.circle.fill"
        case .heartRate: return "heart.fill"
        case .oxygenSaturation: return "lungs.fill"
        }
    }

    var label: String {
        switch self {
        case .weight: return "Weight"
        case .bloodPressure: return "Blood Pressure"
        case .heartRate: return "Heart Rate"
        case .oxygenSaturation: return "Oxygen"
        }
    }

    var fullLabel: String {
        switch self {
        case .weight: return "Weight"
        case .bloodPressure: return "Blood Pressure"
        case .heartRate: return "Heart Rate"
        case .oxygenSaturation: return "Oxygen Saturation"
        }
    }

    var unit: String {
        switch self {
        case .weight: return "lbs"
        case .bloodPressure: return "mmHg"
        case .heartRate: return "bpm"
        case .oxygenSaturation: return "%"
        }
    }

    /// Anchor point for matched geometry animation based on grid position
    var gridAnchor: UnitPoint {
        switch self {
        case .weight: return .topLeading           // Top-left: expands down and right
        case .bloodPressure: return .topTrailing   // Top-right: expands down and left
        case .heartRate: return .bottomLeading     // Bottom-left: expands up and right
        case .oxygenSaturation: return .bottomTrailing // Bottom-right: expands up and left
        }
    }

    var color: Color {
        switch self {
        case .weight: return Color.hrtPinkFallback
        case .bloodPressure: return Color.hrtRoseFallback
        case .heartRate: return Color.hrtPinkFallback
        case .oxygenSaturation: return Color.hrtPinkFallback
        }
    }
}

/// A compact tile for displaying vital sign status in a grid layout
struct VitalSignTile: View {
    let type: VitalSignType
    let isCompleted: Bool
    let lastValue: String?
    let isExpanded: Bool
    let isCollapsed: Bool // When another tile is expanded
    let onTap: () -> Void

    // Optional raw values for status calculation
    var weightGain: Double?
    var heartRateValue: Int?
    var systolicBP: Int?
    var diastolicBP: Int?
    var oxygenSaturationValue: Int?

    /// Computed vital sign status based on raw values
    private var vitalSignStatus: VitalSignStatus {
        switch type {
        case .weight:
            guard let gain = weightGain, gain > 0 else { return .normal }
            return VitalSignStatus.forWeightGain(gain)
        case .heartRate:
            guard let hr = heartRateValue else { return .normal }
            return VitalSignStatus.forHeartRate(hr)
        case .bloodPressure:
            guard let sys = systolicBP, let dia = diastolicBP else { return .normal }
            return VitalSignStatus.forBloodPressure(systolic: sys, diastolic: dia)
        case .oxygenSaturation:
            guard let spo2 = oxygenSaturationValue else { return .normal }
            return VitalSignStatus.forOxygenSaturation(spo2)
        }
    }

    var body: some View {
        Button(action: onTap) {
            if isCollapsed {
                collapsedContent
            } else {
                fullContent
            }
        }
        .buttonStyle(VitalSignTileButtonStyle(isExpanded: isExpanded, isCollapsed: isCollapsed))
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(isCompleted ? "Tap to edit" : "Tap to enter \(type.fullLabel.lowercased())")
        .accessibilityAddTraits(isCompleted ? .isButton : [.isButton])
    }

    // MARK: - Full Content (Normal Grid State)

    private var fullContent: some View {
        VStack(spacing: HRTSpacing.sm) {
            HStack {
                Image(systemName: type.icon)
                    .font(.title2)
                    .foregroundStyle(type.color)

                Spacer()

                statusIndicator
            }

            HStack {
                Text(type.label)
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Spacer()
            }

            if let value = lastValue, isCompleted {
                HStack {
                    Text(value)
                        .font(.system(size: 24, weight: vitalSignStatus.fontWeight, design: .rounded))
                        .foregroundStyle(vitalSignStatus.color)
                    Text(type.unit)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                    Spacer()
                }
            } else {
                HStack {
                    Text("Not entered")
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                    Spacer()
                }
            }
        }
        .padding(HRTSpacing.md)
        .frame(minHeight: 100)
    }

    // MARK: - Collapsed Content (When Another Tile is Expanded)

    private var collapsedContent: some View {
        VStack(spacing: HRTSpacing.xs) {
            Image(systemName: type.icon)
                .font(.title3)
                .foregroundStyle(type.color)

            statusIndicator
        }
        .padding(HRTSpacing.sm)
        .frame(minWidth: 50, minHeight: 50)
    }

    // MARK: - Status Indicator

    private var statusIndicator: some View {
        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
            .font(.caption)
            .foregroundStyle(isCompleted ? Color.hrtGoodFallback : Color.hrtTextTertiaryFallback)
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        if isCompleted, let value = lastValue {
            return "\(type.fullLabel): \(value) \(type.unit), completed"
        } else {
            return "\(type.fullLabel): not entered"
        }
    }
}

// MARK: - Button Style

struct VitalSignTileButtonStyle: ButtonStyle {
    let isExpanded: Bool
    let isCollapsed: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: isCollapsed ? HRTRadius.medium : HRTRadius.large)
                    .fill(Color.hrtCardFallback)
            )
            .overlay(
                RoundedRectangle(cornerRadius: isCollapsed ? HRTRadius.medium : HRTRadius.large)
                    .strokeBorder(
                        isExpanded ? Color.hrtPinkFallback.opacity(0.5) : Color.clear,
                        lineWidth: 2
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Grid State - Normal") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HRTSpacing.sm) {
        VitalSignTile(
            type: .weight,
            isCompleted: true,
            lastValue: "165.2",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            weightGain: 0.5 // Normal - less than 2 lbs
        )

        VitalSignTile(
            type: .bloodPressure,
            isCompleted: true,
            lastValue: "120/80",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            systolicBP: 120,
            diastolicBP: 80 // Normal
        )

        VitalSignTile(
            type: .heartRate,
            isCompleted: true,
            lastValue: "72",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            heartRateValue: 72 // Normal
        )

        VitalSignTile(
            type: .oxygenSaturation,
            isCompleted: true,
            lastValue: "97",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            oxygenSaturationValue: 97 // Normal
        )
    }
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Grid State - Caution") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HRTSpacing.sm) {
        VitalSignTile(
            type: .weight,
            isCompleted: true,
            lastValue: "168.5",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            weightGain: 3.0 // Caution - 2-4.9 lbs gain
        )

        VitalSignTile(
            type: .bloodPressure,
            isCompleted: true,
            lastValue: "145/92",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            systolicBP: 145,
            diastolicBP: 92 // Caution
        )

        VitalSignTile(
            type: .heartRate,
            isCompleted: true,
            lastValue: "55",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            heartRateValue: 55 // Caution - bradycardia
        )

        VitalSignTile(
            type: .oxygenSaturation,
            isCompleted: true,
            lastValue: "90",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            oxygenSaturationValue: 90 // Caution
        )
    }
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Grid State - Critical") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HRTSpacing.sm) {
        VitalSignTile(
            type: .weight,
            isCompleted: true,
            lastValue: "172.0",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            weightGain: 6.0 // Critical - 5+ lbs gain
        )

        VitalSignTile(
            type: .bloodPressure,
            isCompleted: true,
            lastValue: "165/105",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            systolicBP: 165,
            diastolicBP: 105 // Critical
        )

        VitalSignTile(
            type: .heartRate,
            isCompleted: true,
            lastValue: "135",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            heartRateValue: 135 // Critical - severe tachycardia
        )

        VitalSignTile(
            type: .oxygenSaturation,
            isCompleted: true,
            lastValue: "85",
            isExpanded: false,
            isCollapsed: false,
            onTap: {},
            oxygenSaturationValue: 85 // Critical
        )
    }
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Collapsed State") {
    HStack(spacing: HRTSpacing.sm) {
        VitalSignTile(
            type: .bloodPressure,
            isCompleted: false,
            lastValue: nil,
            isExpanded: false,
            isCollapsed: true,
            onTap: {}
        )

        VitalSignTile(
            type: .heartRate,
            isCompleted: true,
            lastValue: "72",
            isExpanded: false,
            isCollapsed: true,
            onTap: {},
            heartRateValue: 72
        )

        VitalSignTile(
            type: .oxygenSaturation,
            isCompleted: false,
            lastValue: nil,
            isExpanded: false,
            isCollapsed: true,
            onTap: {}
        )
    }
    .padding()
    .background(Color.hrtBackgroundFallback)
}
