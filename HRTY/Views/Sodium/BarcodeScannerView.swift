import SwiftUI
import SwiftData
import VisionKit

struct BarcodeScannerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: SodiumViewModel

    @State private var isScanning = true
    @State private var scannedBarcode: String?
    @State private var foundProduct: ProductInfo?
    @State private var showingManualEntry = false
    @State private var customName = ""
    @State private var customSodium = ""
    @State private var customServing = ""

    private let productDatabase = LocalProductDatabase()

    var body: some View {
        ZStack {
            if DataScannerViewController.isSupported && DataScannerViewController.isAvailable {
                if isScanning {
                    scannerView
                } else if let product = foundProduct {
                    productFoundView(product)
                } else if scannedBarcode != nil {
                    productNotFoundView
                }
            } else {
                unsupportedView
            }
        }
        .navigationTitle("Scan Barcode")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showingManualEntry) {
            manualEntrySheet
        }
    }

    // MARK: - Scanner View

    private var scannerView: some View {
        DataScannerRepresentable(
            recognizedDataTypes: [.barcode(symbologies: [.ean13, .ean8, .upce, .code128])],
            onBarcodeScanned: { barcode in
                handleScannedBarcode(barcode)
            }
        )
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Text("Point camera at a barcode")
                .font(.hrtSubheadline)
                .foregroundStyle(.white)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom, HRTSpacing.xl)
        }
    }

    // MARK: - Product Found View

    private func productFoundView(_ product: ProductInfo) -> some View {
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

            // Product Info
            VStack(spacing: HRTSpacing.sm) {
                Text(product.name)
                    .font(.hrtTitle3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hrtTextFallback)
                    .multilineTextAlignment(.center)

                if let brand = product.brand {
                    Text(brand)
                        .font(.hrtSubheadline)
                        .foregroundStyle(Color.hrtTextSecondaryFallback)
                }

                Text(SodiumConstants.formatSodium(product.sodiumMg))
                    .font(.hrtTitle2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.hrtPinkFallback)

                if let serving = product.servingSize {
                    Text("per \(serving)")
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }

            Spacer()

            // Action Buttons
            VStack(spacing: HRTSpacing.md) {
                Button {
                    logProduct(product)
                } label: {
                    Text("Log This")
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
                    Text("Scan Another")
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
            }
            .padding(.horizontal, HRTSpacing.lg)
            .padding(.bottom, HRTSpacing.xl)
        }
        .background(Color.hrtBackgroundFallback)
    }

    // MARK: - Product Not Found View

    private var productNotFoundView: some View {
        VStack(spacing: HRTSpacing.lg) {
            Spacer()

            // Not Found Icon
            ZStack {
                Circle()
                    .fill(Color.hrtCautionFallback.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.hrtCautionFallback)
            }

            VStack(spacing: HRTSpacing.sm) {
                Text("Product Not Found")
                    .font(.hrtTitle3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.hrtTextFallback)

                Text("We don't have this product in our database yet.")
                    .font(.hrtSubheadline)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .multilineTextAlignment(.center)

                if let barcode = scannedBarcode {
                    Text("Barcode: \(barcode)")
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                        .padding(.top, HRTSpacing.xs)
                }
            }
            .padding(.horizontal, HRTSpacing.lg)

            Spacer()

            // Action Buttons
            VStack(spacing: HRTSpacing.md) {
                Button {
                    showingManualEntry = true
                } label: {
                    Text("Add Product Details")
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
                    Text("Try Again")
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
            }
            .padding(.horizontal, HRTSpacing.lg)
            .padding(.bottom, HRTSpacing.xl)
        }
        .background(Color.hrtBackgroundFallback)
    }

    // MARK: - Manual Entry Sheet

    private var manualEntrySheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Product name", text: $customName)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("Name")
                }

                Section {
                    HStack {
                        TextField("Amount", text: $customSodium)
                            .keyboardType(.numberPad)
                        Text("mg")
                            .foregroundStyle(Color.hrtTextSecondaryFallback)
                    }
                } header: {
                    Text("Sodium")
                }

                Section {
                    TextField("e.g., 1 cup, 1 can", text: $customServing)
                } header: {
                    Text("Serving Size (Optional)")
                }
            }
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingManualEntry = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save & Log") {
                        saveAndLogCustomProduct()
                    }
                    .disabled(customName.isEmpty || Int(customSodium) == nil)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Unsupported View

    private var unsupportedView: some View {
        VStack(spacing: HRTSpacing.lg) {
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 60))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("Barcode Scanning Unavailable")
                .font(.hrtTitle3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.hrtTextFallback)

            Text("This device doesn't support barcode scanning. Please use manual entry instead.")
                .font(.hrtSubheadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .multilineTextAlignment(.center)
                .padding(.horizontal, HRTSpacing.lg)
        }
        .background(Color.hrtBackgroundFallback)
    }

    // MARK: - Helper Methods

    private func handleScannedBarcode(_ barcode: String) {
        scannedBarcode = barcode
        isScanning = false

        // Look up product in local database
        if let product = productDatabase.findProduct(barcode: barcode, context: modelContext) {
            foundProduct = product
        }
    }

    private func logProduct(_ product: ProductInfo) {
        viewModel.addFromBarcode(
            name: product.name,
            sodiumMg: product.sodiumMg,
            servingSize: product.servingSize,
            barcode: product.barcode,
            context: modelContext
        )
        dismiss()
    }

    private func saveAndLogCustomProduct() {
        guard let barcode = scannedBarcode,
              let sodiumMg = Int(customSodium) else { return }

        let product = ProductInfo(
            barcode: barcode,
            name: customName,
            sodiumMg: sodiumMg,
            servingSize: customServing.isEmpty ? nil : customServing,
            brand: nil
        )

        // Save to local database for future lookups
        productDatabase.saveCustomProduct(product, context: modelContext)

        // Log the entry
        logProduct(product)
    }

    private func resetScanner() {
        scannedBarcode = nil
        foundProduct = nil
        customName = ""
        customSodium = ""
        customServing = ""
        isScanning = true
    }
}

// MARK: - DataScannerRepresentable

struct DataScannerRepresentable: UIViewControllerRepresentable {
    let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType>
    let onBarcodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeScanned: onBarcodeScanned)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let onBarcodeScanned: (String) -> Void

        init(onBarcodeScanned: @escaping (String) -> Void) {
            self.onBarcodeScanned = onBarcodeScanned
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .barcode(let barcode) = item {
                if let value = barcode.payloadStringValue {
                    dataScanner.stopScanning()
                    onBarcodeScanned(value)
                }
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // Auto-capture on first recognition
            if let firstItem = addedItems.first, case .barcode(let barcode) = firstItem {
                if let value = barcode.payloadStringValue {
                    dataScanner.stopScanning()
                    onBarcodeScanned(value)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        BarcodeScannerView(viewModel: SodiumViewModel())
    }
    .modelContainer(for: [SodiumEntry.self, SodiumTemplate.self], inMemory: true)
}
