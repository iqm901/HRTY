import SwiftUI
import SwiftData

struct ExportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ExportViewModel()

    /// Icon size that scales with Dynamic Type settings
    @ScaledMetric(relativeTo: .title) private var headerIconSize: CGFloat = 48

    var body: some View {
        NavigationStack {
            ZStack {
                Color.hrtBackgroundFallback
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: HRTSpacing.lg) {
                        headerSection

                        dateRangeSection

                        patientIdentifierSection

                        generateButton

                        if viewModel.didSucceed {
                            successMessage
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }

                        if let errorMessage = viewModel.errorMessage {
                            errorMessageView(errorMessage)
                                .transition(.asymmetric(
                                    insertion: .scale(scale: 0.95).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }

                        Spacer(minLength: HRTSpacing.xl)

                        disclaimerSection
                    }
                    .padding(HRTSpacing.md)
                    .animation(HRTAnimation.standard, value: viewModel.generationState)
                }
                .scrollContentBackground(.hidden)
            }
            .toolbarBackground(Color.hrtBackgroundFallback, for: .navigationBar)
            .navigationTitle("Export")
            .sheet(isPresented: $viewModel.showShareSheet) {
                if let pdfData = viewModel.pdfData {
                    ShareSheet(activityItems: [PDFShareItem(data: pdfData)])
                        .presentationDetents([.medium, .large])
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: HRTSpacing.sm) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: headerIconSize))
                .foregroundStyle(Color.hrtPinkFallback)
                .accessibilityHidden(true)

            Text("Share with Your Care Team")
                .font(.hrtTitle2)
                .foregroundStyle(Color.hrtTextFallback)
                .multilineTextAlignment(.center)

            Text("Create a summary to bring to your next appointment")
                .font(.hrtCallout)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .multilineTextAlignment(.center)
        }
        .padding(.top, HRTSpacing.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Share with Your Care Team. Create a summary to bring to your next appointment.")
    }

    // MARK: - Date Range Section

    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.hrtPinkFallback)
                Text("Date Range")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)
            }

            Text(viewModel.dateRangeText)
                .font(.hrtBody)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .padding(.horizontal, HRTSpacing.md)
                .padding(.vertical, HRTSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.hrtCardFallback)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Date range: \(viewModel.dateRangeText)")
    }

    // MARK: - Patient Identifier Section

    private var patientIdentifierSection: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            HStack(spacing: HRTSpacing.sm) {
                Image(systemName: "person.text.rectangle")
                    .foregroundStyle(Color.hrtPinkFallback)
                Text("Patient Identifier (Optional)")
                    .font(.hrtHeadline)
                    .foregroundStyle(Color.hrtTextFallback)
            }

            HRTTextField("Patient Identifier", placeholder: "Name or ID", text: $viewModel.patientIdentifier)
                .textContentType(.name)
                .autocorrectionDisabled()
                .accessibilityLabel("Patient identifier")
                .accessibilityHint("Optional. Enter your name or ID to include in the PDF.")

            Text("This will appear at the top of your PDF summary")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            generatePDF()
        } label: {
            HStack(spacing: HRTSpacing.sm) {
                if viewModel.isGenerating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(viewModel.isGenerating ? "Creating PDF..." : "Generate PDF")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(HRTPrimaryButtonStyle())
        .disabled(viewModel.isGenerating)
        .opacity(viewModel.isGenerating ? 0.7 : 1.0)
        .accessibilityLabel(viewModel.isGenerating ? "Creating PDF" : "Generate PDF")
        .accessibilityHint("Creates a PDF summary of your health data from the past 30 days")
        .accessibilityAddTraits(viewModel.isGenerating ? .isButton : [.isButton])
    }

    // MARK: - Success Message

    private var successMessage: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.hrtGoodFallback)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("PDF Ready")
                    .font(.hrtBodySemibold)
                    .foregroundStyle(Color.hrtTextFallback)

                Text("Choose how to share your summary")
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            Spacer()

            Button {
                viewModel.showShareSheet = true
            } label: {
                Text("Share")
                    .font(.hrtBodyMedium)
                    .padding(.horizontal, HRTSpacing.md)
                    .padding(.vertical, HRTSpacing.sm)
                    .background(Color.hrtPinkFallback)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Share PDF")
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtGoodFallback.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("PDF ready. Choose how to share your summary.")
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: - Error Message

    private func errorMessageView(_ message: String) -> some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.hrtCautionFallback)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Couldn't Create PDF")
                    .font(.hrtBodySemibold)
                    .foregroundStyle(Color.hrtTextFallback)

                Text(message)
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            Spacer()

            Button {
                viewModel.reset()
            } label: {
                Text("Try Again")
                    .font(.hrtBodyMedium)
                    .padding(.horizontal, HRTSpacing.md)
                    .padding(.vertical, HRTSpacing.sm)
                    .background(Color.hrtCautionFallback)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Try again")
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtCautionFallback.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message). Tap try again to retry.")
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        VStack(spacing: HRTSpacing.sm) {
            Image(systemName: "info.circle")
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            Text("The PDF includes your weight trends, symptom history, diuretic doses, and any alerts from the past 30 days.")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, HRTSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("The PDF includes your weight trends, symptom history, diuretic doses, and any alerts from the past 30 days.")
    }

    // MARK: - Actions

    private func generatePDF() {
        Task {
            await viewModel.generatePDF(context: modelContext)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - PDF Share Item Wrapper

/// Wrapper for PDF data that provides a proper filename for sharing
/// Named PDFShareItem to avoid conflict with PDFKit.PDFDocument
class PDFShareItem: NSObject {
    let data: Data
    let filename: String

    init(data: Data, filename: String = "HRTY-Health-Summary.pdf") {
        self.data = data
        self.filename = filename
        super.init()
    }
}

extension PDFShareItem: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return data
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return data
    }

    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "HRTY Health Summary"
    }

    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "com.adobe.pdf"
    }

    func activityViewController(_ activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: UIActivity.ActivityType?, suggestedSize size: CGSize) -> UIImage? {
        return nil
    }
}

#Preview {
    ExportView()
        .modelContainer(for: [DailyEntry.self, Medication.self, AlertEvent.self], inMemory: true)
}
