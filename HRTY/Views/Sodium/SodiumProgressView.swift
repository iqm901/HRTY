import SwiftUI

struct SodiumProgressView: View {
    let currentMg: Int
    let limitMg: Int
    let progressColor: Color

    private var progressPercent: Double {
        guard limitMg > 0 else { return 0 }
        return min(Double(currentMg) / Double(limitMg), 1.0)
    }

    private var remainingMg: Int {
        max(0, limitMg - currentMg)
    }

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            // Main Total Display
            VStack(spacing: HRTSpacing.xs) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(SodiumConstants.numberFormatter.string(from: NSNumber(value: currentMg)) ?? "\(currentMg)")
                        .font(.system(size: 48, weight: .semibold, design: .rounded))
                        .foregroundStyle(progressColor)

                    Text("/")
                        .font(.hrtTitle2)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)

                    Text(SodiumConstants.numberFormatter.string(from: NSNumber(value: limitMg)) ?? "\(limitMg)")
                        .font(.hrtTitle2)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    Text("mg")
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }

                // Remaining text
                Text(SodiumConstants.formatRemaining(remainingMg))
                    .font(.hrtSubheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.hrtBackgroundSecondaryFallback)
                        .frame(height: 16)

                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * progressPercent, height: 16)
                        .animation(.easeInOut(duration: 0.3), value: progressPercent)
                }
            }
            .frame(height: 16)

            // Status Message
            Text(SodiumConstants.statusMessage(for: SodiumConstants.progressPercent(current: currentMg, limit: limitMg)))
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .multilineTextAlignment(.center)
        }
        .padding(HRTSpacing.lg)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Sodium intake: \(currentMg) of \(limitMg) milligrams. \(remainingMg) milligrams remaining.")
    }
}

#Preview("Under Limit") {
    SodiumProgressView(
        currentMg: 1240,
        limitMg: 2000,
        progressColor: .hrtGoodFallback
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Caution") {
    SodiumProgressView(
        currentMg: 1600,
        limitMg: 2000,
        progressColor: .hrtCautionFallback
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Alert") {
    SodiumProgressView(
        currentMg: 1900,
        limitMg: 2000,
        progressColor: .hrtAlertFallback
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
