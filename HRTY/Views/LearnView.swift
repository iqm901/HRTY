import SwiftUI

/// A dedicated view for educational content about heart failure self-management.
/// Organized into expandable sections with topics sourced from authoritative guidelines.
struct LearnView: View {
    @State private var expandedSections: Set<UUID> = []
    @State private var selectedTopic: LearnTopic?

    var body: some View {
        NavigationStack {
            List {
                ForEach(EducationContent.learnSections) { section in
                    Section {
                        LearnSectionContent(
                            section: section,
                            isExpanded: expandedSections.contains(section.id),
                            onToggle: { toggleSection(section.id) },
                            onSelectTopic: { selectedTopic = $0 }
                        )
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Learn")
            .sheet(item: $selectedTopic) { topic in
                LearnTopicSheet(topic: topic)
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

// MARK: - Section Content

private struct LearnSectionContent: View {
    let section: LearnSection
    let isExpanded: Bool
    let onToggle: () -> Void
    let onSelectTopic: (LearnTopic) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Section header button
            Button(action: onToggle) {
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
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(section.title)
            .accessibilityHint(isExpanded ? "Collapse section" : "Expand section")
            .accessibilityAddTraits(.isButton)

            // Expandable topic list
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(section.topics) { topic in
                        Button {
                            onSelectTopic(topic)
                        } label: {
                            HStack {
                                Text(topic.title)
                                    .font(.hrtBody)
                                    .foregroundStyle(Color.primary)
                                    .multilineTextAlignment(.leading)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, HRTSpacing.xs)
                            .padding(.leading, 36)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(topic.title)
                        .accessibilityHint("Opens detailed information")
                    }
                }
                .padding(.top, HRTSpacing.sm)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Topic Detail Sheet

private struct LearnTopicSheet: View {
    let topic: LearnTopic
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HRTSpacing.lg) {
                    // Content
                    Text(formattedContent)
                        .font(.hrtBody)
                        .lineSpacing(4)

                    // Source citation
                    HStack(spacing: HRTSpacing.xs) {
                        Image(systemName: "book.closed.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Source: \(topic.source)")
                            .font(.hrtCaption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, HRTSpacing.sm)
                }
                .padding(HRTSpacing.lg)
            }
            .navigationTitle(topic.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

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
