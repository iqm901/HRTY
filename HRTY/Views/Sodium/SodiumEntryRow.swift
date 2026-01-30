import SwiftUI

struct SodiumEntryRow: View {
    let entry: SodiumEntry

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        HStack(spacing: HRTSpacing.md) {
            // Source Icon
            ZStack {
                Circle()
                    .fill(Color.hrtPinkLightFallback)
                    .frame(width: 40, height: 40)

                Image(systemName: entry.source.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.hrtPinkFallback)
            }

            // Name and Details
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.hrtBody)
                    .foregroundStyle(Color.hrtTextFallback)
                    .lineLimit(1)

                HStack(spacing: HRTSpacing.xs) {
                    Text(timeFormatter.string(from: entry.timestamp))
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)

                    if let serving = entry.servingSize, !serving.isEmpty {
                        Text("·")
                            .foregroundStyle(Color.hrtTextTertiaryFallback)
                        Text(serving)
                            .font(.hrtCaption)
                            .foregroundStyle(Color.hrtTextTertiaryFallback)
                    }
                }
            }

            Spacer()

            // Sodium Amount
            Text(SodiumConstants.formatSodium(entry.sodiumMg))
                .font(.hrtBody)
                .fontWeight(.medium)
                .foregroundStyle(Color.hrtTextFallback)
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.sm)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(entry.name), \(entry.sodiumMg) milligrams, logged at \(timeFormatter.string(from: entry.timestamp))")
    }
}

#Preview {
    VStack(spacing: 0) {
        SodiumEntryRow(entry: SodiumEntry(
            name: "Morning Coffee",
            sodiumMg: 50,
            servingSize: "1 cup",
            source: .template
        ))

        Divider()
            .padding(.leading, 56)

        SodiumEntryRow(entry: SodiumEntry(
            name: "Canned Soup",
            sodiumMg: 890,
            servingSize: "1 can",
            source: .barcode
        ))

        Divider()
            .padding(.leading, 56)

        SodiumEntryRow(entry: SodiumEntry(
            name: "Lunch Sandwich",
            sodiumMg: 650,
            source: .manual
        ))
    }
    .background(Color.hrtCardFallback)
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(Color.hrtBackgroundFallback)
}
