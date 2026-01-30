import Foundation
import SwiftData

/// Product information from barcode lookup
struct ProductInfo: Codable, Equatable {
    let barcode: String
    let name: String
    let sodiumMg: Int
    let servingSize: String?
    let brand: String?
}

/// Protocol defining local product database operations
protocol LocalProductDatabaseProtocol {
    func findProduct(barcode: String, context: ModelContext) -> ProductInfo?
    func saveCustomProduct(_ product: ProductInfo, context: ModelContext) -> Bool
}

/// Local product database that caches scanned products for offline reuse
final class LocalProductDatabase: LocalProductDatabaseProtocol {

    /// Find a product by barcode
    /// First checks saved templates, then could be extended to check a local database
    func findProduct(barcode: String, context: ModelContext) -> ProductInfo? {
        // Check if we have a template with this barcode
        if let template = SodiumTemplate.findByBarcode(barcode, in: context) {
            return ProductInfo(
                barcode: barcode,
                name: template.name,
                sodiumMg: template.sodiumMg,
                servingSize: template.servingSize,
                brand: nil
            )
        }

        // Future: Could check a bundled product database here
        // For now, return nil and let user add manually
        return nil
    }

    /// Save a custom product as a template for future lookups
    @discardableResult
    func saveCustomProduct(_ product: ProductInfo, context: ModelContext) -> Bool {
        let template = SodiumTemplate(
            name: product.name,
            sodiumMg: product.sodiumMg,
            servingSize: product.servingSize,
            category: .other,
            barcode: product.barcode
        )

        context.insert(template)

        do {
            try context.save()
            return true
        } catch {
            #if DEBUG
            print("LocalProductDatabase: Failed to save custom product - \(error.localizedDescription)")
            #endif
            return false
        }
    }
}
