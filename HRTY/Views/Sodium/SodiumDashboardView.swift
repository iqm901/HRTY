import SwiftUI
import SwiftData

struct SodiumDashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = SodiumViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: HRTSpacing.lg) {
                // Progress Section
                SodiumProgressView(
                    currentMg: viewModel.todayTotalMg,
                    limitMg: SodiumConstants.dailyLimitMg,
                    progressColor: viewModel.progressColor
                )
                .padding(.horizontal, HRTSpacing.md)

                // Quick Add Templates
                if !viewModel.frequentTemplates.isEmpty {
                    quickAddSection
                }

                // Today's Entries
                todayEntriesSection
            }
            .padding(.vertical, HRTSpacing.lg)
        }
        .background(Color.hrtBackgroundFallback)
        .navigationTitle("Sodium Tracker")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        viewModel.prepareForAdd()
                    } label: {
                        Label("Manual Entry", systemImage: "pencil")
                    }

                    Button {
                        viewModel.showingBarcodeScannerSheet = true
                    } label: {
                        Label("Scan Barcode", systemImage: "barcode.viewfinder")
                    }

                    Button {
                        viewModel.showingLabelScannerSheet = true
                    } label: {
                        Label("Scan Label", systemImage: "camera")
                    }
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }

            ToolbarItem(placement: .secondaryAction) {
                Button {
                    viewModel.showingHistoryView = true
                } label: {
                    Label("History", systemImage: "calendar")
                }
            }
        }
        .task {
            viewModel.loadData(context: modelContext)
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            AddSodiumSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingTemplateEditor) {
            TemplateEditorSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingHistoryView) {
            NavigationStack {
                SodiumHistoryView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showingBarcodeScannerSheet) {
            NavigationStack {
                BarcodeScannerView(viewModel: viewModel)
            }
        }
        .sheet(isPresented: $viewModel.showingLabelScannerSheet) {
            NavigationStack {
                LabelScannerView(viewModel: viewModel)
            }
        }
        .alert("Save as Template?", isPresented: $viewModel.showSaveAsTemplatePrompt) {
            Button("Save") {
                viewModel.saveAsTemplate(context: modelContext)
            }
            Button("Not Now", role: .cancel) {
                viewModel.dismissSaveAsTemplatePrompt()
            }
        } message: {
            if let entry = viewModel.lastAddedEntry {
                Text("Would you like to save \"\(entry.name)\" as a quick-add template?")
            }
        }
        .overlay(alignment: .bottom) {
            if let message = viewModel.entryAddedMessage {
                toastMessage(message)
            }
        }
    }

    // MARK: - Quick Add Section

    private var quickAddSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                Text("Quick Add")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)

                Spacer()

                Button {
                    viewModel.prepareForNewTemplate()
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .font(.hrtSubheadline)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
            }
            .padding(.horizontal, HRTSpacing.md)

            TemplateGridView(
                templates: viewModel.frequentTemplates,
                onTap: { template in
                    viewModel.addFromTemplate(template, context: modelContext)
                },
                onLongPress: { template in
                    viewModel.prepareForTemplateEdit(template)
                }
            )
            .padding(.horizontal, HRTSpacing.md)
        }
    }

    // MARK: - Today's Entries Section

    private var todayEntriesSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Text("Today's Entries")
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)
                .padding(.horizontal, HRTSpacing.md)

            if viewModel.todayEntries.isEmpty {
                emptyEntriesView
            } else {
                entriesList
            }
        }
    }

    private var emptyEntriesView: some View {
        VStack(spacing: HRTSpacing.sm) {
            Image(systemName: "fork.knife")
                .font(.system(size: 32))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("No entries yet today")
                .font(.hrtBody)
                .foregroundStyle(Color.hrtTextSecondaryFallback)

            Text("Tap + to log your sodium intake")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
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
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.deleteEntry(entry, context: modelContext)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        if entry.source != .template {
                            Button {
                                viewModel.lastAddedEntry = entry
                                viewModel.showSaveAsTemplatePrompt = true
                            } label: {
                                Label("Save as Template", systemImage: "star")
                            }
                        }
                    }

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

    // MARK: - Toast Message

    private func toastMessage(_ message: String) -> some View {
        Text(message)
            .font(.hrtSubheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding(.horizontal, HRTSpacing.md)
            .padding(.vertical, HRTSpacing.sm)
            .background(Color.hrtTextFallback.opacity(0.9))
            .clipShape(Capsule())
            .padding(.bottom, HRTSpacing.lg)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        viewModel.clearEntryAddedMessage()
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        SodiumDashboardView()
    }
    .modelContainer(for: [SodiumEntry.self, SodiumTemplate.self], inMemory: true)
}
