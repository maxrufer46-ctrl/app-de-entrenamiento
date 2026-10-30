import CoreData
import XCTest
@testable import FitTrack

final class ProfileRepositoryTests: XCTestCase {
    func testEmptyStoreHasNoProfile() throws {
        let repository = CoreDataProfileRepository(stack: try openedMemoryStack())
        let profile = try waitForResult { repository.loadProfile(completion: $0) }.get()
        XCTAssertNil(profile)
    }

    func testUpdatingProfilePreservesIdentityAndCreationDate() throws {
        let stack = try openedMemoryStack()
        var timestamp = Date(timeIntervalSince1970: 1_600_000_000)
        let repository = CoreDataProfileRepository(stack: stack, now: { timestamp })
        let first = try waitForResult { repository.saveDisplayName("  Alex  ", completion: $0) }.get()
        timestamp = timestamp.addingTimeInterval(60)
        let second = try waitForResult { repository.saveDisplayName("Alejandra", completion: $0) }.get()
        XCTAssertEqual(first.displayName, "Alex")
        XCTAssertEqual(first.id, second.id)
        XCTAssertEqual(first.createdAt, second.createdAt)
        XCTAssertGreaterThan(second.updatedAt, first.updatedAt)
        let count = try perform(in: stack) { context in
            return try context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "ProfileEntity"))
        }
        XCTAssertEqual(count, 1)
    }

    func testInvalidUpdateLeavesSavedProfileUnchanged() throws {
        let repository = CoreDataProfileRepository(stack: try openedMemoryStack())
        let saved = try waitForResult { repository.saveDisplayName("Ada", completion: $0) }.get()
        let failed: Result<LocalProfile, Error> = try waitForResult { repository.saveDisplayName(" ", completion: $0) }
        XCTAssertThrowsError(try failed.get())
        let reloaded = try waitForResult { repository.loadProfile(completion: $0) }.get()
        XCTAssertEqual(reloaded, saved)
    }

    func testSQLiteProfileCanBeReadByANewStack() throws {
        let url = try temporaryDirectory().appendingPathComponent("FitTrack.sqlite")
        let first = CoreDataStack(location: .sqlite(url))
        try waitForResult { first.load(completion: $0) }.get()
        let writer = CoreDataProfileRepository(stack: first)
        let saved = try waitForResult { writer.saveDisplayName("María", completion: $0) }.get()
        let second = CoreDataStack(location: .sqlite(url))
        try waitForResult { second.load(completion: $0) }.get()
        let reader = CoreDataProfileRepository(stack: second)
        let reloaded = try waitForResult { reader.loadProfile(completion: $0) }.get()
        XCTAssertEqual(reloaded, saved)
    }
}
