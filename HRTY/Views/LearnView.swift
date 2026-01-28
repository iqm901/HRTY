import SwiftUI

/// A dedicated view for educational content about heart failure self-management.
/// Organized into expandable sections with topics sourced from authoritative guidelines.
struct LearnView: View {
    @State private var expandedSections: Set<UUID> = []
    @State private var selectedHeroTopic: LearnTopic?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

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
                                        .foregroundStyle(Color.hrtTextFallback)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.hrtCallout)
                                        .foregroundStyle(Color.hrtTextSecondaryFallback)
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
                                    if topic.heroImage != nil {
                                        // Hero image topics: present as full screen cover
                                        Button {
                                            selectedHeroTopic = topic
                                        } label: {
                                            HStack {
                                                Text(topic.title)
                                                    .font(.hrtBody)
                                                    .foregroundStyle(Color.hrtTextFallback)
                                                    .multilineTextAlignment(.leading)
                                                    .padding(.leading, 36)
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                                            }
                                        }
                                        .accessibilityLabel(topic.title)
                                        .accessibilityHint("Opens detailed information")
                                    } else {
                                        // Regular topics: use navigation
                                        NavigationLink(value: topic) {
                                            Text(topic.title)
                                                .font(.hrtBody)
                                                .foregroundStyle(Color.hrtTextFallback)
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
                }
                .listStyle(.insetGrouped)
                .listSectionSpacing(HRTSpacing.sm)
                .scrollContentBackground(.hidden)
            }
            .toolbarBackground(Color.hrtBackgroundFallback, for: .navigationBar)
            .navigationTitle("Learn")
            .navigationDestination(for: LearnTopic.self) { topic in
                LearnTopicDetailView(topic: topic)
            }
            .fullScreenCover(item: $selectedHeroTopic) { topic in
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
    @Environment(\.dismiss) private var dismiss
    let topic: LearnTopic

    private var hasHeroImage: Bool { topic.heroImage != nil }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if hasHeroImage {
                    // Hero image layout with overlapping content card
                    heroImageLayout
                } else {
                    // Standard layout with accent bar
                    accentBar
                    contentSection
                }
            }
        }
        .overlay(alignment: .topLeading) {
            if hasHeroImage {
                closeButton
            }
        }
        .ignoresSafeArea(edges: hasHeroImage ? .top : [])
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .padding(10)
                .background(.black.opacity(0.5))
                .clipShape(Circle())
        }
        .padding(.top, 60)
        .padding(.leading, 16)
    }

    // MARK: - Hero Image Layout

    private var heroImageLayout: some View {
        VStack(spacing: 0) {
            // Hero image extending to top, constrained to screen width
            if let heroImage = topic.heroImage {
                Image(heroImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 320)
                    .containerRelativeFrame(.horizontal)
                    .clipped()
            }

            // Content with rounded top corners, pulled up to overlap image
            contentSection
                .background(
                    Color(.systemBackground)
                        .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                )
                .offset(y: -40)
        }
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

// MARK: - Rounded Corner Shape

/// A shape that allows rounding only specific corners
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    LearnView()
}
