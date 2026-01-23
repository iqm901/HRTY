import SwiftUI
import Charts

/// Chart view displaying heart rate trends over the past 30 days
struct HeartRateTrendChart: View {
    let heartRateEntries: [HeartRateDataPoint]
    let alertDates: Set<Date>

    var body: some View {
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

            // Heart rate line
            ForEach(heartRateEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Heart Rate", entry.heartRate)
                )
                .foregroundStyle(Color.red)
                .lineStyle(StrokeStyle(lineWidth: 2))

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Heart Rate", entry.heartRate)
                )
                .foregroundStyle(entry.hasAlert ? Color.orange : Color.red)
                .symbolSize(entry.hasAlert ? 60 : 40)
            }

            // Threshold lines
            RuleMark(y: .value("Low Threshold", AlertConstants.heartRateLowThreshold))
                .foregroundStyle(Color.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .leading, alignment: .leading) {
                    Text("\(AlertConstants.heartRateLowThreshold)")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

            RuleMark(y: .value("High Threshold", AlertConstants.heartRateHighThreshold))
                .foregroundStyle(Color.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .leading, alignment: .leading) {
                    Text("\(AlertConstants.heartRateHighThreshold)")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 7)) { value in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYScale(domain: yAxisDomain)
        .frame(height: 200)
    }

    /// Calculate appropriate Y-axis domain based on data and thresholds
    private var yAxisDomain: ClosedRange<Int> {
        guard !heartRateEntries.isEmpty else {
            return 30...130
        }

        let heartRates = heartRateEntries.map { $0.heartRate }
        let minHR = min(heartRates.min() ?? 40, AlertConstants.heartRateLowThreshold - 10)
        let maxHR = max(heartRates.max() ?? 120, AlertConstants.heartRateHighThreshold + 10)

        return minHR...maxHR
    }
}

#Preview {
    let sampleData: [HeartRateDataPoint] = {
        let calendar = Calendar.current
        let today = Date()
        return (0..<14).compactMap { dayOffset -> HeartRateDataPoint? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            let heartRate = 60 + Int.random(in: -10...15)
            return HeartRateDataPoint(
                date: calendar.startOfDay(for: date),
                heartRate: heartRate,
                hasAlert: heartRate < 40 || heartRate > 120
            )
        }.reversed()
    }()

    HeartRateTrendChart(
        heartRateEntries: Array(sampleData),
        alertDates: []
    )
    .padding()
}
