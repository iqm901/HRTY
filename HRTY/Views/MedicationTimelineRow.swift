import SwiftUI

/// A row displaying a single medication timeline event with visual timeline elements.
/// Used in the medication history section to show starts, changes, and discontinuations.
struct MedicationTimelineRow: View {
    let event: MedicationHistoryService.TimelineEvent
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: HRTSpacing.md) {
            // Timeline indicator
            timelineIndicator

            // Event content
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                // Medication name and date
                HStack {
                    Text(event.medicationName)
                        .font(.hrtHeadline)
                        .foregroundStyle(Color.hrtTextFallback)

                    Spacer()

                    Text(event.shortDate)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }

                // Event type badge
                eventTypeBadge

                // Change description
                Text(event.changeDescription)
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }
        }
        .padding(.vertical, HRTSpacing.sm)
    }

    // MARK: - Subviews

    private var timelineIndicator: some View {
        VStack(spacing: 0) {
            // Line above (if not first)
            if !isFirst {
                Rectangle()
                    .fill(Color.hrtTextSecondaryFallback.opacity(0.3))
                    .frame(width: 2, height: 12)
            } else {
                Spacer()
                    .frame(width: 2, height: 12)
            }

            // Dot
            Circle()
                .fill(dotColor)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle()
                        .strokeBorder(Color.hrtCardFallback, lineWidth: 2)
                )

            // Line below (if not last)
            if !isLast {
                Rectangle()
                    .fill(Color.hrtTextSecondaryFallback.opacity(0.3))
                    .frame(width: 2, height: 24)
            } else {
                Spacer()
                    .frame(width: 2, height: 24)
            }
        }
        .frame(width: 20)
    }

    private var eventTypeBadge: some View {
        HStack(spacing: HRTSpacing.xs) {
            Image(systemName: event.eventType.icon)
                .font(.caption2)

            Text(event.eventType.rawValue)
                .font(.hrtCaption)
        }
        .foregroundStyle(badgeTextColor)
        .padding(.horizontal, HRTSpacing.sm)
        .padding(.vertical, 2)
        .background(badgeBackgroundColor)
        .clipShape(Capsule())
    }

    // MARK: - Colors

    private var dotColor: Color {
        switch event.eventType {
        case .started:
            return Color.hrtGoodFallback
        case .doseChanged:
            return Color.hrtCautionFallback
        case .discontinued:
            return Color.hrtAlertFallback
        case .reactivated:
            return Color.hrtPinkFallback
        }
    }

    private var badgeTextColor: Color {
        switch event.eventType {
        case .started:
            return Color.hrtGoodFallback
        case .doseChanged:
            return Color.hrtCautionFallback
        case .discontinued:
            return Color.hrtAlertFallback
        case .reactivated:
            return Color.hrtPinkFallback
        }
    }

    private var badgeBackgroundColor: Color {
        switch event.eventType {
        case .started:
            return Color.hrtGoodFallback.opacity(0.15)
        case .doseChanged:
            return Color.hrtCautionFallback.opacity(0.15)
        case .discontinued:
            return Color.hrtAlertFallback.opacity(0.15)
        case .reactivated:
            return Color.hrtPinkFallback.opacity(0.15)
        }
    }
}

/// A grouped timeline section for a specific date
struct MedicationTimelineDateGroup: View {
    let date: Date
    let events: [MedicationHistoryService.TimelineEvent]
    let isFirstGroup: Bool
    let isLastGroup: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Date header
            Text(formattedDate)
                .font(.hrtSubheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hrtTextFallback)
                .padding(.leading, 32) // Align with event content
                .padding(.bottom, HRTSpacing.xs)

            // Events for this date
            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                let isFirst = isFirstGroup && index == 0
                let isLast = isLastGroup && index == events.count - 1
                MedicationTimelineRow(
                    event: event,
                    isFirst: isFirst,
                    isLast: isLast
                )
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

/// Container view that organizes timeline events by date
struct MedicationTimelineView: View {
    let events: [MedicationHistoryService.TimelineEvent]
    let maxEventsToShow: Int?

    init(events: [MedicationHistoryService.TimelineEvent], maxEventsToShow: Int? = nil) {
        self.events = events
        self.maxEventsToShow = maxEventsToShow
    }

    var body: some View {
        if events.isEmpty {
            emptyState
        } else {
            LazyVStack(alignment: .leading, spacing: HRTSpacing.sm) {
                ForEach(Array(displayedGroups.enumerated()), id: \.element.date) { index, group in
                    MedicationTimelineDateGroup(
                        date: group.date,
                        events: group.events,
                        isFirstGroup: index == 0,
                        isLastGroup: index == displayedGroups.count - 1
                    )
                }

                if hasMoreEvents {
                    moreEventsIndicator
                }
            }
        }
    }

    // MARK: - Private

    private var groupedEvents: [(date: Date, events: [MedicationHistoryService.TimelineEvent])] {
        let calendar = Calendar.current

        // Group events by date
        var groups: [Date: [MedicationHistoryService.TimelineEvent]] = [:]
        for event in events {
            let day = calendar.startOfDay(for: event.date)
            if groups[day] != nil {
                groups[day]?.append(event)
            } else {
                groups[day] = [event]
            }
        }

        // Sort groups by date (most recent first)
        return groups.map { (date: $0.key, events: $0.value) }
            .sorted { $0.date > $1.date }
    }

    private var displayedGroups: [(date: Date, events: [MedicationHistoryService.TimelineEvent])] {
        guard let max = maxEventsToShow else {
            return groupedEvents
        }

        var count = 0
        var result: [(date: Date, events: [MedicationHistoryService.TimelineEvent])] = []

        for group in groupedEvents {
            if count >= max {
                break
            }

            let remainingSlots = max - count
            if group.events.count <= remainingSlots {
                result.append(group)
                count += group.events.count
            } else {
                // Partial group
                let partialEvents = Array(group.events.prefix(remainingSlots))
                result.append((date: group.date, events: partialEvents))
                count = max
                break
            }
        }

        return result
    }

    private var hasMoreEvents: Bool {
        guard let max = maxEventsToShow else { return false }
        return events.count > max
    }

    private var moreEventsIndicator: some View {
        HStack {
            Spacer()
            Text("\(events.count - (maxEventsToShow ?? 0)) more events")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
            Spacer()
        }
        .padding(.top, HRTSpacing.xs)
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: HRTSpacing.sm) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                Text("No medication changes yet")
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }
            .padding(.vertical, HRTSpacing.lg)
            Spacer()
        }
    }
}

#Preview {
    MedicationTimelineView(events: [])
        .padding()
        .background(Color.hrtBackgroundFallback)
}
