import SwiftUI
import Charts

/// Chart view displaying oxygen saturation trends over the past 30 days
struct OxygenSaturationTrendChart: View {
    let oxygenSaturationEntries: [OxygenSaturationDataPoint]
    let alertDates: Set<Date>

    /// Chart height that scales with Dynamic Type settings
    @ScaledMetric(relativeTo: .body) private var chartHeight: CGFloat = 220

    var body: some View {
        if oxygenSaturationEntries.isEmpty {
            emptyChartPlaceholder
        } else {
            chartContent
        }
    }

    private var emptyChartPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color(.secondarySystemBackground))
            .frame(height: chartHeight)
            .overlay {
                Text("No data to display")
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Oxygen saturation chart with no data")
    }

    private var chartContent: some View {
        Chart {
            // Alert zones (background highlighting)
            ForEach(Array(alertDates), id: \.self) { alertDate in
                RectangleMark(
                    xStart: .value("Start", alertDate),
                    xEnd: .value("End", Calendar.current.date(byAdding: .day, value: 1, to: alertDate) ?? alertDate),
                    yStart: nil,
                    yEnd: nil
                )
                .foregroundStyle(Color.red.opacity(0.1))
            }

            // Gradient area fill under the line
            ForEach(oxygenSaturationEntries) { entry in
                AreaMark(
                    x: .value("Date", entry.date, unit: .day),
                    y: .value("O2", entry.percentage)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.teal.opacity(0.2), Color.teal.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }

            // Oxygen saturation line
            ForEach(oxygenSaturationEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("O2", entry.percentage)
                )
                .foregroundStyle(Color.teal)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("O2", entry.percentage)
                )
                .foregroundStyle(entry.hasAlert ? Color.orange : Color.teal)
                .symbolSize(entry.hasAlert ? 60 : 40)
            }

            // Low threshold line (normal cutoff at 92%)
            RuleMark(y: .value("Normal Threshold", AlertConstants.oxygenSaturationNormalThreshold))
                .foregroundStyle(Color.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .leading, alignment: .leading) {
                    Text("\(AlertConstants.oxygenSaturationNormalThreshold)%")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

            // Alert threshold line
            RuleMark(y: .value("Alert Threshold", AlertConstants.oxygenSaturationLowThreshold))
                .foregroundStyle(Color.red.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .leading, alignment: .leading) {
                    Text("\(AlertConstants.oxygenSaturationLowThreshold)%")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let percentage = value.as(Int.self) {
                        Text("\(percentage)%")
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYScale(domain: yAxisDomain)
        .chartXScale(domain: dateRange)
        .frame(height: chartHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Oxygen saturation trend chart")
        .accessibilityHint("Shows your oxygen saturation measurements over the past 30 days")
    }

    /// Calculate appropriate Y-axis domain based on data
    /// Typically show 85-100% range for oxygen saturation
    private var yAxisDomain: ClosedRange<Int> {
        guard !oxygenSaturationEntries.isEmpty else {
            return 85...100
        }

        let values = oxygenSaturationEntries.map { $0.percentage }
        let minO2 = min(values.min() ?? 90, AlertConstants.oxygenSaturationLowThreshold - 5)
        let maxO2 = 100

        return max(minO2, 80)...maxO2
    }

    /// Date range for the chart
    private var dateRange: ClosedRange<Date> {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        return startDate...endDate
    }
}

#Preview {
    let sampleData: [OxygenSaturationDataPoint] = {
        let calendar = Calendar.current
        let today = Date()
        return (0..<14).compactMap { dayOffset -> OxygenSaturationDataPoint? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            let percentage = 95 + Int.random(in: -3...5)
            return OxygenSaturationDataPoint(
                date: calendar.startOfDay(for: date),
                percentage: min(percentage, 100),
                hasAlert: percentage < 90
            )
        }.reversed()
    }()

    OxygenSaturationTrendChart(
        oxygenSaturationEntries: Array(sampleData),
        alertDates: []
    )
    .padding()
}
