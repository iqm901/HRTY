import SwiftUI
import Charts

/// A compact sparkline chart that auto-scales to the data range
struct SparklineChart: View {
    let values: [Double]
    let color: Color

    var body: some View {
        if values.isEmpty {
            Rectangle()
                .fill(Color.clear)
        } else {
            Chart(values.indices, id: \.self) { index in
                LineMark(
                    x: .value("Day", index),
                    y: .value("Value", values[index])
                )
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 1.5))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: yAxisDomain)
        }
    }

    /// Auto-scale Y-axis to the actual data range with a small buffer
    private var yAxisDomain: ClosedRange<Double> {
        let minVal = values.min() ?? 0
        let maxVal = values.max() ?? 1
        let range = max(maxVal - minVal, 0.001) // Avoid division by zero
        let buffer = range * 0.1
        return (minVal - buffer)...(maxVal + buffer)
    }
}

/// A sparkline row for a single vital sign in the Overview mode
struct VitalSparklineView: View {
    let title: String
    let value: String?
    let unit: String
    let color: Color
    let dataPoints: [Double]
    let onTap: (() -> Void)?
    let valueStatus: VitalSignStatus

    init(
        title: String,
        value: String?,
        unit: String,
        color: Color,
        dataPoints: [Double],
        valueStatus: VitalSignStatus = .normal,
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.unit = unit
        self.color = color
        self.dataPoints = dataPoints
        self.valueStatus = valueStatus
        self.onTap = onTap
    }

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: HRTSpacing.md) {
                // Left side: Title and current value
                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text(title)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(value ?? "--")
                            .font(.hrtTitle3)
                            .fontWeight(valueStatus.fontWeight)
                            .foregroundStyle(valueStatus.color)

                        if !unit.isEmpty {
                            Text(unit)
                                .font(.hrtCaption)
                                .foregroundStyle(Color.hrtTextSecondaryFallback)
                        }
                    }
                }
                .frame(minWidth: 80, alignment: .leading)

                Spacer()

                // Right side: Mini sparkline chart
                if dataPoints.isEmpty {
                    Text("No data")
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                        .frame(width: 100, height: 40)
                } else {
                    SparklineChart(values: dataPoints, color: color)
                        .frame(width: 100, height: 40)
                }

                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
            .padding(HRTSpacing.md)
            .background(Color.hrtCardFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value ?? "no data") \(unit)")
        .accessibilityHint("Double tap to view full \(title) chart")
    }
}

/// Blood pressure sparkline with two lines (systolic and diastolic)
struct BloodPressureSparklineChart: View {
    let systolicValues: [Double]
    let diastolicValues: [Double]
    let systolicColor: Color
    let diastolicColor: Color

    var body: some View {
        if systolicValues.isEmpty || diastolicValues.isEmpty {
            Rectangle()
                .fill(Color.clear)
        } else {
            Chart {
                ForEach(systolicValues.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Day", index),
                        y: .value("Systolic", systolicValues[index])
                    )
                    .foregroundStyle(systolicColor)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .interpolationMethod(.catmullRom)
                }

                ForEach(diastolicValues.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Day", index),
                        y: .value("Diastolic", diastolicValues[index])
                    )
                    .foregroundStyle(diastolicColor)
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: yAxisDomain)
        }
    }

    private var yAxisDomain: ClosedRange<Double> {
        let allValues = systolicValues + diastolicValues
        let minVal = allValues.min() ?? 60
        let maxVal = allValues.max() ?? 140
        let range = max(maxVal - minVal, 1)
        let buffer = range * 0.1
        return (minVal - buffer)...(maxVal + buffer)
    }
}

/// Blood pressure sparkline row with two-line chart
struct BloodPressureSparklineView: View {
    let title: String
    let value: String?
    let unit: String
    let systolicValues: [Double]
    let diastolicValues: [Double]
    let onTap: (() -> Void)?

    init(
        title: String,
        value: String?,
        unit: String,
        systolicValues: [Double],
        diastolicValues: [Double],
        onTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.value = value
        self.unit = unit
        self.systolicValues = systolicValues
        self.diastolicValues = diastolicValues
        self.onTap = onTap
    }

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: HRTSpacing.md) {
                // Left side: Title and current value
                VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                    Text(title)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(value ?? "--/--")
                            .font(.hrtTitle3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.hrtTextFallback)

                        Text(unit)
                            .font(.hrtCaption)
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }
                }
                .frame(minWidth: 80, alignment: .leading)

                Spacer()

                // Right side: Mini sparkline chart with two lines
                if systolicValues.isEmpty {
                    Text("No data")
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                        .frame(width: 100, height: 40)
                } else {
                    BloodPressureSparklineChart(
                        systolicValues: systolicValues,
                        diastolicValues: diastolicValues,
                        systolicColor: .purple,
                        diastolicColor: .purple.opacity(0.5)
                    )
                    .frame(width: 100, height: 40)
                }

                // Chevron indicator
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
            .padding(HRTSpacing.md)
            .background(Color.hrtCardFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value ?? "no data") \(unit)")
        .accessibilityHint("Double tap to view full \(title) chart")
    }
}

#Preview {
    VStack(spacing: 12) {
        VitalSparklineView(
            title: "Weight",
            value: "165.2",
            unit: "lbs",
            color: .blue,
            dataPoints: [164.5, 165.0, 165.2, 164.8, 165.5, 165.2],
            onTap: {}
        )

        VitalSparklineView(
            title: "Heart Rate",
            value: "72",
            unit: "bpm",
            color: .red,
            dataPoints: [68, 72, 70, 75, 71, 72],
            onTap: {}
        )

        BloodPressureSparklineView(
            title: "Blood Pressure",
            value: "120/80",
            unit: "mmHg",
            systolicValues: [118, 122, 120, 125, 119, 120],
            diastolicValues: [78, 82, 80, 84, 79, 80],
            onTap: {}
        )

        VitalSparklineView(
            title: "Oxygen",
            value: "98",
            unit: "%",
            color: .teal,
            dataPoints: [97, 98, 98, 97, 99, 98],
            onTap: {}
        )

        VitalSparklineView(
            title: "No Data Test",
            value: nil,
            unit: "lbs",
            color: .blue,
            dataPoints: [],
            onTap: {}
        )
    }
    .padding()
    .background(Color.hrtBackgroundFallback)
}
