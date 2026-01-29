import SwiftUI
import SwiftData

struct ProfileSheetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = MyHeartViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        introCard
                        ejectionFractionCard
                        nyhaClassCard
                        optionalHeader
                        bpTargetCard
                    }
                    .padding(.vertical, HRTSpacing.lg)
                }
            }
            .navigationTitle("My Health Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear {
                viewModel.loadProfile(context: modelContext)
            }
            .sheet(isPresented: $viewModel.showingEjectionFractionEdit) {
                EjectionFractionEditView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingNYHAClassEdit) {
                NYHAClassEditView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingBPTargetEdit) {
                BPTargetEditView(viewModel: viewModel)
            }
        }
    }

    // MARK: - Intro Card

    private var introCard: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.hrtPinkFallback)
                    .font(.title2)
                Text("A few details go a long way")
                    .font(.headline)
                Spacer()
            }

            Text("These values come from your doctor visits. Having them here helps you track changes over time and share updates with your care team.")
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

    // MARK: - Ejection Fraction Card

    private var ejectionFractionCard: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                requiredBadge
                Spacer()
            }

            HStack {
                Image(systemName: "percent")
                    .foregroundStyle(Color.hrtPinkFallback)
                    .font(.title2)
                Text("Ejection Fraction")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                    .font(.caption)
            }

            if let display = viewModel.ejectionFractionDisplay {
                Text(display)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hrtTextFallback)

                if let dateDisplay = viewModel.ejectionFractionDateDisplay {
                    Text(dateDisplay)
                        .font(.caption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
            } else {
                Text("Not recorded")
                    .font(.subheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                Text("Your ejection fraction shows how well your heart pumps blood.")
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.prepareEjectionFractionEdit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Ejection Fraction, required")
        .accessibilityValue(viewModel.ejectionFractionDisplay ?? "Not recorded")
        .accessibilityHint("Tap to edit")
    }

    // MARK: - NYHA Class Card

    private var nyhaClassCard: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                requiredBadge
                Spacer()
            }

            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.hrtPinkFallback)
                    .font(.title2)
                Text("NYHA Class")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                    .font(.caption)
            }

            if let display = viewModel.nyhaClassDisplay {
                Text(display)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hrtTextFallback)

                if let dateDisplay = viewModel.nyhaClassDateDisplay {
                    Text(dateDisplay)
                        .font(.caption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
            } else {
                Text("Not recorded")
                    .font(.subheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                Text("NYHA class describes how heart failure affects your daily activities.")
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.prepareNYHAClassEdit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("NYHA Class, required")
        .accessibilityValue(viewModel.nyhaClassDisplay ?? "Not recorded")
        .accessibilityHint("Tap to edit")
    }

    // MARK: - Optional Header

    private var optionalHeader: some View {
        HStack {
            Text("Optional")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
            Spacer()
        }
        .hrtPagePadding()
    }

    // MARK: - BP Target Card

    private var bpTargetCard: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                Image(systemName: "gauge.with.dots.needle.33percent")
                    .foregroundStyle(Color.hrtPinkFallback)
                    .font(.title2)
                Text("Blood Pressure Target")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                    .font(.caption)
            }

            if let display = viewModel.profile?.bpTargetDisplay {
                Text(display)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hrtTextFallback)
            } else {
                Text("Not set")
                    .font(.subheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                Text("Your doctor can tell you what blood pressure target is right for you.")
                    .font(.caption)
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
        .contentShape(Rectangle())
        .onTapGesture {
            viewModel.prepareBPTargetEdit()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Blood Pressure Target")
        .accessibilityValue(viewModel.profile?.bpTargetDisplay ?? "Not set")
        .accessibilityHint("Tap to edit")
    }

    // MARK: - Required Badge

    private var requiredBadge: some View {
        Text("Required")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(Color.hrtPinkFallback)
            .padding(.horizontal, HRTSpacing.xs)
            .padding(.vertical, 2)
            .background(Color.hrtPinkLightFallback)
            .clipShape(Capsule())
    }
}

#Preview {
    ProfileSheetView()
        .modelContainer(for: [ClinicalProfile.self])
}
