import SwiftUI
import Charts

struct SymptomTrendChart: View {
    let symptomEntries: [SymptomDataPoint]
    let visibleSymptoms: Set<SymptomType>
    let alertDates: Set<Date>
    let colorForSymptom: (SymptomType) -> Color

    private var dateRange: ClosedRange<Date> {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        return startDate...endDate
    }

    private var filteredEntries: [SymptomDataPoint] {
        symptomEntries.filter { visibleSymptoms.contains($0.symptomType) }
    }

    var body: some View {
        if filteredEntries.isEmpty {
            emptyChartPlaceholder
        } else {
            chartContent
        }
    }

    private var emptyChartPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.secondarySystemBackground))
            .frame(height: 220)
            .overlay {
                Text("No symptom data to display")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Symptom chart with no data")
    }

    private var chartContent: some View {
        Chart {
            // Draw lines for each visible symptom
            ForEach(Array(visibleSymptoms), id: \.self) { symptomType in
                let entries = symptomEntries
                    .filter { $0.symptomType == symptomType }
                    .sorted { $0.date < $1.date }

                ForEach(entries) { entry in
                    LineMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Severity", entry.severity)
                    )
                    .foregroundStyle(colorForSymptom(symptomType))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .interpolationMethod(.linear)

                    PointMark(
                        x: .value("Date", entry.date, unit: .day),
                        y: .value("Severity", entry.severity)
                    )
                    .foregroundStyle(colorForSymptom(symptomType))
                    .symbolSize(entry.hasAlert ? 80 : 30)
                }
                .foregroundStyle(by: .value("Symptom", symptomType.displayName))
            }

            // Alert day markers (subtle vertical rule)
            ForEach(Array(alertDates), id: \.self) { alertDate in
                RuleMark(x: .value("Alert", alertDate, unit: .day))
                    .foregroundStyle(Color.orange.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 4]))
            }
        }
        .chartXScale(domain: dateRange)
        .chartYScale(domain: 1...5)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks(values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let severity = value.as(Int.self) {
                        Text(severityLabel(for: severity))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartLegend(.hidden)
        .frame(height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Symptom trend chart")
        .accessibilityHint("Shows your symptom severity over the past 30 days")
    }

    private func severityLabel(for value: Int) -> String {
        switch value {
        case 1: return "None"
        case 2: return "Mild"
        case 3: return "Mod"
        case 4: return "Sig"
        case 5: return "Sev"
        default: return ""
        }
    }
}

#Preview {
    let calendar = Calendar.current
    var sampleData: [SymptomDataPoint] = []

    // Generate sample data for a few symptoms
    let sampleSymptoms: [SymptomType] = [.dyspneaAtRest, .dyspneaOnExertion, .dizziness]

    for i in 0..<30 {
        if let date = calendar.date(byAdding: .day, value: -29 + i, to: Date()) {
            if i % 3 != 0 { // Skip some days
                for symptom in sampleSymptoms {
                    sampleData.append(SymptomDataPoint(
                        date: date,
                        symptomType: symptom,
                        severity: Int.random(in: 1...5),
                        hasAlert: i % 7 == 0
                    ))
                }
            }
        }
    }

    let alertDates: Set<Date> = {
        var dates: Set<Date> = []
        for i in stride(from: 0, to: 30, by: 7) {
            if let date = calendar.date(byAdding: .day, value: -29 + i, to: Date()) {
                dates.insert(calendar.startOfDay(for: date))
            }
        }
        return dates
    }()

    return SymptomTrendChart(
        symptomEntries: sampleData,
        visibleSymptoms: Set(sampleSymptoms),
        alertDates: alertDates,
        colorForSymptom: { type in
            switch type {
            case .dyspneaAtRest: return .blue
            case .dyspneaOnExertion: return .cyan
            case .dizziness: return .orange
            default: return .gray
            }
        }
    )
    .padding()
}
