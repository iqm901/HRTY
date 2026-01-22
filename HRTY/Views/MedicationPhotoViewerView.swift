import SwiftUI

/// Full-screen photo viewer for medication reference photos.
/// Supports pinch-to-zoom, swipe gestures, and deletion.
struct MedicationPhotoViewerView: View {
    let photo: MedicationPhoto
    let onDelete: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var fullImage: UIImage?
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showingDeleteConfirmation = false

    private let photoService = PhotoService.shared

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.black
                        .ignoresSafeArea()

                    if let image = fullImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(magnificationGesture)
                            .gesture(dragGesture)
                            .onTapGesture(count: 2) {
                                if reduceMotion {
                                    if scale > 1 {
                                        scale = 1
                                        offset = .zero
                                    } else {
                                        scale = 2
                                    }
                                } else {
                                    withAnimation {
                                        if scale > 1 {
                                            scale = 1
                                            offset = .zero
                                        } else {
                                            scale = 2
                                        }
                                    }
                                }
                            }
                            .accessibilityLabel("Medication photo")
                            .accessibilityHint("Double tap to zoom, pinch to adjust zoom level")
                    } else {
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .tint(.white)
                }

                ToolbarItem(placement: .principal) {
                    Text(photo.capturedAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.subheadline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.white)
                    .accessibilityLabel("Delete photo")
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .confirmationDialog(
                "Delete Photo",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this photo? This cannot be undone.")
            }
            .task {
                fullImage = photoService.loadFullImage(for: photo)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Gestures

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1), 4)
            }
            .onEnded { _ in
                lastScale = 1.0
                if scale < 1 {
                    if reduceMotion {
                        scale = 1
                        offset = .zero
                    } else {
                        withAnimation {
                            scale = 1
                            offset = .zero
                        }
                    }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1 {
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                lastOffset = offset
                if scale <= 1 {
                    if reduceMotion {
                        offset = .zero
                        lastOffset = .zero
                    } else {
                        withAnimation {
                            offset = .zero
                            lastOffset = .zero
                        }
                    }
                }
            }
    }
}

#Preview {
    MedicationPhotoViewerView(
        photo: MedicationPhoto(
            filename: "test.jpg",
            thumbnailFilename: "test_thumb.jpg"
        ),
        onDelete: { }
    )
}
