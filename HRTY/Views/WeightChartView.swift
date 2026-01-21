import SwiftUI
import Charts

struct WeightChartView: View {
    let weightEntries: [(date: Date, weight: Double)]

    private var minWeight: Double {
        let min = weightEntries.map(\.weight).min() ?? 0
        return max(0, min - 5) // 5 lb padding below
    }

    private var maxWeight: Double {
        let max = weightEntries.map(\.weight).max() ?? 200
        return max + 5 // 5 lb padding above
    }

    private var dateRange: ClosedRange<Date> {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        return startDate...endDate
    }

    var body: some View {
        Chart {
            ForEach(weightEntries, id: \.date) { entry in
                LineMark(
                    x: .value("Date", entry.date, unit: .day),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(Color.blue)
                .lineStyle(StrokeStyle(lineWidth: 2))

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
        .frame(height: 220)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Weight trend chart")
    }
}

#Preview {
    let sampleData: [(date: Date, weight: Double)] = {
        let calendar = Calendar.current
        var entries: [(Date, Double)] = []
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -29 + i, to: Date()) {
                // Skip some days to show gaps
                if i % 5 != 2 {
                    let weight = 180.0 + Double.random(in: -3...3)
                    entries.append((date, weight))
                }
            }
        }
        return entries
    }()

    return WeightChartView(weightEntries: sampleData)
        .padding()
}
