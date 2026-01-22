import SwiftUI
import SwiftData

struct MedicationsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = MedicationsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    photosSection

                    medicationsSection
                }
                .padding(.vertical)
            }
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Reference Photos", systemImage: "photo.on.rectangle.angled")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    viewModel.prepareForPhotoCapture()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .accessibilityLabel("Add reference photo")
            }
            .padding(.horizontal)

            Text("Photos of your medication bottles or lists for easy reference")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("My Medications", systemImage: "pills")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    viewModel.prepareForAdd()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
                .accessibilityLabel("Add medication")
            }
            .padding(.horizontal)

            if viewModel.hasNoMedications {
                medicationsEmptyState
            } else {
                medicationsList
            }
        }
    }

    private var medicationsEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "pills")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("No Medications Yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Add your medications to keep track of what you're taking and log your daily diuretic doses.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)

            Button {
                viewModel.prepareForAdd()
            } label: {
                Text("Add Medication")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No medications added yet")
        .accessibilityHint("Tap add medication to get started")
    }

    private var medicationsList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.sortedMedications, id: \.id) { medication in
                MedicationRowView(medication: medication)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.prepareForEdit(medication: medication)
                    }
                    .contextMenu {
                        Button(role: .destructive) {
                            viewModel.prepareForDelete(medication: medication)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                if medication.id != viewModel.sortedMedications.last?.id {
                    Divider()
                        .padding(.horizontal)
                }
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

/// Toast notification for photo saved confirmation.
/// Provides warm, reassuring feedback to patients.
private struct PhotoSavedToast: View {
    let message: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)

            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding(.bottom, 24)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
        .accessibilityAddTraits(.isStaticText)
    }
}

#Preview {
    MedicationsView()
        .modelContainer(for: Medication.self, inMemory: true)
}
