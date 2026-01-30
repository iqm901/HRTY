import SwiftUI
import SwiftData
import AVFoundation

struct LabelScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SodiumViewModel

    @State private var capturedImage: UIImage?
    @State private var isProcessing = false
    @State private var parseResult: NutritionLabelResult?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var customName = ""
    @State private var showingNameEntry = false

    private let parser = NutritionLabelParser()

    var body: some View {
        ZStack {
            if capturedImage == nil {
                cameraView
            } else if isProcessing {
                processingView
            } else if let result = parseResult {
                resultView(result)
            } else {
                notFoundView
            }
        }
        .navigationTitle("Scan Label")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Unable to Process", isPresented: $showingError) {
            Button("Try Again") {
                resetScanner()
            }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingNameEntry) {
            nameEntrySheet
        }
    }

    // MARK: - Camera View

    private var cameraView: some View {
        ZStack {
            CameraViewRepresentable(onImageCaptured: { image in
                capturedImage = image
                processImage(image)
            })
            .ignoresSafeArea()

            // Overlay with guidance
            VStack {
                Spacer()

                Text("Position the nutrition label within the frame")
                    .font(.hrtSubheadline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.bottom, HRTSpacing.xl)
            }

            // Frame guide
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                .frame(width: 280, height: 350)
        }
    }

    // MARK: - Processing View

    private var processingView: some View {
        VStack(spacing: HRTSpacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.hrtPinkFallback)

            Text("Reading nutrition label...")
                .font(.hrtBody)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.hrtBackgroundFallback)
    }

    // MARK: - Result View

    private func resultView(_ result: NutritionLabelResult) -> some View {
        VStack(spacing: HRTSpacing.lg) {
            Spacer()

            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.hrtGoodFallback.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.hrtGoodFallback)
            }

            // Result Info
            VStack(spacing: HRTSpacing.sm) {
                Text("Sodium Found")
                    .font(.hrtTitle3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hrtTextFallback)

                Text(SodiumConstants.formatSodium(result.sodiumMg))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.hrtPinkFallback)

                if let serving = result.servingSize {
                    Text("per \(serving)")
                        .font(.hrtSubheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }
            }

            Spacer()

            // Action Buttons
            VStack(spacing: HRTSpacing.md) {
                Button {
                    showingNameEntry = true
                } label: {
                    Text("Use This Value")
                        .font(.hrtBody)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.hrtPinkFallback)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    resetScanner()
                } label: {
                    Text("Scan Again")
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
            }
            .padding(.horizontal, HRTSpacing.lg)
            .padding(.bottom, HRTSpacing.xl)
        }
        .background(Color.hrtBackgroundFallback)
    }

    // MARK: - Not Found View

    private var notFoundView: some View {
        VStack(spacing: HRTSpacing.lg) {
            Spacer()

            // Error Icon
            ZStack {
                Circle()
                    .fill(Color.hrtCautionFallback.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "eye.slash.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.hrtCautionFallback)
            }

            VStack(spacing: HRTSpacing.sm) {
                Text("Could Not Find Sodium")
                    .font(.hrtTitle3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hrtTextFallback)

                Text("Make sure the nutrition facts label is clearly visible and well-lit.")
                    .font(.hrtSubheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, HRTSpacing.lg)
            }

            Spacer()

            // Action Buttons
            VStack(spacing: HRTSpacing.md) {
                Button {
                    resetScanner()
                } label: {
                    Text("Try Again")
                        .font(.hrtBody)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.hrtPinkFallback)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    viewModel.prepareForAdd()
                    dismiss()
                } label: {
                    Text("Enter Manually")
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
            }
            .padding(.horizontal, HRTSpacing.lg)
            .padding(.bottom, HRTSpacing.xl)
        }
        .background(Color.hrtBackgroundFallback)
    }

    // MARK: - Name Entry Sheet

    private var nameEntrySheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Food or drink name", text: $customName)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("What did you eat?")
                }

                if let result = parseResult {
                    Section {
                        HStack {
                            Text("Sodium")
                            Spacer()
                            Text(SodiumConstants.formatSodium(result.sodiumMg))
                                .foregroundStyle(Color.hrtTextSecondaryFallback)
                        }

                        if let serving = result.servingSize {
                            HStack {
                                Text("Serving")
                                Spacer()
                                Text(serving)
                                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                            }
                        }
                    } header: {
                        Text("Scanned Values")
                    }
                }
            }
            .navigationTitle("Log Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingNameEntry = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Log") {
                        logEntry()
                    }
                    .disabled(customName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func processImage(_ image: UIImage) {
        isProcessing = true

        Task {
            let result = await parser.parseImage(image)

            await MainActor.run {
                isProcessing = false
                parseResult = result
            }
        }
    }

    private func logEntry() {
        guard let result = parseResult else { return }

        let name = customName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }

        viewModel.addFromBarcode(
            name: name,
            sodiumMg: result.sodiumMg,
            servingSize: result.servingSize,
            barcode: "",
            context: modelContext
        )

        showingNameEntry = false
        dismiss()
    }

    private func resetScanner() {
        capturedImage = nil
        parseResult = nil
        isProcessing = false
        customName = ""
    }
}

// MARK: - Camera View Representable

struct CameraViewRepresentable: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onImageCaptured = onImageCaptured
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}

// MARK: - Camera View Controller

class CameraViewController: UIViewController {
    var onImageCaptured: ((UIImage) -> Void)?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        addCaptureButton()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCamera() {
        let session = AVCaptureSession()
        session.sessionPreset = .photo

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            return
        }

        let output = AVCapturePhotoOutput()

        if session.canAddInput(input) && session.canAddOutput(output) {
            session.addInput(input)
            session.addOutput(output)

            photoOutput = output
            captureSession = session

            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer

            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }
    }

    private func addCaptureButton() {
        let button = UIButton(type: .system)
        button.setTitle("Capture", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.systemPink, for: .normal)
        button.layer.cornerRadius = 35
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            button.widthAnchor.constraint(equalToConstant: 70),
            button.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    @objc private func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }

        DispatchQueue.main.async {
            self.onImageCaptured?(image)
        }
    }
}

#Preview {
    NavigationStack {
        LabelScannerView(viewModel: SodiumViewModel())
    }
    .modelContainer(for: [SodiumEntry.self, SodiumTemplate.self], inMemory: true)
}
