import SwiftUI

// MARK: - HRT Text Field

/// A styled text field with optional label
struct HRTTextField: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?

    init(
        _ label: String? = nil,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.textContentType = textContentType
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            if let label {
                Text(label)
                    .font(.hrtInputLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            TextField(placeholder, text: $text)
                .font(.hrtBody)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .padding(HRTSpacing.md)
                .background(Color.hrtBackgroundSecondaryFallback)
                .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        }
    }
}

// MARK: - HRT Metric Input

/// A large input field for entering metrics like weight
struct HRTMetricInput: View {
    @Binding var value: String
    let unit: String
    let placeholder: String
    @FocusState private var isFocused: Bool

    init(
        value: Binding<String>,
        unit: String,
        placeholder: String = "0"
    ) {
        self._value = value
        self.unit = unit
        self.placeholder = placeholder
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: HRTSpacing.sm) {
            TextField(placeholder, text: $value)
                .font(.hrtMetricLarge)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.center)
                .focused($isFocused)
                .frame(minWidth: 100)

            Text(unit)
                .font(.hrtHeadline)
                .foregroundStyle(Color.hrtTextSecondaryFallback)
        }
        .padding(HRTSpacing.lg)
        .background(Color.hrtBackgroundSecondaryFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.large))
        .onTapGesture {
            isFocused = true
        }
    }
}

// MARK: - HRT Search Field

/// A search input field with icon
struct HRTSearchField: View {
    let placeholder: String
    @Binding var text: String

    init(
        placeholder: String = "Search",
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        HStack(spacing: HRTSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.hrtTextTertiaryFallback)

            TextField(placeholder, text: $text)
                .font(.hrtBody)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(HRTSpacing.sm + 4)
        .background(Color.hrtBackgroundSecondaryFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
    }
}

// MARK: - HRT Picker Row

/// A row that shows a picker value with navigation
struct HRTPickerRow: View {
    let label: String
    let value: String
    let placeholder: String

    init(
        _ label: String,
        value: String,
        placeholder: String = "Select"
    ) {
        self.label = label
        self.value = value
        self.placeholder = placeholder
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.hrtBody)
                .foregroundStyle(Color.hrtTextFallback)

            Spacer()

            Text(value.isEmpty ? placeholder : value)
                .font(.hrtBody)
                .foregroundStyle(value.isEmpty ? Color.hrtTextTertiaryFallback : Color.hrtTextSecondaryFallback)

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.hrtTextTertiaryFallback)
        }
        .padding(HRTSpacing.md)
        .background(Color.hrtBackgroundSecondaryFallback)
        .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
    }
}

// MARK: - HRT Text Area

/// A multi-line text input field
struct HRTTextArea: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat

    init(
        _ label: String? = nil,
        placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 100
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: HRTSpacing.sm) {
            if let label {
                Text(label)
                    .font(.hrtInputLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
            }

            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.hrtBody)
                        .foregroundStyle(Color.hrtTextTertiaryFallback)
                        .padding(HRTSpacing.md)
                }

                TextEditor(text: $text)
                    .font(.hrtBody)
                    .scrollContentBackground(.hidden)
                    .padding(HRTSpacing.sm)
                    .frame(minHeight: minHeight)
            }
            .background(Color.hrtBackgroundSecondaryFallback)
            .clipShape(RoundedRectangle(cornerRadius: HRTRadius.medium))
        }
    }
}

// MARK: - Preview

#Preview("Inputs") {
    ScrollView {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Text Fields")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)

                HRTTextField("Name", placeholder: "Enter medication name", text: .constant(""))

                HRTTextField(placeholder: "Without label", text: .constant("Some text"))
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 16) {
                Text("Metric Input")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)

                HRTMetricInput(value: .constant("165.5"), unit: "lbs")
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 16) {
                Text("Search Field")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)

                HRTSearchField(text: .constant(""))
                HRTSearchField(text: .constant("Furosemide"))
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 16) {
                Text("Picker Row")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)

                HRTPickerRow("Medication", value: "", placeholder: "Select medication")
                HRTPickerRow("Dosage", value: "40 mg")
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 16) {
                Text("Text Area")
                    .font(.hrtSectionLabel)
                    .foregroundStyle(Color.hrtTextSecondaryFallback)
                    .textCase(.uppercase)

                HRTTextArea("Notes", placeholder: "Add any notes...", text: .constant(""))
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(Color.hrtBackgroundFallback)
}
