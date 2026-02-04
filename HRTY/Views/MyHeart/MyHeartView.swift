import SwiftUI
import SwiftData

struct MyHeartView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MyHeartViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero image extending to top
                    Image("MyHeartHero")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 280)
                        .containerRelativeFrame(.horizontal)
                        .clipped()
                        .overlay(alignment: .top) {
                            LinearGradient(
                                stops: [
                                    .init(color: Color.white.opacity(0.12), location: 0),
                                    .init(color: Color.white.opacity(0), location: 0.7)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        }
                        .overlay(alignment: .topLeading) {
                            Text("My Heart")
                                .font(.custom("Nunito-SemiBold", size: 34))
                                .foregroundStyle(Color.hrtHeroTitle)
                                .shadow(color: Color.hrtHeroTitleShadow, radius: 8, x: 0, y: 2)
                                .padding(.top, 60)
                                .padding(.leading, HRTSpacing.md)
                        }

                    // Main content with rounded top corners, pulled up to overlap image
                    mainContent
                        .background(
                            Color.hrtBackgroundFallback
                                .clipShape(RoundedCorner(radius: 24, corners: [.topLeft, .topRight]))
                        )
                        .offset(y: -40)
                }
            }
            .ignoresSafeArea(edges: .top)
            .background(Color.hrtBackgroundFallback)
            .toolbarBackground(Color.hrtBackgroundFallback.opacity(0), for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadProfile(context: modelContext)
                viewModel.loadMedications(context: modelContext)
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
            .navigationDestination(isPresented: $viewModel.showingHeartValvesDetail) {
                HeartValvesDetailView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: $viewModel.showingCoronaryProceduresDetail) {
                CoronaryProceduresDetailView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingCoronaryProcedureEdit) {
                CoronaryProcedureEditView(viewModel: viewModel)
            }
        }
    }

    // MARK: - State for Add Medication Navigation

    @State private var showingAddMedication = false

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: HRTSpacing.lg) {
            ejectionFractionCard

            nyhaClassCard

            bpTargetCard

            coronaryArteriesCard

            heartValvesCard
        }
        .padding(.vertical, HRTSpacing.lg)
    }

    // MARK: - Ejection Fraction Card

    private var ejectionFractionCard: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                Image(systemName: "percent")
                    .foregroundStyle(Color.hrtPinkFallback)
                    .font(.title2)
                Text("Ejection Fraction")
                    .font(.headline)
                Spacer()
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
        .accessibilityLabel("Ejection Fraction")
        .accessibilityValue(viewModel.ejectionFractionDisplay ?? "Not recorded")
        .accessibilityHint("Tap to edit")
    }

    // MARK: - NYHA Class Card

    private var nyhaClassCard: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.hrtPinkFallback)
                    .font(.title2)
                Text("NYHA Class")
                    .font(.headline)
                Spacer()
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
        .accessibilityLabel("NYHA Class")
        .accessibilityValue(viewModel.nyhaClassDisplay ?? "Not recorded")
        .accessibilityHint("Tap to edit")
    }

    // MARK: - Coronary Arteries Card

    private var coronaryArteriesCard: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            // Card header
            VStack(alignment: .leading, spacing: HRTSpacing.sm) {
                HStack {
                    Image(systemName: "heart.text.square")
                        .foregroundStyle(Color.hrtPinkFallback)
                        .font(.title2)
                    Text("Coronary Arteries")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                        .font(.caption)
                }

                Text(viewModel.coronaryProceduresSummary)
                    .font(.subheadline)
                    .foregroundStyle(viewModel.hasCoronaryProcedures ? Color.hrtTextFallback : Color.hrtTextSecondaryFallback)

                if !viewModel.hasCoronaryProcedures {
                    Text("Track your stents and bypass surgery to help monitor medication needs.")
                        .font(.caption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.prepareCoronaryProceduresDetail()
            }

            // Antiplatelet warning banner (if applicable)
            if viewModel.shouldShowAntiplateletWarning {
                AntiplateletWarningBanner(
                    recommendation: viewModel.antiplateletRecommendation,
                    onAddMedication: {
                        showingAddMedication = true
                    }
                )
                .padding(.top, HRTSpacing.xs)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .hrtCardPadding()
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        .hrtCardShadow()
        .hrtPagePadding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Coronary Arteries")
        .accessibilityValue(viewModel.coronaryProceduresSummary)
        .accessibilityHint("Tap to view details")
        .sheet(isPresented: $showingAddMedication) {
            MedicationFormView(
                viewModel: MedicationsViewModel(),
                isEditing: false
            )
            .onDisappear {
                // Refresh medications to update the recommendation
                viewModel.loadMedications(context: modelContext)
            }
        }
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

    // MARK: - Heart Valves Card

    private var heartValvesCard: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .foregroundStyle(Color.hrtPinkFallback)
                    .font(.title2)
                Text("Heart Valves")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.hrtTextTertiaryFallback)
                    .font(.caption)
            }

            Text(viewModel.heartValvesSummary)
                .font(.subheadline)
                .foregroundStyle(viewModel.hasHeartValves ? Color.hrtTextFallback : Color.hrtTextSecondaryFallback)

            if !viewModel.hasHeartValves {
                Text("Track the status of your heart valves from your echocardiogram results.")
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
            viewModel.prepareHeartValvesDetail()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Heart Valves")
        .accessibilityValue(viewModel.heartValvesSummary)
        .accessibilityHint("Tap to view details")
    }
}

#Preview {
    MyHeartView()
        .modelContainer(for: [ClinicalProfile.self, HeartValveCondition.self, CoronaryProcedure.self])
}
