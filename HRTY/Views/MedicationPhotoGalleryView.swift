import SwiftUI

/// Displays a grid gallery of medication reference photos.
/// Supports viewing individual photos and deletion.
struct MedicationPhotoGalleryView: View {
    let photos: [MedicationPhoto]
    let onPhotoTapped: (MedicationPhoto) -> Void
    let onDeletePhoto: (MedicationPhoto) -> Void

    private let photoService = PhotoService.shared
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]

    var body: some View {
        if photos.isEmpty {
            emptyState
        } else {
            photoGrid
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("No Photos Yet")
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Add photos of your medication bottles or lists for easy reference.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("No medication photos. Add photos for reference.")
    }

    private var photoGrid: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(photos) { photo in
                PhotoThumbnailView(
                    photo: photo,
                    onTap: { onPhotoTapped(photo) },
                    onDelete: { onDeletePhoto(photo) }
                )
            }
        }
        .padding(.horizontal)
    }
}

/// Individual photo thumbnail with tap and delete actions.
struct PhotoThumbnailView: View {
    let photo: MedicationPhoto
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var thumbnailImage: UIImage?
    @State private var showingDeleteConfirmation = false

    private let photoService = PhotoService.shared

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let image = thumbnailImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .overlay {
                            ProgressView()
                        }
                }
            }
            .frame(height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .confirmationDialog(
            "Delete Photo",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this photo? This cannot be undone.")
        }
        .accessibilityLabel("Medication photo from \(photo.capturedAt.formatted(date: .abbreviated, time: .shortened))")
        .accessibilityHint("Tap to view full size, long press for options")
        .task {
            thumbnailImage = photoService.loadThumbnail(for: photo)
        }
    }
}

#Preview {
    MedicationPhotoGalleryView(
        photos: [],
        onPhotoTapped: { _ in },
        onDeletePhoto: { _ in }
    )
}
