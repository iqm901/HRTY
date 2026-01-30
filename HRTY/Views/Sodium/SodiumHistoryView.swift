import SwiftUI
import SwiftData
import Charts

struct SodiumHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SodiumViewModel

    @State private var weeklyData: [(date: Date, totalMg: Int)] = []

    private var startOfWeek: Date {
        Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: HRTSpacing.lg) {
                // Date Picker
                DatePicker(
                    "Select Date",
                    selection: $viewModel.selectedDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color.hrtPinkFallback)
                .padding(.horizontal, HRTSpacing.md)
                .background(Color.hrtCardFallback)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, HRTSpacing.md)

                // Weekly Trend Chart
                weeklyChartSection

                // Entries for Selected Date
                entriesSection
            }
            .padding(.vertical, HRTSpacing.lg)
        }
        .background(Color.hrtBackgroundFallback)
        .navigationTitle("Sodium History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.selectedDate) { _, newDate in
            viewModel.loadEntriesForDate(newDate, context: modelContext)
        }
        .task {
            loadWeeklyData()
            viewModel.loadEntriesForDate(viewModel.selectedDate, context: modelContext)
        }
    }

    // MARK: - Weekly Chart Section

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Last 7 Days")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)

            if weeklyData.isEmpty {
                emptyChartView
            } else {
                chartView
            }
        }
        .padding(.horizontal, HRTSpacing.md)
    }

    private var emptyChartView: some View {
        VStack(spacing: HRTSpacing.sm) {
            Image(systemName: "chart.bar")
                .font(.system(size: 32))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("No data for the past week")
                .font(.hrtSubheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var chartView: some View {
        Chart {
            // Daily limit reference line
            RuleMark(y: .value("Limit", SodiumConstants.dailyLimitMg))
                .foregroundStyle(Color.hrtAlertFallback.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))

            // Daily bars
            ForEach(weeklyData, id: \.date) { item in
                BarMark(
                    x: .value("Day", item.date, unit: .day),
                    y: .value("Sodium", item.totalMg)
                )
                .foregroundStyle(barColor(for: item.totalMg))
                .cornerRadius(4)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let mg = value.as(Int.self) {
                        Text("\(mg)")
                            .font(.hrtCaption)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .frame(height: 180)
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func barColor(for mg: Int) -> Color {
        let percent = SodiumConstants.progressPercent(current: mg)
        return SodiumConstants.progressColor(for: percent)
    }

    // MARK: - Entries Section

    private var entriesSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                Text(formattedSelectedDate)
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Spacer()

                Text(SodiumConstants.formatSodium(viewModel.todayTotalMg))
                    .font(.hrtSubheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.progressColor)
            }
            .padding(.horizontal, HRTSpacing.md)

            if viewModel.todayEntries.isEmpty {
                emptyEntriesView
            } else {
                entriesList
            }
        }
    }

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: viewModel.selectedDate)
    }

    private var emptyEntriesView: some View {
        VStack(spacing: HRTSpacing.sm) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("No entries for this date")
                .font(.hrtSubheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HRTSpacing.xl)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, HRTSpacing.md)
    }

    private var entriesList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.todayEntries, id: \.id) { entry in
                SodiumEntryRow(entry: entry)

                if entry.id != viewModel.todayEntries.last?.id {
                    Divider()
                        .padding(.leading, 56)
                }
            }
        }
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, HRTSpacing.md)
    }

    // MARK: - Data Loading

    private func loadWeeklyData() {
        weeklyData = SodiumEntry.dailyTotals(
            from: startOfWeek,
            to: Date(),
            in: modelContext
        )
    }
}

#Preview {
    NavigationStack {
        SodiumHistoryView(viewModel: SodiumViewModel())
    }
    .modelContainer(for: [SodiumEntry.self, SodiumTemplate.self], inMemory: true)
}
