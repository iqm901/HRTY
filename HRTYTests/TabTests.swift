import XCTest
@testable import HRTY

final class TabTests: XCTestCase {

    func testTabCasesExist() {
        // Verify all seven tabs are defined using CaseIterable
        XCTAssertEqual(Tab.allCases.count, 7, "Should have exactly 7 tabs")
        XCTAssertTrue(Tab.allCases.contains(.today))
        XCTAssertTrue(Tab.allCases.contains(.trends))
        XCTAssertTrue(Tab.allCases.contains(.medications))
        XCTAssertTrue(Tab.allCases.contains(.myHeart))
        XCTAssertTrue(Tab.allCases.contains(.learn))
        XCTAssertTrue(Tab.allCases.contains(.export))
        XCTAssertTrue(Tab.allCases.contains(.settings))
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
        let tabSet = Set(Tab.allCases)
        XCTAssertEqual(tabSet.count, Tab.allCases.count, "Set should contain all unique tabs")
    }

    func testTabCanBeUsedAsDictionaryKey() {
        // Verify tabs can be used as dictionary keys (requires Hashable)
        var tabNames: [Tab: String] = [:]
        tabNames[.today] = "Today"
        tabNames[.trends] = "Trends"
        tabNames[.medications] = "Medications"
        tabNames[.myHeart] = "My Heart"
        tabNames[.learn] = "Learn"
        tabNames[.export] = "Export"
        tabNames[.settings] = "Settings"

        XCTAssertEqual(tabNames[.today], "Today")
        XCTAssertEqual(tabNames[.myHeart], "My Heart")
        XCTAssertEqual(tabNames[.settings], "Settings")
    }
}
