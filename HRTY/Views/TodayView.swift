import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TodayViewModel()
    @FocusState private var isWeightFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    weightEntrySection
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("Today")
            .onAppear {
                viewModel.loadData(context: modelContext)
                isWeightFieldFocused = true
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("How are you feeling today?")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Your daily check-in takes just a couple of minutes.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Weight Entry Section
    private var weightEntrySection: some View {
        VStack(spacing: 16) {
            sectionHeader

            weightInputField

            if let error = viewModel.validationError {
                validationErrorView(error)
            }

            saveButton

            if viewModel.showSaveSuccess {
                successFeedback
            }

            previousWeightView
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    private var sectionHeader: some View {
        HStack {
            Image(systemName: "scalemass.fill")
                .foregroundStyle(.blue)
            Text("Weight")
                .font(.headline)
            Spacer()
        }
    }

    private var weightInputField: some View {
        HStack(spacing: 8) {
            TextField("Enter weight", text: $viewModel.weightInput)
                .keyboardType(.decimalPad)
                .font(.system(size: 28, weight: .medium))
                .multilineTextAlignment(.center)
                .padding()
                .frame(height: 60)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .focused($isWeightFieldFocused)
                .accessibilityLabel("Weight input")
                .accessibilityHint("Enter your weight in pounds")

            Text("lbs")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }

    private func validationErrorView(_ error: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(.red)
            Text(error)
                .font(.footnote)
                .foregroundStyle(.red)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(error)")
    }

    private var saveButton: some View {
        Button {
            viewModel.saveWeight(context: modelContext)
            isWeightFieldFocused = false
        } label: {
            Text("Save Weight")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.weightInput.isEmpty ? Color.gray : Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(viewModel.weightInput.isEmpty)
        .accessibilityLabel("Save weight button")
        .accessibilityHint("Tap to save your weight entry")
    }

    private var successFeedback: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Weight saved!")
                .font(.subheadline)
                .foregroundStyle(.green)
        }
        .transition(.opacity.combined(with: .scale))
        .accessibilityLabel("Weight saved successfully")
    }

    private var previousWeightView: some View {
        VStack(spacing: 8) {
            if viewModel.hasNoPreviousData {
                Text("This is your first weight entry!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("This is your first weight entry")
            } else if let previousWeight = viewModel.previousWeight {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Yesterday (\(viewModel.yesterdayDateText))")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                        Text("\(previousWeight, specifier: "%.1f") lbs")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Yesterday's weight: \(String(format: "%.1f", previousWeight)) pounds")

                if let changeText = viewModel.weightChangeText {
                    weightChangeView(text: changeText)
                }
            }
        }
        .padding(.top, 8)
    }

    private func weightChangeView(text: String) -> some View {
        HStack {
            Image(systemName: weightChangeIcon)
                .foregroundStyle(weightChangeSwiftUIColor)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(weightChangeSwiftUIColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(weightChangeBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
        .accessibilityHint("Weight change from yesterday")
    }

    // MARK: - Weight Change Styling
    private var weightChangeIcon: String {
        switch viewModel.weightChangeColor {
        case .warning:
            return "arrow.up.circle.fill"
        case .neutral:
            return "arrow.down.circle.fill"
        case .success:
            return "equal.circle.fill"
        }
    }

    private var weightChangeSwiftUIColor: Color {
        switch viewModel.weightChangeColor {
        case .warning:
            return .orange
        case .neutral:
            return .secondary
        case .success:
            return .green
        }
    }

    private var weightChangeBackgroundColor: Color {
        switch viewModel.weightChangeColor {
        case .warning:
            return .orange.opacity(0.1)
        case .neutral:
            return Color(.secondarySystemBackground)
        case .success:
            return .green.opacity(0.1)
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: DailyEntry.self, inMemory: true)
}
