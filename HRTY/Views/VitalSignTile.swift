import SwiftUI

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
        case .oxygenSaturation: return Color(red: 0.45, green: 0.75, blue: 0.85)
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
                        .font(.hrtMetricSmallLight)
                        .foregroundStyle(Color.hrtTextFallback)
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

#Preview("Grid State") {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: HRTSpacing.sm) {
        VitalSignTile(
            type: .weight,
            isCompleted: true,
            lastValue: "165.2",
            isExpanded: false,
            isCollapsed: false,
            onTap: {}
        )

        VitalSignTile(
            type: .bloodPressure,
            isCompleted: false,
            lastValue: nil,
            isExpanded: false,
            isCollapsed: false,
            onTap: {}
        )

        VitalSignTile(
            type: .heartRate,
            isCompleted: true,
            lastValue: "72",
            isExpanded: false,
            isCollapsed: false,
            onTap: {}
        )

        VitalSignTile(
            type: .oxygenSaturation,
            isCompleted: false,
            lastValue: nil,
            isExpanded: false,
            isCollapsed: false,
            onTap: {}
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
            onTap: {}
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
