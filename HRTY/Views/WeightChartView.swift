import SwiftUI
import Charts

struct WeightChartView: View {
    let weightEntries: [WeightDataPoint]

    /// Chart height that scales with Dynamic Type settings
    @ScaledMetric(relativeTo: .body) private var chartHeight: CGFloat = 220

    private var minWeight: Double {
        guard let min = weightEntries.map(\.weight).min() else { return 0 }
        return max(0, min - 5) // 5 lb padding below
    }

    private var maxWeight: Double {
        guard let max = weightEntries.map(\.weight).max() else { return 200 }
        return max + 5 // 5 lb padding above
    }

    private var dateRange: ClosedRange<Date> {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        return startDate...endDate
    }

    var body: some View {
        if weightEntries.isEmpty {
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
            .accessibilityLabel("Weight chart with no data")
    }

    private var chartContent: some View {
        Chart {
            ForEach(weightEntries) { entry in
                // Gradient area fill under the line
                AreaMark(
                    x: .value("Date", entry.date, unit: .day),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", entry.date, unit: .day),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date, unit: .day),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(Color.blue)
                .symbolSize(40)
            }
        }
        .chartXScale(domain: dateRange)
        .chartYScale(domain: minWeight...maxWeight)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let weight = value.as(Double.self) {
                        Text("\(Int(weight))")
                    }
                }
            }
        }
        .frame(height: chartHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weight trend chart")
        .accessibilityHint("Shows your weight measurements over the past 30 days")
    }
}

extension WeightChartView {
    var hasData: Bool {
        !weightEntries.isEmpty
    }
}

#Preview {
    let sampleData: [WeightDataPoint] = {
        let calendar = Calendar.current
        var entries: [WeightDataPoint] = []
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -29 + i, to: Date()) {
                // Skip some days to show gaps
                if i % 5 != 2 {
                    let weight = 180.0 + Double.random(in: -3...3)
                    entries.append(WeightDataPoint(date: date, weight: weight))
                }
            }
        }
        return entries
    }()

    return WeightChartView(weightEntries: sampleData)
        .padding()
}
