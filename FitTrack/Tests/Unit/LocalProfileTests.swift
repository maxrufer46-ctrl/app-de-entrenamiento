import XCTest
@testable import FitTrack

final class LocalProfileTests: XCTestCase {
    func testTrimsOuterWhitespaceWithoutRemovingAccents() throws {
        XCTAssertEqual(try LocalProfile.validatedDisplayName("  María José \n"), "María José")
    }

    func testRejectsEmptyAndWhitespaceOnlyNames() {
        for name in ["", "  ", "\n\t"] {
            XCTAssertThrowsError(try LocalProfile.validatedDisplayName(name))
        }
    }

    func testRejectsNamesLongerThanLimit() {
        XCTAssertThrowsError(try LocalProfile.validatedDisplayName(String(repeating: "a", count: 81)))
    }

    func testAcceptsNameAtLimit() throws {
        let name = String(repeating: "a", count: 80)
        XCTAssertEqual(try LocalProfile.validatedDisplayName(name), name)
    }

    func testRejectsEmbeddedControlCharacters() {
        for name in ["Ana\nMaría", "Ana\tMaría", "Ana\u{0000}"] {
            XCTAssertThrowsError(try LocalProfile.validatedDisplayName(name))
        }
    }

    func testCountsUserPerceivedCharacters() throws {
        let name = String(repeating: "🏋🏽", count: 80)
        XCTAssertEqual(try LocalProfile.validatedDisplayName(name), name)
    }
}
