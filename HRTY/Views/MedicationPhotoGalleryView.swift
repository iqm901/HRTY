import SwiftUI

/// Displays a grid gallery of medication reference photos.
/// Supports viewing individual photos and deletion.
/// Adapts to Dynamic Type settings for accessibility.
struct MedicationPhotoGalleryView: View {
    let photos: [MedicationPhoto]
    let onPhotoTapped: (MedicationPhoto) -> Void
    let onDeletePhoto: (MedicationPhoto) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private let photoService = PhotoService.shared

    /// Returns the number of columns based on Dynamic Type size.
    /// Larger text sizes get fewer columns for better usability.
    private var columnCount: Int {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium, .large:
            return 3
        case .xLarge, .xxLarge:
            return 2
        case .xxxLarge, .accessibility1, .accessibility2, .accessibility3, .accessibility4, .accessibility5:
            return 2
        @unknown default:
            return 3
        }
    }

    /// Returns the thumbnail height based on Dynamic Type size.
    /// Scales up for accessibility sizes to improve visibility.
    private var thumbnailHeight: CGFloat {
        switch dynamicTypeSize {
        case .xSmall, .small, .medium, .large:
            return 110
        case .xLarge, .xxLarge:
            return 130
        case .xxxLarge, .accessibility1:
            return 150
        case .accessibility2, .accessibility3:
            return 170
        case .accessibility4, .accessibility5:
            return 190
        @unknown default:
            return 110
        }
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 8), count: columnCount)
    }

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
                    thumbnailHeight: thumbnailHeight,
                    onTap: { onPhotoTapped(photo) },
                    onDelete: { onDeletePhoto(photo) }
                )
            }
        }
        .padding(.horizontal)
    }
}

/// Individual photo thumbnail with tap and delete actions.
/// Supports Dynamic Type by accepting a configurable height.
/// Accepts an optional thumbnail loader closure for dependency injection and testing.
struct PhotoThumbnailView: View {
    let photo: MedicationPhoto
    let thumbnailHeight: CGFloat
    let onTap: () -> Void
    let onDelete: () -> Void
    /// Optional closure to load thumbnail image. Defaults to PhotoService.shared if not provided.
    var loadThumbnail: ((MedicationPhoto) -> UIImage?)?

    @State private var thumbnailImage: UIImage?
    @State private var showingDeleteConfirmation = false

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
                                .accessibilityHidden(true)
                        }
                }
            }
            .frame(height: thumbnailHeight)
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
            Text("This will remove the photo from your saved reference photos.")
        }
        .accessibilityLabel(thumbnailImage == nil
            ? "Loading medication photo from \(photo.capturedAt.formatted(date: .abbreviated, time: .shortened))"
            : "Medication photo from \(photo.capturedAt.formatted(date: .abbreviated, time: .shortened))")
        .accessibilityHint(thumbnailImage == nil
            ? "Photo is loading"
            : "Tap to view full size, long press for options")
        .task {
            // Use injected loader if provided, otherwise fall back to shared service
            if let loader = loadThumbnail {
                thumbnailImage = loader(photo)
            } else {
                thumbnailImage = PhotoService.shared.loadThumbnail(for: photo)
            }
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
