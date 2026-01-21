import SwiftUI
import SwiftData

struct ExportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ExportViewModel()

    /// Icon size that scales with Dynamic Type settings
    @ScaledMetric(relativeTo: .title) private var headerIconSize: CGFloat = 48

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
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

                    Spacer(minLength: 40)

                    disclaimerSection
                }
                .padding()
                .animation(.easeInOut(duration: 0.3), value: viewModel.generationState)
            }
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
        VStack(spacing: 8) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: headerIconSize))
                .foregroundStyle(.blue)
                .accessibilityHidden(true)

            Text("Share with Your Care Team")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Create a summary to bring to your next appointment")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Share with Your Care Team. Create a summary to bring to your next appointment.")
    }

    // MARK: - Date Range Section

    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Date Range", systemImage: "calendar")
                .font(.headline)
                .foregroundStyle(.primary)

            Text(viewModel.dateRangeText)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Date range: \(viewModel.dateRangeText)")
    }

    // MARK: - Patient Identifier Section

    private var patientIdentifierSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Patient Identifier (Optional)", systemImage: "person.text.rectangle")
                .font(.headline)
                .foregroundStyle(.primary)

            TextField("Name or ID", text: $viewModel.patientIdentifier)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .autocorrectionDisabled()
                .accessibilityLabel("Patient identifier")
                .accessibilityHint("Optional. Enter your name or ID to include in the PDF.")

            Text("This will appear at the top of your PDF summary")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Generate Button

    private var generateButton: some View {
        Button {
            generatePDF()
        } label: {
            HStack(spacing: 12) {
                if viewModel.isGenerating {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(viewModel.isGenerating ? "Creating PDF..." : "Generate PDF")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(viewModel.isGenerating ? Color.gray : Color.blue)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(viewModel.isGenerating)
        .accessibilityLabel(viewModel.isGenerating ? "Creating PDF" : "Generate PDF")
        .accessibilityHint("Creates a PDF summary of your health data from the past 30 days")
        .accessibilityAddTraits(viewModel.isGenerating ? .isButton : [.isButton])
    }

    // MARK: - Success Message

    private var successMessage: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("PDF Ready")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("Choose how to share your summary")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.showShareSheet = true
            } label: {
                Text("Share")
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Share PDF")
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("PDF ready. Choose how to share your summary.")
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: - Error Message

    private func errorMessageView(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.title2)

            VStack(alignment: .leading, spacing: 2) {
                Text("Couldn't Create PDF")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.reset()
            } label: {
                Text("Try Again")
                    .fontWeight(.medium)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .accessibilityLabel("Try again")
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message). Tap try again to retry.")
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "info.circle")
                .foregroundStyle(.tertiary)

            Text("The PDF includes your weight trends, symptom history, diuretic doses, and any alerts from the past 30 days.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("The PDF includes your weight trends, symptom history, diuretic doses, and any alerts from the past 30 days.")
    }

    // MARK: - Actions

    private func generatePDF() {
        viewModel.generatePDF(context: modelContext)
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
