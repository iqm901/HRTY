import SwiftUI

/// A dedicated view for educational content about heart failure self-management.
/// Organized into expandable sections with topics sourced from authoritative guidelines.
struct LearnView: View {
    @State private var expandedSections: Set<UUID> = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(EducationContent.learnSections) { section in
                    Section {
                        // Section header button
                        Button {
                            toggleSection(section.id)
                        } label: {
                            HStack(spacing: HRTSpacing.sm) {
                                Image(systemName: section.icon)
                                    .font(.title3)
                                    .foregroundStyle(Color.hrtPinkFallback)
                                    .frame(width: 28)
                                    .accessibilityHidden(true)

                                Text(section.title)
                                    .font(.hrtHeadline)
                                    .foregroundStyle(Color.primary)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.hrtCallout)
                                    .foregroundStyle(.secondary)
                                    .rotationEffect(.degrees(expandedSections.contains(section.id) ? 90 : 0))
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(section.title)
                        .accessibilityHint(expandedSections.contains(section.id) ? "Collapse section" : "Expand section")
                        .accessibilityAddTraits(.isButton)

                        // Topic rows - shown when expanded
                        if expandedSections.contains(section.id) {
                            ForEach(section.topics) { topic in
                                NavigationLink(value: topic) {
                                    Text(topic.title)
                                        .font(.hrtBody)
                                        .foregroundStyle(Color.primary)
                                        .multilineTextAlignment(.leading)
                                        .padding(.leading, 36)
                                }
                                .accessibilityLabel(topic.title)
                                .accessibilityHint("Opens detailed information")
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Learn")
            .navigationDestination(for: LearnTopic.self) { topic in
                LearnTopicDetailView(topic: topic)
            }
        }
    }

    private func toggleSection(_ id: UUID) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if expandedSections.contains(id) {
                expandedSections.remove(id)
            } else {
                expandedSections.insert(id)
            }
        }
    }
}

// MARK: - Topic Detail View

/// Full-screen detail view for a Learn topic with accent color bar and content.
struct LearnTopicDetailView: View {
    let topic: LearnTopic

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Accent color bar
                accentBar

                // Content area
                contentSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    // MARK: - Accent Bar

    private var accentBar: some View {
        LinearGradient(
            colors: topic.heroColor.gradient,
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 6)
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.md) {
            // Title
            Text(topic.title)
                .font(.hrtTitle2)
                .fontWeight(.bold)
                .foregroundStyle(Color.primary)

            // Source attribution
            HStack(spacing: HRTSpacing.xs) {
                Image(systemName: "building.columns.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(topic.source)
                    .font(.hrtSubheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.vertical, HRTSpacing.sm)

            // Body content
            Text(formattedContent)
                .font(.hrtBody)
                .lineSpacing(6)
                .foregroundStyle(Color.primary)

            // Bottom source citation
            sourceFooter
        }
        .padding(.horizontal, HRTSpacing.lg)
        .padding(.top, HRTSpacing.lg)
        .padding(.bottom, HRTSpacing.xl)
    }

    // MARK: - Source Footer

    private var sourceFooter: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "book.closed.fill")
                .font(.footnote)
                .foregroundStyle(.tertiary)

            Text("Source: \(topic.source)")
                .font(.hrtCaption)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, HRTSpacing.lg)
    }

    // MARK: - Content Formatting

    /// Parse content for markdown-style bold text
    private var formattedContent: AttributedString {
        var result = AttributedString()
        let content = topic.content

        // Split by bold markers
        let parts = content.components(separatedBy: "**")

        for (index, part) in parts.enumerated() {
            var attributedPart = AttributedString(part)
            // Odd indices are bold (between ** markers)
            if index % 2 == 1 {
                attributedPart.font = .hrtBody.bold()
            }
            result.append(attributedPart)
        }

        return result
    }
}

#Preview {
    LearnView()
}
