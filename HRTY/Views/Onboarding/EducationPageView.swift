import SwiftUI

/// A page displaying educational content during onboarding.
/// Provides an optional learning moment before diving into permissions and setup.
struct EducationPageView: View {
    let education: OnboardingEducation
    let pageNumber: Int
    let totalEducationPages: Int
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: education.icon)
                .font(.system(size: 64))
                .foregroundStyle(.pink)
                .accessibilityHidden(true)

            // Title
            Text(education.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            // Content
            Text(formattedContent)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)
                .padding(.horizontal, 32)
                .lineSpacing(4)

            // Source
            Text("Source: \(education.source)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 32)

            Spacer()

            // Page indicator
            HStack(spacing: 8) {
                ForEach(0..<totalEducationPages, id: \.self) { index in
                    Circle()
                        .fill(index == pageNumber ? Color.pink : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Page \(pageNumber + 1) of \(totalEducationPages)")

            // Buttons
            VStack(spacing: 12) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .accessibilityHint("Proceed to the next page")

                Button(action: onSkip) {
                    Text("Skip Learning")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityHint("Skip the remaining education pages")
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }

    /// Parse content for markdown-style bold text
    private var formattedContent: AttributedString {
        var result = AttributedString()
        let content = education.content

        // Split by bold markers
        let parts = content.components(separatedBy: "**")

        for (index, part) in parts.enumerated() {
            var attributedPart = AttributedString(part)
            // Odd indices are bold (between ** markers)
            if index % 2 == 1 {
                attributedPart.font = .body.bold()
            }
            result.append(attributedPart)
        }

        return result
    }
}

#Preview("Why Tracking Matters") {
    EducationPageView(
        education: EducationContent.Onboarding.whyTrackingMatters,
        pageNumber: 0,
        totalEducationPages: 3,
        onContinue: {},
        onSkip: {}
    )
}

#Preview("Know Your Zones") {
    EducationPageView(
        education: EducationContent.Onboarding.knowYourZones,
        pageNumber: 1,
        totalEducationPages: 3,
        onContinue: {},
        onSkip: {}
    )
}
