import XCTest
@testable import HRTY

final class TabTests: XCTestCase {

    func testTabCasesExist() {
        // Verify all five tabs are defined
        let tabs: [Tab] = [.today, .trends, .medications, .export, .settings]
        XCTAssertEqual(tabs.count, 5, "Should have exactly 5 tabs")
    }

    func testTabHashable() {
        // Verify Tab conforms to Hashable for use in TabView selection
        let tab1 = Tab.today
        let tab2 = Tab.today
        let tab3 = Tab.trends

        XCTAssertEqual(tab1, tab2, "Same tab cases should be equal")
        XCTAssertNotEqual(tab1, tab3, "Different tab cases should not be equal")
    }

    func testTabCanBeUsedInSet() {
        // Verify tabs can be stored in a Set (requires Hashable)
        let tabSet: Set<Tab> = [.today, .trends, .medications, .export, .settings]
        XCTAssertEqual(tabSet.count, 5, "Set should contain all 5 unique tabs")
    }

    func testTabCanBeUsedAsDictionaryKey() {
        // Verify tabs can be used as dictionary keys (requires Hashable)
        var tabNames: [Tab: String] = [:]
        tabNames[.today] = "Today"
        tabNames[.trends] = "Trends"
        tabNames[.medications] = "Medications"
        tabNames[.export] = "Export"
        tabNames[.settings] = "Settings"

        XCTAssertEqual(tabNames[.today], "Today")
        XCTAssertEqual(tabNames[.settings], "Settings")
    }
}
