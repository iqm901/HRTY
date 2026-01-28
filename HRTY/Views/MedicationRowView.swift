import SwiftUI

struct MedicationRowView: View {
    let medication: Medication
    var isInConflict: Bool = false
    @State private var showingEducationSheet = false

    /// The detected medication class for this medication
    private var medicationClass: EducationContent.MedicationClass {
        EducationContent.MedicationClass.detect(from: medication.name)
    }

    /// Whether we have educational content for this medication
    private var hasEducation: Bool {
        medicationClass != .unknown
    }

    var body: some View {
        HStack(alignment: .center, spacing: HRTSpacing.sm) {
            VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                HStack(spacing: HRTSpacing.sm) {
                    Text(medication.name)
                        .font(.hrtBodySemibold)
                        .foregroundStyle(Color.hrtTextFallback)

                    if isInConflict {
                        reviewBadge
                    }

                    if hasEducation {
                        medicationClassBadge
                    }
                }

                Text(dosageText)
                    .font(.hrtCallout)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)

                if !medication.schedule.isEmpty {
                    Text(medication.schedule)
                        .font(.hrtCaption)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
            }

            Spacer(minLength: 0)

            if hasEducation {
                Button {
                    showingEducationSheet = true
                } label: {
                    Image(systemName: "info.circle")
                        .font(.body)
                        .foregroundStyle(Color.hrtPinkFallback)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Learn about \(medicationClass.rawValue)")
                .accessibilityHint("Opens educational information about this medication type")
            }

            Image(systemName: "chevron.right")
                .font(.hrtCaption)
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, HRTSpacing.xs)
        .padding(.horizontal, isInConflict ? HRTSpacing.sm : 0)
        .background(isInConflict ? Color.conflictBackground : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: isInConflict ? HRTRadius.small : 0))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to edit this medication")
        .sheet(isPresented: $showingEducationSheet) {
            if let education = EducationContent.Medications.education(for: medicationClass) {
                MedicationEducationSheet(education: education)
            }
        }
    }

    // MARK: - Subviews

    private var diureticBadge: some View {
        Text("Diuretic")
            .font(.hrtSmall)
            .fontWeight(.medium)
            .padding(.horizontal, HRTSpacing.sm)
            .padding(.vertical, 2)
            .background(Color.hrtPinkLightFallback)
            .foregroundStyle(Color.hrtPinkFallback)
            .clipShape(Capsule())
            .accessibilityLabel("This is a diuretic medication")
    }

    private var medicationClassBadge: some View {
        Text(medicationClass.rawValue)
            .font(.hrtSmall)
            .fontWeight(.medium)
            .padding(.horizontal, HRTSpacing.sm)
            .padding(.vertical, 2)
            .background(Color.hrtPinkLightFallback.opacity(0.5))
            .foregroundStyle(Color.hrtPinkFallback.opacity(0.8))
            .clipShape(Capsule())
            .accessibilityLabel("This is a \(medicationClass.rawValue) medication")
    }

    private var reviewBadge: some View {
        Text("Review")
            .font(.hrtSmall)
            .fontWeight(.medium)
            .padding(.horizontal, HRTSpacing.sm)
            .padding(.vertical, 2)
            .background(Color.conflictBadgeBackground)
            .foregroundStyle(Color.conflictBadgeText)
            .clipShape(Capsule())
            .accessibilityLabel("This medication may need review")
    }

    // MARK: - Computed Properties

    private var dosageText: String {
        "\(medication.dosage) \(medication.unit)"
    }

    private var accessibilityLabel: String {
        var label = "\(medication.name), \(dosageText)"
        if medication.isDiuretic {
            label += ", diuretic"
        }
        if isInConflict {
            label += ", needs review with care team"
        }
        if !medication.schedule.isEmpty {
            label += ", taken \(medication.schedule)"
        }
        return label
    }
}

// MARK: - Medication Education Sheet

/// Sheet displaying educational content about a medication class
struct MedicationEducationSheet: View {
    let education: MedicationEducation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: HRTSpacing.lg) {
                    // Header
                    VStack(alignment: .leading, spacing: HRTSpacing.xs) {
                        Label(education.className, systemImage: "pills.fill")
                            .font(.hrtTitle2)
                            .foregroundStyle(Color.hrtPinkFallback)
                    }

                    // How it helps
                    educationSection(
                        title: "How It Helps",
                        icon: "heart.fill",
                        content: education.howItHelps
                    )

                    // Common side effects
                    educationSection(
                        title: "Common Side Effects",
                        icon: "exclamationmark.triangle.fill",
                        content: education.commonSideEffects
                    )

                    // Important notes
                    VStack(alignment: .leading, spacing: HRTSpacing.sm) {
                        Label("Important", systemImage: "info.circle.fill")
                            .font(.hrtHeadline)
                            .foregroundStyle(Color.hrtCautionFallback)

                        Text(education.importantNotes)
                            .font(.hrtBody)
                            .foregroundStyle(Color.hrtTextFallback)
                    }
                    .padding(HRTSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.hrtCautionFallback.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))

                    // Source
                    HStack {
                        Image(systemName: "book.closed.fill")
                            .font(.caption)
                        Text("Source: \(education.source)")
                            .font(.hrtCaption)
                    }
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, HRTSpacing.sm)
                }
                .padding(HRTSpacing.lg)
            }
            .background(Color.hrtBackgroundFallback)
            .navigationTitle("About This Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func educationSection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            Label(title, systemImage: icon)
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextFallback)

            Text(content)
                .font(.hrtBody)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(HRTSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.hrtCardFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
    }
}

// MARK: - Conflict Colors

private extension Color {
    /// Warm amber/yellow background for medications in conflict
    static let conflictBackground = Color.adaptive(
        light: Color(red: 255/255, green: 251/255, blue: 235/255),
        dark: Color(red: 60/255, green: 50/255, blue: 30/255)
    )

    /// Background for the "Review" badge
    static let conflictBadgeBackground = Color.adaptive(
        light: Color(red: 254/255, green: 243/255, blue: 199/255),
        dark: Color(red: 80/255, green: 65/255, blue: 30/255)
    )

    /// Text color for the "Review" badge
    static let conflictBadgeText = Color.adaptive(
        light: Color(red: 180/255, green: 130/255, blue: 20/255),
        dark: Color(red: 250/255, green: 200/255, blue: 80/255)
    )
}

#Preview {
    List {
        MedicationRowView(medication: Medication(
            name: "Furosemide",
            dosage: "40",
            unit: "mg",
            schedule: "Morning",
            isDiuretic: true
        ), isInConflict: true)

        MedicationRowView(medication: Medication(
            name: "Bumetanide",
            dosage: "1",
            unit: "mg",
            schedule: "Morning",
            isDiuretic: true
        ), isInConflict: true)

        MedicationRowView(medication: Medication(
            name: "Lisinopril",
            dosage: "10",
            unit: "mg",
            schedule: "Morning",
            isDiuretic: false
        ))

        MedicationRowView(medication: Medication(
            name: "Metoprolol",
            dosage: "25",
            unit: "mg",
            schedule: "Twice daily",
            isDiuretic: false
        ))
    }
}
