import SwiftUI

/// A flexible date picker with three wheels for month, day, and year
/// Each component is optional, allowing users to enter partial dates
struct FlexibleDatePicker: View {
    @Binding var year: Int?
    @Binding var month: Int?
    @Binding var day: Int?

    private let startYear = 1950
    private let currentYear = Calendar.current.component(.year, from: Date())

    private let months = [
        (1, "Jan"), (2, "Feb"), (3, "Mar"), (4, "Apr"),
        (5, "May"), (6, "Jun"), (7, "Jul"), (8, "Aug"),
        (9, "Sep"), (10, "Oct"), (11, "Nov"), (12, "Dec")
    ]

    var body: some View {
        HStack(spacing: 0) {
            // Month picker
            Picker("Month", selection: $month) {
                Text("---").tag(nil as Int?)
                ForEach(months, id: \.0) { value, name in
                    Text(name).tag(value as Int?)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
            .clipped()

            // Day picker
            Picker("Day", selection: $day) {
                Text("---").tag(nil as Int?)
                ForEach(1...31, id: \.self) { dayNum in
                    Text("\(dayNum)").tag(dayNum as Int?)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 60)
            .clipped()

            // Year picker
            Picker("Year", selection: $year) {
                ForEach((startYear...currentYear).reversed(), id: \.self) { yearNum in
                    Text(String(yearNum)).tag(yearNum as Int?)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 90)
            .clipped()
        }
        .frame(height: 150)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var year: Int? = 2024
        @State private var month: Int? = 3
        @State private var day: Int? = 15

        var body: some View {
            VStack(spacing: 20) {
                FlexibleDatePicker(year: $year, month: $month, day: $day)

                Text("Selected: \(formatDate())")
            }
            .padding()
        }

        private func formatDate() -> String {
            var parts: [String] = []
            if let m = month { parts.append("Month: \(m)") }
            if let d = day { parts.append("Day: \(d)") }
            if let y = year { parts.append("Year: \(y)") }
            return parts.isEmpty ? "None" : parts.joined(separator: ", ")
        }
    }

    return PreviewWrapper()
}
