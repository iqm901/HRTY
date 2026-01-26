import SwiftUI

/// Prompt card shown on TodayView to start or resume symptom check-in
struct SymptomCheckInPromptView: View {
    let hasIncompleteCheckIn: Bool
    let completedCount: Int
    let totalCount: Int
    let hasCompletedToday: Bool
    let onStartCheckIn: () -> Void

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            headerSection

            if hasCompletedToday {
                completedContent
            } else {
                checkInContent
            }
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack {
            Image(systemName: "heart.text.square.fill")
                .foregroundStyle(Color.hrtPinkFallback)
                .font(.title2)
            Text("Symptom Check-in")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)
            Spacer()

            if hasCompletedToday {
                completedBadge
            }
        }
    }

    private var completedBadge: some View {
        HStack(spacing: HRTSpacing.xs) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)
            Text("Done")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtGoodFallback)
        }
    }

    // MARK: - Completed Content

    private var completedContent: some View {
        VStack(spacing: HRTSpacing.sm) {
            Text("You've completed today's check-in.")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .multilineTextAlignment(.center)

            Button {
                onStartCheckIn()
            } label: {
                Text("Update Responses")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(HRTSecondaryButtonStyle())
            .accessibilityLabel("Update your symptom responses")
            .accessibilityHint("Tap to review and change your symptom check-in")
        }
    }

    // MARK: - Check-in Content

    private var checkInContent: some View {
        VStack(spacing: HRTSpacing.sm) {
            descriptionText

            if hasIncompleteCheckIn {
                progressIndicator
            }

            actionButton
        }
    }

    private var descriptionText: some View {
        Text(hasIncompleteCheckIn
             ? "You have an incomplete check-in. Pick up where you left off."
             : "Take a moment to check in on how you're feeling today.")
            .font(.hrtCallout)
            .foregroundStyle(Color.hrtTextSecondaryFallback)
            .multilineTextAlignment(.center)
    }

    private var progressIndicator: some View {
        HStack(spacing: HRTSpacing.sm) {
            ProgressView(value: Double(completedCount), total: Double(totalCount))
                .tint(Color.hrtPinkFallback)

            Text("\(completedCount)/\(totalCount)")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completedCount) of \(totalCount) symptoms completed")
    }

    private var actionButton: some View {
        Button {
            onStartCheckIn()
        } label: {
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: hasIncompleteCheckIn ? "arrow.forward.circle.fill" : "play.circle.fill")
                Text(hasIncompleteCheckIn ? "Resume Check-in" : "Start Check-in")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .accessibilityLabel(hasIncompleteCheckIn
                           ? "Resume symptom check-in at step \(completedCount + 1)"
                           : "Start symptom check-in")
        .accessibilityHint("Opens the symptom check-in wizard")
    }
}

// MARK: - Preview

#Preview("New Check-in") {
    SymptomCheckInPromptView(
        hasIncompleteCheckIn: false,
        completedCount: 0,
        totalCount: 8,
        hasCompletedToday: false,
        onStartCheckIn: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Resume Check-in") {
    SymptomCheckInPromptView(
        hasIncompleteCheckIn: true,
        completedCount: 4,
        totalCount: 8,
        hasCompletedToday: false,
        onStartCheckIn: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Completed") {
    SymptomCheckInPromptView(
        hasIncompleteCheckIn: false,
        completedCount: 8,
        totalCount: 8,
        hasCompletedToday: true,
        onStartCheckIn: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
