import SwiftUI
import SwiftData

struct HeartValvesDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: MyHeartViewModel

    var body: some View {
        ZStack {
            Color.hrtBackgroundFallback
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: HRTSpacing.lg) {
                    infoSection

                    if viewModel.hasHeartValves {
                        valvesListSection
                    } else {
                        emptyStateSection
                    }
                }
                .padding(.vertical, HRTSpacing.md)
            }
            .scrollContentBackground(.hidden)
        }
        .toolbarBackground(Color.hrtBackgroundFallback, for: .navigationBar)
        .navigationTitle("Heart Valves")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.prepareAddHeartValve()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add valve")
            }
        }
        .sheet(isPresented: $viewModel.showingHeartValveEdit) {
            HeartValveEditView(viewModel: viewModel)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("About Heart Valves")
                .font(.headline)

            Text("Your heart has four valves that keep blood flowing in the right direction. When valves don't work properly, it can strain your heart and contribute to heart failure.")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                valveTypeBullet("Stenosis", description: "Valve doesn't open fully")
                valveTypeBullet("Regurgitation", description: "Valve doesn't close completely")
            }
            .padding(.top, HRTSpacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    private func valveTypeBullet(_ title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: HRTSpacing.xs) {
            Text("•")
                .foregroundStyle(Color.hrtPinkFallback)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
        }
    }

    private var valvesListSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            ForEach(viewModel.heartValves, id: \.persistentModelID) { valve in
                valveRow(valve)
            }
        }
        .hrtPagePadding()
    }

    private func valveRow(_ valve: HeartValveCondition) -> some View {
        Button {
            viewModel.prepareEditHeartValve(valve)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(valve.valveType.displayName) Valve")
                        .font(.headline)
                        .foregroundStyle(Color.hrtTextFallback)

                    Text(valve.statusSummary)
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    if let interventionDate = valve.interventionDateDisplay {
                        Text("Intervention: \(interventionDate)")
                            .font(.caption)
                            .foregroundStyle(Color.hrtTextTertiaryFallback)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                    .font(.caption)
            }
            .padding(HRTSpacing.md)
            .background(Color.hrtCardFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
            .hrtCardShadow()
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                viewModel.deleteHeartValve(valve, context: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(valve.valveType.displayName) Valve")
        .accessibilityValue(valve.statusSummary)
        .accessibilityHint("Tap to edit")
    }

    private var emptyStateSection: some View {
        VStack(spacing: HRTSpacing.md) {
            Image(systemName: "arrow.up.arrow.down.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("No Valves Recorded")
                .font(.headline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("Tap the + button to add information about your heart valves from your echocardiogram results.")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HRTSpacing.xl)
        .hrtPagePadding()
    }
}

#Preview {
    NavigationStack {
        HeartValvesDetailView(viewModel: MyHeartViewModel())
    }
    .modelContainer(for: [ClinicalProfile.self, HeartValveCondition.self])
}
