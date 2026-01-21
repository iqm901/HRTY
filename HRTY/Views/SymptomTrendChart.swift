import SwiftUI
import Charts

struct SymptomTrendChart: View {
    let symptomEntries: [SymptomDataPoint]
    let visibleSymptomTypes: [SymptomType]
    let alertDates: Set<Date>

    private var dateRange: ClosedRange<Date> {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        return startDate...endDate
    }

    private var filteredEntries: [SymptomDataPoint] {
        symptomEntries.filter { visibleSymptomTypes.contains($0.symptomType) }
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
                VStack(spacing: 8) {
                    Image(systemName: "waveform.path.ecg")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    Text("No symptom data to display")
                        .foregroundStyle(.secondary)
                    if visibleSymptomTypes.isEmpty {
                        Text("Try enabling some symptoms above")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .accessibilityLabel("Symptom chart with no data")
    }

    private var chartContent: some View {
        Chart {
            alertMarks
            symptomMarks
        }
        .chartXScale(domain: dateRange)
        .chartYScale(domain: 0.5...5.5)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 2, 3, 4, 5]) { value in
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
        .accessibilityHint("Shows your symptom severity over the past 30 days. Days with concerning symptoms are highlighted.")
    }

    @ChartContentBuilder
    private var alertMarks: some ChartContent {
        ForEach(Array(alertDates), id: \.self) { date in
            RectangleMark(
                xStart: .value("Start", Calendar.current.startOfDay(for: date)),
                xEnd: .value("End", Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date),
                yStart: .value("Bottom", 0.5),
                yEnd: .value("Top", 5.5)
            )
            .foregroundStyle(Color.red.opacity(0.1))
        }
    }

    @ChartContentBuilder
    private var symptomMarks: some ChartContent {
        ForEach(visibleSymptomTypes, id: \.self) { symptomType in
            symptomMarks(for: symptomType)
        }
    }

    @ChartContentBuilder
    private func symptomMarks(for symptomType: SymptomType) -> some ChartContent {
        let entries = filteredEntries.filter { $0.symptomType == symptomType }
        let color = TrendsViewModel.color(for: symptomType)
        ForEach(entries) { entry in
            LineMark(
                x: .value("Date", entry.date, unit: .day),
                y: .value("Severity", entry.severity)
            )
            .foregroundStyle(color)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.linear)

            PointMark(
                x: .value("Date", entry.date, unit: .day),
                y: .value("Severity", entry.severity)
            )
            .foregroundStyle(color)
            .symbolSize(entry.hasAlert ? 80 : 40)
        }
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
    let sampleData: [SymptomDataPoint] = {
        let calendar = Calendar.current
        var entries: [SymptomDataPoint] = []

        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -29 + i, to: Date()) {
                if i % 3 != 0 {
                    entries.append(SymptomDataPoint(
                        date: date,
                        symptomType: .dyspneaAtRest,
                        severity: Int.random(in: 1...3),
                        hasAlert: false
                    ))
                    entries.append(SymptomDataPoint(
                        date: date,
                        symptomType: .chestPain,
                        severity: Int.random(in: 1...5),
                        hasAlert: Int.random(in: 1...5) >= 4
                    ))
                }
            }
        }
        return entries
    }()

    let alertDates: Set<Date> = {
        let calendar = Calendar.current
        var dates: Set<Date> = []
        if let date = calendar.date(byAdding: .day, value: -5, to: Date()) {
            dates.insert(calendar.startOfDay(for: date))
        }
        return dates
    }()

    return SymptomTrendChart(
        symptomEntries: sampleData,
        visibleSymptomTypes: [.dyspneaAtRest, .chestPain],
        alertDates: alertDates
    )
    .padding()
}
