import SwiftUI

// MARK: - HRT Severity Selector

/// A horizontal selector for choosing symptom severity (1-5)
struct HRTSeveritySelector: View {
    @Binding var selectedLevel: Int
    let labels: [String]

    @ScaledMetric(relativeTo: .body) private var buttonSize: CGFloat = 48

    init(
        selectedLevel: Binding<Int>,
        labels: [String] = ["None", "Mild", "Mod", "High", "Severe"]
    ) {
        self._selectedLevel = selectedLevel
        self.labels = labels
    }

    var body: some View {
        HStack(spacing: HRTSpacing.sm) {
            ForEach(1...5, id: \.self) { level in
                severityButton(level: level)
            }
        }
    }

    private func severityButton(level: Int) -> some View {
        Button {
            withAnimation(HRTAnimation.spring) {
                selectedLevel = level
            }
        } label: {
            VStack(spacing: HRTSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(severityColor(level))
                        .frame(width: buttonSize, height: buttonSize)

                    Text("\(level)")
                        .font(.hrtBodySemibold)
                        .foregroundStyle(.white)
                }
                .overlay {
                    Circle()
                        .strokeBorder(
                            selectedLevel == level ? Color.hrtTextFallback : .clear,
                            lineWidth: 2.5
                        )
                }
                .scaleEffect(selectedLevel == level ? 1.1 : 1.0)

                Text(labels[safe: level - 1] ?? "")
                    .font(.hrtSmall)
                    .foregroundStyle(
                        selectedLevel == level
                            ? Color.hrtTextFallback
                            : Color.hrtTextTertiaryFallback
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Severity \(level), \(labels[safe: level - 1] ?? "")")
        .accessibilityAddTraits(selectedLevel == level ? .isSelected : [])
    }

    private func severityColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.hrtSeverity1Fallback
        case 2: return Color.hrtSeverity2Fallback
        case 3: return Color.hrtSeverity3Fallback
        case 4: return Color.hrtSeverity4Fallback
        case 5: return Color.hrtSeverity5Fallback
        default: return Color.hrtSeverity1Fallback
        }
    }
}

// MARK: - HRT Compact Severity Selector

/// A more compact severity selector for tighter spaces
struct HRTCompactSeveritySelector: View {
    @Binding var selectedLevel: Int

    @ScaledMetric(relativeTo: .caption) private var dotSize: CGFloat = 12

    var body: some View {
        HStack(spacing: HRTSpacing.sm) {
            ForEach(1...5, id: \.self) { level in
                Button {
                    withAnimation(HRTAnimation.spring) {
                        selectedLevel = level
                    }
                } label: {
                    Circle()
                        .fill(severityColor(level))
                        .frame(width: dotSize, height: dotSize)
                        .scaleEffect(selectedLevel == level ? 1.5 : 1.0)
                        .overlay {
                            if selectedLevel == level {
                                Circle()
                                    .strokeBorder(Color.hrtTextFallback, lineWidth: 1.5)
                                    .frame(width: dotSize * 1.5, height: dotSize * 1.5)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func severityColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.hrtSeverity1Fallback
        case 2: return Color.hrtSeverity2Fallback
        case 3: return Color.hrtSeverity3Fallback
        case 4: return Color.hrtSeverity4Fallback
        case 5: return Color.hrtSeverity5Fallback
        default: return Color.hrtSeverity1Fallback
        }
    }
}

// MARK: - HRT Severity Badge

/// A small badge showing a severity level
struct HRTSeverityBadge: View {
    let level: Int
    let showLabel: Bool

    init(level: Int, showLabel: Bool = false) {
        self.level = level
        self.showLabel = showLabel
    }

    var body: some View {
        HStack(spacing: HRTSpacing.xs) {
            Circle()
                .fill(severityColor(level))
                .frame(width: 10, height: 10)

            if showLabel {
                Text(severityLabel(level))
                    .font(.hrtSmall)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }
        }
    }

    private func severityColor(_ level: Int) -> Color {
        switch level {
        case 1: return Color.hrtSeverity1Fallback
        case 2: return Color.hrtSeverity2Fallback
        case 3: return Color.hrtSeverity3Fallback
        case 4: return Color.hrtSeverity4Fallback
        case 5: return Color.hrtSeverity5Fallback
        default: return Color.hrtSeverity1Fallback
        }
    }

    private func severityLabel(_ level: Int) -> String {
        switch level {
        case 1: return "None"
        case 2: return "Mild"
        case 3: return "Moderate"
        case 4: return "Significant"
        case 5: return "Severe"
        default: return "None"
        }
    }
}

// MARK: - Safe Array Access

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview("Severity Selectors") {
    VStack(spacing: 32) {
        VStack(alignment: .leading, spacing: 12) {
            Text("Standard Selector")
                .font(.hrtSectionLabel)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .textCase(.uppercase)

            HRTSeveritySelector(selectedLevel: .constant(3))
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Compact Selector")
                .font(.hrtSectionLabel)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .textCase(.uppercase)

            HRTCompactSeveritySelector(selectedLevel: .constant(2))
        }

        VStack(alignment: .leading, spacing: 12) {
            Text("Severity Badges")
                .font(.hrtSectionLabel)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .textCase(.uppercase)

            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { level in
                    HRTSeverityBadge(level: level, showLabel: true)
                }
            }
        }
    }
    .padding()
}
