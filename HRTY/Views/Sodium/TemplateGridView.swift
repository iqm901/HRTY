import SwiftUI

struct TemplateGridView: View {
    let templates: [SodiumTemplate]
    let onTap: (SodiumTemplate) -> Void
    let onLongPress: (SodiumTemplate) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: HRTSpacing.sm),
        GridItem(.flexible(), spacing: HRTSpacing.sm)
    ]

    var body: some View {
        if templates.isEmpty {
            emptyState
        } else {
            LazyVGrid(columns: columns, spacing: HRTSpacing.sm) {
                ForEach(templates, id: \.id) { template in
                    TemplateCard(template: template)
                        .onTapGesture {
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                            onTap(template)
                        }
                        .onLongPressGesture {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            onLongPress(template)
                        }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: HRTSpacing.sm) {
            Image(systemName: "star")
                .font(.system(size: 24))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("No templates yet")
                .font(.hrtSubheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("Save items you eat often for quick logging")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HRTSpacing.lg)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Template Card

private struct TemplateCard: View {
    let template: SodiumTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.xs) {
            HStack {
                Image(systemName: template.category.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.hrtPinkFallback)

                Spacer()

                Text(SodiumConstants.formatSodium(template.sodiumMg))
                    .font(.hrtCaption)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hrtPinkFallback)
            }

            Text(template.name)
                .font(.hrtSubheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.hrtTextFallback)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            if let serving = template.servingSize, !serving.isEmpty {
                Text(serving)
                    .font(.hrtCaption)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                    .lineLimit(1)
            }
        }
        .padding(HRTSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.hrtPinkLightFallback, lineWidth: 1)
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(template.name), \(template.sodiumMg) milligrams")
        .accessibilityHint("Double tap to log, long press to edit")
    }
}

#Preview {
    let templates = [
        SodiumTemplate(name: "Morning Coffee", sodiumMg: 50, servingSize: "1 cup", category: .beverage, usageCount: 15),
        SodiumTemplate(name: "Breakfast Cereal", sodiumMg: 210, servingSize: "1 bowl", category: .breakfast, usageCount: 10),
        SodiumTemplate(name: "Lunch Sandwich", sodiumMg: 650, category: .lunch, usageCount: 8),
        SodiumTemplate(name: "Afternoon Snack", sodiumMg: 180, servingSize: "1 package", category: .snack, usageCount: 5)
    ]

    return VStack {
        TemplateGridView(
            templates: templates,
            onTap: { _ in },
            onLongPress: { _ in }
        )
        .padding()
    }
    .background(Color.hrtBackgroundFallback)
}

#Preview("Empty") {
    TemplateGridView(
        templates: [],
        onTap: { _ in },
        onLongPress: { _ in }
    )
    .padding()
    .background(Color.hrtBackgroundFallback)
}
