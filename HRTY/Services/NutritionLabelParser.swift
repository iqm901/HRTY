import Foundation
import Vision
import UIKit

/// Result of parsing a nutrition label
struct NutritionLabelResult {
    let sodiumMg: Int
    let servingSize: String?
    let rawText: String
}

/// Protocol for nutrition label parsing
protocol NutritionLabelParserProtocol {
    func parseImage(_ image: UIImage) async -> NutritionLabelResult?
}

/// Service that uses Vision framework to extract sodium from nutrition labels
final class NutritionLabelParser: NutritionLabelParserProtocol {

    // MARK: - Regex Patterns

    /// Patterns to match sodium values in various formats
    private let sodiumPatterns: [NSRegularExpression] = {
        let patterns = [
            // "Sodium 480mg" or "Sodium: 480mg"
            #"[Ss]odium[:\s]*(\d{1,4})\s*mg"#,
            // "Sodium 480 mg" (with space)
            #"[Ss]odium[:\s]*(\d{1,4})\s+mg"#,
            // "Sodium: 1,200mg" (with comma)
            #"[Ss]odium[:\s]*(\d{1,3},\d{3})\s*mg"#,
            // "480mg Sodium"
            #"(\d{1,4})\s*mg\s+[Ss]odium"#,
            // Just numbers followed by mg near sodium text
            #"(\d{1,4})\s*mg"#
        ]

        return patterns.compactMap { pattern in
            try? NSRegularExpression(pattern: pattern, options: [])
        }
    }()

    /// Patterns to match serving size
    private let servingPatterns: [NSRegularExpression] = {
        let patterns = [
            #"[Ss]erving [Ss]ize[:\s]*([^\n]+)"#,
            #"[Ss]ervings?[:\s]*([^\n]+)"#
        ]

        return patterns.compactMap { pattern in
            try? NSRegularExpression(pattern: pattern, options: [])
        }
    }()

    // MARK: - Public Methods

    func parseImage(_ image: UIImage) async -> NutritionLabelResult? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: nil)
                    return
                }

                let recognizedText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                let result = self.parseText(recognizedText)
                continuation.resume(returning: result)
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                #if DEBUG
                print("NutritionLabelParser: Vision request failed - \(error.localizedDescription)")
                #endif
                continuation.resume(returning: nil)
            }
        }
    }

    // MARK: - Text Parsing

    func parseText(_ text: String) -> NutritionLabelResult? {
        guard let sodiumMg = extractSodium(from: text) else {
            return nil
        }

        let servingSize = extractServingSize(from: text)

        return NutritionLabelResult(
            sodiumMg: sodiumMg,
            servingSize: servingSize,
            rawText: text
        )
    }

    // MARK: - Private Methods

    private func extractSodium(from text: String) -> Int? {
        let normalizedText = text.lowercased()

        // First, try to find sodium-specific matches
        for pattern in sodiumPatterns.dropLast() {
            let range = NSRange(normalizedText.startIndex..., in: normalizedText)
            if let match = pattern.firstMatch(in: normalizedText, options: [], range: range) {
                if let valueRange = Range(match.range(at: 1), in: normalizedText) {
                    let valueString = String(normalizedText[valueRange])
                    return parseNumber(valueString)
                }
            }
        }

        // If no sodium-specific match, look for any mg value near "sodium" text
        if normalizedText.contains("sodium") {
            if let lastPattern = sodiumPatterns.last {
                let range = NSRange(normalizedText.startIndex..., in: normalizedText)
                if let match = lastPattern.firstMatch(in: normalizedText, options: [], range: range) {
                    if let valueRange = Range(match.range(at: 1), in: normalizedText) {
                        let valueString = String(normalizedText[valueRange])
                        return parseNumber(valueString)
                    }
                }
            }
        }

        return nil
    }

    private func extractServingSize(from text: String) -> String? {
        for pattern in servingPatterns {
            let range = NSRange(text.startIndex..., in: text)
            if let match = pattern.firstMatch(in: text, options: [], range: range) {
                if let valueRange = Range(match.range(at: 1), in: text) {
                    let servingString = String(text[valueRange])
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    if !servingString.isEmpty {
                        return servingString
                    }
                }
            }
        }
        return nil
    }

    private func parseNumber(_ string: String) -> Int? {
        // Remove commas and whitespace
        let cleaned = string.replacingOccurrences(of: ",", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Int(cleaned)
    }
}
