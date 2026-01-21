import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                reminderSection
                patientIdentifierSection
                privacySection
                aboutSection
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Reminder Section

    private var reminderSection: some View {
        Section {
            Toggle("Daily Reminder", isOn: $viewModel.reminderEnabled.animation(.easeInOut(duration: 0.2)))
                .accessibilityLabel("Daily reminder")
                .accessibilityHint("Toggle to enable or disable daily check-in reminders")

            if viewModel.reminderEnabled {
                DatePicker(
                    "Reminder Time",
                    selection: Binding(
                        get: { viewModel.reminderTime },
                        set: { viewModel.reminderTime = $0 }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .accessibilityLabel("Reminder time")
                .accessibilityHint("Select the time for your daily reminder")
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        } header: {
            Text("Reminders")
        } footer: {
            Text("Receive a gentle reminder to complete your daily check-in.")
        }
    }

    // MARK: - Patient Identifier Section

    /// Maximum characters allowed for patient identifier to ensure proper PDF formatting
    private let patientIdentifierMaxLength = 50

    private var patientIdentifierSection: some View {
        Section {
            HStack {
                TextField("Name or ID (optional)", text: $viewModel.patientIdentifier)
                    .textContentType(.name)
                    .onChange(of: viewModel.patientIdentifier) { _, newValue in
                        if newValue.count > patientIdentifierMaxLength {
                            viewModel.patientIdentifier = String(newValue.prefix(patientIdentifierMaxLength))
                        }
                    }
                    .accessibilityLabel("Patient identifier")
                    .accessibilityHint("Enter your name or patient ID for PDF exports, up to \(patientIdentifierMaxLength) characters")

                if !viewModel.patientIdentifier.isEmpty {
                    Button {
                        viewModel.clearPatientIdentifier()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear patient identifier")
                    .accessibilityHint("Removes the patient identifier")
                }
            }
        } header: {
            Text("Patient Identifier")
        } footer: {
            Text("This appears on exported PDF reports. It's completely optional and stored only on your device.")
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                privacyRow(
                    icon: "iphone",
                    title: "Stored on Your Device",
                    description: "All your health data stays on this device."
                )

                privacyRow(
                    icon: "icloud.slash",
                    title: "No Cloud Sync",
                    description: "Your data is never uploaded to any cloud service."
                )

                privacyRow(
                    icon: "lock.shield",
                    title: "Your Data, Your Control",
                    description: "Only you can access your information."
                )
            }
            .padding(.vertical, 4)
        } header: {
            Text("Privacy")
        }
    }

    private func privacyRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("HRTY")
                        .font(.headline)
                    Spacer()
                    Text(viewModel.versionString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("HRTY \(viewModel.versionString)")

                Text("Your personal companion for managing heart health. Track your daily progress in just a couple of minutes, and feel confident when sharing updates with your care team.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        } header: {
            Text("About")
        }
    }
}

#Preview {
    SettingsView()
}
