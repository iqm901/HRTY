import SwiftUI

/// Prompt card shown on TodayView to encourage profile completion
struct ProfileCompletionPromptView: View {
    let completedCount: Int
    let totalCount: Int
    let onTapComplete: () -> Void

    var body: some View {
        VStack(spacing: HRTSpacing.md) {
            headerSection
            descriptionSection
            progressSection
            actionButton
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .overlay {
            RoundedRectangle(cornerRadius: HRTRadius.large)
                .strokeBorder(Color.hrtPinkFallback.opacity(0.3), lineWidth: 1)
        }
    }

    private var headerSection: some View {
        HStack {
            Image(systemName: "heart.text.square.fill")
                .foregroundStyle(Color.hrtPinkFallback)
                .font(.title2)
            Text("Prepare for Your Next Visit")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)
            Spacer()
        }
    }

    private var descriptionSection: some View {
        Text("Add a few details from your doctor visits to help track your heart health over time.")
            .font(.hrtCallout)
            .foregroundStyle(Color.hrtTextSecondaryFallback)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var progressSection: some View {
        HStack(spacing: HRTSpacing.sm) {
            ProgressView(value: Double(completedCount), total: Double(totalCount))
                .tint(Color.hrtPinkFallback)
            Text("\(completedCount)/\(totalCount)")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(completedCount) of \(totalCount) profile items completed")
    }

    private var actionButton: some View {
        Button(action: onTapComplete) {
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: "plus.circle.fill")
                Text("Complete Profile")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .accessibilityHint("Opens the health profile form")
    }
}

// MARK: - Preview

#Preview("Empty Profile") {
    ProfileCompletionPromptView(
        completedCount: 0,
        totalCount: 2,
        onTapComplete: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}

#Preview("Partial Profile") {
    ProfileCompletionPromptView(
        completedCount: 1,
        totalCount: 2,
        onTapComplete: {}
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
