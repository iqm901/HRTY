import SwiftUI
import SwiftData

struct MedicationsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MedicationsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        photosSection

                        medicationsSection
                    }
                    .padding(.vertical, HRTSpacing.md)
                }
                .scrollContentBackground(.hidden)
            }
            .toolbarBackground(Color.hrtBackgroundFallback, for: .navigationBar)
            .navigationTitle("Medications")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            viewModel.prepareForPhotoCapture()
                        } label: {
                            Label("Add Photo", systemImage: "camera")
                        }
                        Button {
                            viewModel.prepareForAdd()
                        } label: {
                            Label("Add Medication", systemImage: "pills")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add")
                    .accessibilityHint("Opens menu to add a photo or medication")
                }
            }
            .sheet(isPresented: $viewModel.showingAddMedication) {
                MedicationFormView(viewModel: viewModel, isEditing: false)
            }
            .sheet(isPresented: $viewModel.showingEditMedication) {
                MedicationFormView(viewModel: viewModel, isEditing: true)
            }
            .sheet(isPresented: $viewModel.showingPhotoCaptureView) {
                MedicationPhotoCaptureView(capturedImage: $viewModel.capturedImage)
            }
            .fullScreenCover(isPresented: $viewModel.showingPhotoViewer) {
                if let photo = viewModel.selectedPhoto {
                    MedicationPhotoViewerView(
                        photo: photo,
                        onDelete: { viewModel.deletePhoto(photo) }
                    )
                }
            }
            .onChange(of: viewModel.capturedImage) { _, newImage in
                if newImage != nil {
                    Task {
                        await viewModel.savePhoto()
                    }
                }
            }
            .alert("Remove Medication", isPresented: $viewModel.showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    viewModel.medicationToDelete = nil
                }
                Button("Remove", role: .destructive) {
                    viewModel.deleteMedication(context: modelContext)
                }
            } message: {
                if let medication = viewModel.medicationToDelete {
                    Text("Are you sure you want to remove \(medication.name) from your medications list? You can always add it back later.")
                }
            }
            .alert("Unable to Remove", isPresented: .init(
                get: { viewModel.deleteError != nil },
                set: { if !$0 { viewModel.clearDeleteError() } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.clearDeleteError()
                }
            } message: {
                if let error = viewModel.deleteError {
                    Text(error)
                }
            }
            .alert("Photo Error", isPresented: .init(
                get: { viewModel.photoError != nil },
                set: { if !$0 { viewModel.clearPhotoError() } }
            )) {
                Button("OK", role: .cancel) {
                    viewModel.clearPhotoError()
                }
            } message: {
                if let error = viewModel.photoError {
                    Text(error)
                }
            }
            .alert("Before You Add", isPresented: $viewModel.showingConflictWarning) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelConflictAdd()
                }
                Button("Add Anyway") {
                    viewModel.confirmAddDespiteConflict(context: modelContext)
                }
            } message: {
                Text(viewModel.conflictWarningMessage)
            }
            .alert("Archive Medication?", isPresented: $viewModel.showingArchivePrompt) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelArchiveOrDelete()
                }
                Button("Archive") {
                    viewModel.archiveMedication(context: modelContext)
                }
            } message: {
                if let medication = viewModel.medicationToArchive {
                    Text("Move \(medication.name) to Prior Medications? You can reactivate it later if needed.")
                }
            }
            .alert("Keep Medication History?", isPresented: $viewModel.showingArchiveInsteadPrompt) {
                Button("Cancel", role: .cancel) {
                    viewModel.cancelArchiveOrDelete()
                }
                Button("Archive Instead") {
                    viewModel.archiveInsteadOfDelete(context: modelContext)
                }
                Button("Delete Permanently", role: .destructive) {
                    viewModel.permanentlyDeleteMedication(context: modelContext)
                }
            } message: {
                if let medication = viewModel.medicationToDelete {
                    Text("This medication has been tracked for more than a day. Would you like to archive \(medication.name) instead? Archiving preserves your history and lets you reactivate it later.")
                }
            }
            .sheet(isPresented: $viewModel.showingPriorMedicationDetail) {
                if let medication = viewModel.selectedPriorMedication {
                    PriorMedicationDetailView(viewModel: viewModel, medication: medication)
                }
            }
            .onAppear {
                viewModel.loadMedications(context: modelContext)
                viewModel.loadPhotos()
            }
            .overlay(alignment: .bottom) {
                if let message = viewModel.photoSavedMessage {
                    PhotoSavedToast(message: message)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                withAnimation {
                                    viewModel.clearPhotoSavedMessage()
                                }
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.photoSavedMessage)
        }
    }

    // MARK: - Subviews

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                HStack(spacing: HRTSpacing.sm) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundStyle(Color.hrtPinkFallback)
                    Text("Reference Photos")
                        .font(.hrtHeadline)
                        .foregroundStyle(Color.hrtTextFallback)
                }

                Spacer()

                Button {
                    viewModel.prepareForPhotoCapture()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .accessibilityLabel("Add reference photo")
            }
            .padding(.horizontal, HRTSpacing.md)

            Text("Photos of your medication bottles or lists for easy reference")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .padding(.horizontal, HRTSpacing.md)

            MedicationPhotoGalleryView(
                photos: viewModel.photos,
                onPhotoTapped: { photo in
                    viewModel.viewPhoto(photo)
                },
                onDeletePhoto: { photo in
                    viewModel.deletePhoto(photo)
                }
            )
        }
    }

    private var medicationsSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack {
                HStack(spacing: HRTSpacing.sm) {
                    Image(systemName: "pills")
                        .foregroundStyle(Color.hrtPinkFallback)
                    Text("Active Medications")
                        .font(.hrtHeadline)
                        .foregroundStyle(Color.hrtTextFallback)
                }

                Spacer()

                Button {
                    viewModel.prepareForAdd()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .accessibilityLabel("Add medication")
            }
            .padding(.horizontal, HRTSpacing.md)

            if viewModel.hasNoMedications {
                medicationsEmptyState
            } else {
                medicationsList
            }

            // Prior Medications Section
            if viewModel.hasPriorMedications {
                priorMedicationsSection
            }
        }
    }

    private var medicationsEmptyState: some View {
        HRTEmptyState(
            icon: "pills",
            title: "No Medications Yet",
            message: "Add your medications to keep track of what you're taking and log your daily diuretic doses.",
            actionTitle: "Add Medication"
        ) {
            viewModel.prepareForAdd()
        }
        .padding(.horizontal, HRTSpacing.md)
        .accessibilityLabel("No medications added yet")
        .accessibilityHint("Tap add medication to get started")
    }

    private var medicationsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.sortedMedications, id: \.id) { medication in
                MedicationRowView(
                    medication: medication,
                    isInConflict: viewModel.isInConflict(medication)
                )
                    .padding(.horizontal, HRTSpacing.md)
                    .padding(.vertical, HRTSpacing.sm)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.prepareForEdit(medication: medication)
                    }
                    .contextMenu {
                        Button {
                            viewModel.prepareForArchive(medication: medication)
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                        Button(role: .destructive) {
                            handleDeleteAction(for: medication)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

                if medication.id != viewModel.sortedMedications.last?.id {
                    HRTDivider()
                        .padding(.horizontal, HRTSpacing.md)
                }
            }
        }
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .padding(.horizontal, HRTSpacing.md)
    }

    private func handleDeleteAction(for medication: Medication) {
        if viewModel.shouldPromptArchiveInsteadOfDelete(medication) {
            viewModel.prepareForDeleteWithArchiveOption(medication: medication)
        } else {
            viewModel.prepareForDelete(medication: medication)
        }
    }

    private var priorMedicationsSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            // Collapsible header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.togglePriorSection()
                }
            } label: {
                HStack {
                    HStack(spacing: HRTSpacing.sm) {
                        Image(systemName: "archivebox")
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                        Text("Prior Medications (\(viewModel.priorMedicationsCount))")
                            .font(.hrtHeadline)
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }

                    Spacer()

                    Image(systemName: viewModel.isPriorSectionExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, HRTSpacing.md)
            .padding(.top, HRTSpacing.md)

            if viewModel.isPriorSectionExpanded {
                priorMedicationsList
            }
        }
    }

    private var priorMedicationsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.priorMedications, id: \.id) { medication in
                HStack {
                    Text(medication.name)
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextFallback)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.prepareForPriorDetail(medication: medication)
                }
                .padding(.horizontal, HRTSpacing.md)
                .padding(.vertical, HRTSpacing.sm)

                if medication.id != viewModel.priorMedications.last?.id {
                    HRTDivider()
                        .padding(.horizontal, HRTSpacing.md)
                }
            }
        }
        .background(Color.hrtCardFallback.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .padding(.horizontal, HRTSpacing.md)
    }
}

/// Toast notification for photo saved confirmation.
/// Provides warm, reassuring feedback to patients.
private struct PhotoSavedToast: View {
    let message: String

    var body: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)

            Text(message)
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextFallback)
        }
        .padding(.horizontal, HRTSpacing.md)
        .padding(.vertical, HRTSpacing.sm + 2)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .hrtFloatingShadow()
        .padding(.bottom, HRTSpacing.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .accessibilityAddTraits(.isStaticText)
    }
}

#Preview {
    MedicationsView()
        .modelContainer(for: Medication.self, inMemory: true)
}
