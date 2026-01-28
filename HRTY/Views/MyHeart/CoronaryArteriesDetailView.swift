import SwiftUI
import SwiftData

struct CoronaryArteriesDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: MyHeartViewModel

    var body: some View {
        ZStack {
            Color.hrtBackgroundFallback
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: HRTSpacing.lg) {
                    infoSection

                    if viewModel.hasCoronaryArteries {
                        arteriesListSection
                    } else {
                        emptyStateSection
                    }
                }
                .padding(.vertical, HRTSpacing.md)
            }
            .scrollContentBackground(.hidden)
        }
        .toolbarBackground(Color.hrtBackgroundFallback, for: .navigationBar)
        .navigationTitle("Coronary Arteries")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.prepareAddCoronaryArtery()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add artery")
            }
        }
        .sheet(isPresented: $viewModel.showingCoronaryArteryEdit) {
            CoronaryArteryEditView(viewModel: viewModel)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("About Coronary Arteries")
                .font(.headline)

            Text("Coronary arteries supply blood to your heart muscle. Blockages in these arteries can cause heart attacks and contribute to heart failure. Your doctor may have checked your arteries with a coronary angiogram or CT scan.")
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

    private var arteriesListSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            ForEach(viewModel.coronaryArteries, id: \.persistentModelID) { artery in
                arteryRow(artery)
            }
        }
        .hrtPagePadding()
    }

    private func arteryRow(_ artery: CoronaryArtery) -> some View {
        Button {
            viewModel.prepareEditCoronaryArtery(artery)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(artery.arteryType.displayName)
                        .font(.headline)
                        .foregroundStyle(Color.hrtTextFallback)

                    Text(artery.statusSummary)
                        .font(.subheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)

                    if let stentDate = artery.stentDateDisplay {
                        Text("Stent: \(stentDate)")
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
                viewModel.deleteCoronaryArtery(artery, context: modelContext)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(artery.arteryType.displayName)
        .accessibilityValue(artery.statusSummary)
        .accessibilityHint("Tap to edit")
    }

    private var emptyStateSection: some View {
        VStack(spacing: HRTSpacing.md) {
            Image(systemName: "arrow.triangle.branch")
                .font(.system(size: 48))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("No Arteries Recorded")
                .font(.headline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("Tap the + button to add information about your coronary arteries from your doctor's findings.")
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
        CoronaryArteriesDetailView(viewModel: MyHeartViewModel())
    }
    .modelContainer(for: [ClinicalProfile.self, CoronaryArtery.self])
}
