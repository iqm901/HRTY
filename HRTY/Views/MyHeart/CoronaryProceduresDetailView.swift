import SwiftUI
import SwiftData

/// View mode for displaying coronary procedures
enum CoronaryProcedureViewMode: String, CaseIterable {
    case byProcedure = "By Procedure"
    case byVessel = "By Vessel"
}

struct CoronaryProceduresDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: MyHeartViewModel
    @State private var viewMode: CoronaryProcedureViewMode = .byProcedure

    var body: some View {
        ZStack {
            Color.hrtBackgroundFallback
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: HRTSpacing.lg) {
                    infoSection

                    if viewModel.hasCoronaryProcedures {
                        viewModePicker

                        if viewMode == .byProcedure {
                            proceduresListSection
                        } else {
                            vesselCentricSection
                        }
                    } else {
                        emptyStateSection
                    }
                }
                .padding(.vertical, HRTSpacing.md)
            }
            .scrollContentBackground(.hidden)
        }
        .toolbarBackground(Color.hrtBackgroundFallback, for: .navigationBar)
        .navigationTitle("Coronary Procedures")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.prepareAddCoronaryProcedure()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add procedure")
            }
        }
        .sheet(isPresented: $viewModel.showingCoronaryProcedureEdit) {
            CoronaryProcedureEditView(viewModel: viewModel)
        }
    }

    // MARK: - Info Section

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("About Coronary Procedures")
                .font(.headline)

            Text("Track your coronary interventions including stents (PCI) and bypass surgery (CABG). This helps monitor your heart health and medication needs.")
                .font(.subheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
    }

    // MARK: - View Mode Picker

    private var viewModePicker: some View {
        Picker("View Mode", selection: $viewMode) {
            ForEach(CoronaryProcedureViewMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .hrtPagePadding()
    }

    // MARK: - Procedures List (By Procedure)

    private var proceduresListSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            ForEach(viewModel.coronaryProcedures, id: \.persistentModelID) { procedure in
                procedureRow(procedure)
            }
        }
        .hrtPagePadding()
    }

    private func procedureRow(_ procedure: CoronaryProcedure) -> some View {
        Button {
            viewModel.prepareEditCoronaryProcedure(procedure)
        } label: {
            HStack {
                // Icon based on procedure type
                Image(systemName: procedure.procedureType.icon)
                    .font(.title2)
                    .foregroundStyle(Color.hrtPinkFallback)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(procedure.procedureType.shortName)
                            .font(.headline)
                            .foregroundStyle(Color.hrtTextFallback)

                        if let dateDisplay = procedure.procedureDateDisplay {
                            Text("- \(dateDisplay)")
                                .font(.subheadline)
                                .foregroundStyle(Color.hrtTextSecondaryFallback)
                        }
                    }

                    if !procedure.vesselsInvolved.isEmpty {
                        Text("Vessels: \(procedure.vesselsInvolved.map(\.shortName).joined(separator: ", "))")
                            .font(.caption)
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }

                    if procedure.procedureType == .cabg && !procedure.graftTypes.isEmpty {
                        Text("Grafts: \(procedure.graftTypes.map(\.shortName).joined(separator: ", "))")
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
                viewModel.deleteCoronaryProcedure(procedure, context: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(procedure.procedureType.displayName)")
        .accessibilityValue(procedure.procedureDateDisplay ?? "Date unknown")
        .accessibilityHint("Tap to edit")
    }

    // MARK: - Vessel-Centric View

    private var vesselCentricSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            ForEach(vesselsWithProcedures, id: \.vessel) { vesselGroup in
                vesselGroupRow(vesselGroup)
            }

            if unknownVesselProcedures.count > 0 {
                unknownVesselsRow
            }
        }
        .hrtPagePadding()
    }

    private struct VesselGroup {
        let vessel: CoronaryArteryType
        let procedures: [CoronaryProcedure]
    }

    private var vesselsWithProcedures: [VesselGroup] {
        var groups: [CoronaryArteryType: [CoronaryProcedure]] = [:]

        for procedure in viewModel.coronaryProcedures {
            for vessel in procedure.vesselsInvolved {
                if groups[vessel] == nil {
                    groups[vessel] = []
                }
                groups[vessel]?.append(procedure)
            }
        }

        return CoronaryArteryType.allCases.compactMap { vessel in
            guard let procedures = groups[vessel], !procedures.isEmpty else { return nil }
            return VesselGroup(vessel: vessel, procedures: procedures)
        }
    }

    private var unknownVesselProcedures: [CoronaryProcedure] {
        viewModel.coronaryProcedures.filter { $0.vesselsInvolved.isEmpty }
    }

    private func vesselGroupRow(_ group: VesselGroup) -> some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text(group.vessel.displayName)
                .font(.headline)
                .foregroundStyle(Color.hrtTextFallback)

            ForEach(group.procedures, id: \.persistentModelID) { procedure in
                HStack(spacing: HRTSpacing.sm) {
                    Image(systemName: procedure.procedureType.icon)
                        .font(.caption)
                        .foregroundStyle(Color.hrtPinkFallback)
                        .frame(width: 20)

                    Text("\(procedure.procedureType.shortName) \(procedure.procedureDateDisplay.map { "(\($0))" } ?? "")")
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
                .padding(.leading, HRTSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
    }

    private var unknownVesselsRow: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Unknown Vessels")
                .font(.headline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            ForEach(unknownVesselProcedures, id: \.persistentModelID) { procedure in
                HStack(spacing: HRTSpacing.sm) {
                    Image(systemName: procedure.procedureType.icon)
                        .font(.caption)
                        .foregroundStyle(Color.hrtPinkFallback)
                        .frame(width: 20)

                    Text("\(procedure.procedureType.shortName) \(procedure.procedureDateDisplay.map { "(\($0))" } ?? "")")
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
                .padding(.leading, HRTSpacing.sm)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(HRTSpacing.md)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
    }

    // MARK: - Empty State

    private var emptyStateSection: some View {
        VStack(spacing: HRTSpacing.md) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 48))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("No Procedures Recorded")
                .font(.headline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("Tap the + button to add information about your coronary procedures such as stents or bypass surgery.")
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
        CoronaryProceduresDetailView(viewModel: MyHeartViewModel())
    }
    .modelContainer(for: [ClinicalProfile.self, CoronaryProcedure.self])
}
