import SwiftUI
import Charts

/// Chart view displaying blood pressure trends over the past 30 days
/// Shows two lines: systolic (top) and diastolic (bottom)
struct BloodPressureTrendChart: View {
    let bloodPressureEntries: [BloodPressureDataPoint]
    let alertDates: Set<Date>

    /// Chart height that scales with Dynamic Type settings
    @ScaledMetric(relativeTo: .body) private var chartHeight: CGFloat = 220

    var body: some View {
        if bloodPressureEntries.isEmpty {
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
            .accessibilityLabel("Blood pressure chart with no data")
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

            // Systolic line (upper)
            ForEach(bloodPressureEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Systolic", entry.systolic)
                )
                .foregroundStyle(Color.purple)
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Systolic", entry.systolic)
                )
                .foregroundStyle(entry.hasAlert ? Color.orange : Color.purple)
                .symbolSize(entry.hasAlert ? 60 : 40)
            }

            // Diastolic line (lower)
            ForEach(bloodPressureEntries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Diastolic", entry.diastolic)
                )
                .foregroundStyle(Color.purple.opacity(0.6))
                .lineStyle(StrokeStyle(lineWidth: 2))
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Diastolic", entry.diastolic)
                )
                .foregroundStyle(entry.hasAlert ? Color.orange.opacity(0.6) : Color.purple.opacity(0.6))
                .symbolSize(entry.hasAlert ? 50 : 30)
            }

            // Normal range threshold lines
            RuleMark(y: .value("Low Systolic Threshold", AlertConstants.systolicBPNormalLow))
                .foregroundStyle(Color.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .leading, alignment: .leading) {
                    Text("\(AlertConstants.systolicBPNormalLow)")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

            RuleMark(y: .value("High Systolic Threshold", AlertConstants.systolicBPCriticalHigh))
                .foregroundStyle(Color.orange.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .annotation(position: .leading, alignment: .leading) {
                    Text("\(AlertConstants.systolicBPCriticalHigh)")
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
        .chartXScale(domain: dateRange)
        .frame(height: chartHeight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Blood pressure trend chart")
        .accessibilityHint("Shows your blood pressure measurements over the past 30 days")
    }

    /// Calculate appropriate Y-axis domain based on data and thresholds
    private var yAxisDomain: ClosedRange<Int> {
        guard !bloodPressureEntries.isEmpty else {
            return 50...180
        }

        let systolicValues = bloodPressureEntries.map { $0.systolic }
        let diastolicValues = bloodPressureEntries.map { $0.diastolic }

        let minDiastolic = diastolicValues.min() ?? 60
        let maxSystolic = systolicValues.max() ?? 140

        let minValue = min(minDiastolic - 10, AlertConstants.diastolicBPCriticalLow - 5)
        let maxValue = max(maxSystolic + 10, AlertConstants.systolicBPCriticalHigh + 5)

        return minValue...maxValue
    }

    /// Date range for the chart
    private var dateRange: ClosedRange<Date> {
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -29, to: endDate) ?? endDate
        return startDate...endDate
    }
}

#Preview {
    let sampleData: [BloodPressureDataPoint] = {
        let calendar = Calendar.current
        let today = Date()
        return (0..<14).compactMap { dayOffset -> BloodPressureDataPoint? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            let systolic = 115 + Int.random(in: -10...20)
            let diastolic = 75 + Int.random(in: -5...10)
            return BloodPressureDataPoint(
                date: calendar.startOfDay(for: date),
                systolic: systolic,
                diastolic: diastolic,
                hasAlert: systolic < 90 || systolic >= 160
            )
        }.reversed()
    }()

    BloodPressureTrendChart(
        bloodPressureEntries: Array(sampleData),
        alertDates: []
    )
    .padding()
}
