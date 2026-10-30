import CoreData
import XCTest
@testable import FitTrack

final class CoreDataStackTests: XCTestCase {
    func testCompiledModelContainsAllPlannedEntities() throws {
        let model = try CoreDataStack.loadModel()
        XCTAssertEqual(model.entities.count, 16)
        XCTAssertNotNil(model.entitiesByName["WorkoutSessionEntity"])
        XCTAssertNotNil(model.entitiesByName["ProfileEntity"])
        for entity in model.entities {
            XCTAssertNotNil(entity.attributesByName["id"])
            let keys = entity.uniquenessConstraints.compactMap { $0 as? [String] }
            XCTAssertTrue(keys.contains(["id"]), "Missing UUID uniqueness on \(entity.name ?? "unknown")")
            for relation in entity.relationshipsByName.values {
                XCTAssertNotNil(relation.inverseRelationship)
                XCTAssertTrue(relation.inverseRelationship?.inverseRelationship === relation)
            }
        }
    }

    func testConcurrentOpeningCallsUseOneContainerAttempt() {
        var modelRequests = 0
        let stack = CoreDataStack(location: .inMemory) {
            modelRequests += 1
            return try CoreDataStack.loadModel()
        }
        let completed = expectation(description: "All opening callers complete")
        completed.expectedFulfillmentCount = 3
        for _ in 0..<3 {
            stack.load { result in
                XCTAssertTrue(Thread.isMainThread)
                XCTAssertNoThrow(try result.get())
                completed.fulfill()
            }
        }
        wait(for: [completed], timeout: 8)
        XCTAssertEqual(modelRequests, 1)
        XCTAssertTrue(stack.isLoaded)
    }

    func testFailedModelLoadCanBeRetried() throws {
        var attempts = 0
        let stack = CoreDataStack(location: .inMemory) {
            attempts += 1
            if attempts == 1 { throw TestFailure.opening }
            return try CoreDataStack.loadModel()
        }
        let failed: Result<Void, Error> = try waitForResult { stack.load(completion: $0) }
        XCTAssertThrowsError(try failed.get())
        XCTAssertFalse(stack.isLoaded)
        try waitForResult { stack.load(completion: $0) }.get()
        XCTAssertTrue(stack.isLoaded)
        XCTAssertEqual(attempts, 2)
    }

    func testSaveBeforeOpeningFailsRatherThanPretendingSuccess() throws {
        let stack = CoreDataStack(location: .inMemory)
        let result: Result<Void, Error> = try waitForResult { stack.save(completion: $0) }
        XCTAssertThrowsError(try result.get())
        XCTAssertThrowsError(try stack.makeBackgroundContext())
    }

    func testExistingFileIsNotDeletedWhenParentIsInvalid() throws {
        let directory = try temporaryDirectory()
        let blocker = directory.appendingPathComponent("blocked")
        let original = Data("Keep this file".utf8)
        try original.write(to: blocker)
        let stack = CoreDataStack(location: .sqlite(blocker.appendingPathComponent("FitTrack.sqlite")))
        let result: Result<Void, Error> = try waitForResult { stack.load(completion: $0) }
        XCTAssertThrowsError(try result.get())
        XCTAssertEqual(try Data(contentsOf: blocker), original)
        XCTAssertFalse(stack.isLoaded)
    }

    func testCorruptSQLiteIsNotReplacedByAnEmptyStore() throws {
        let url = try temporaryDirectory().appendingPathComponent("FitTrack.sqlite")
        let original = Data("This is not a SQLite database".utf8)
        try original.write(to: url)
        let stack = CoreDataStack(location: .sqlite(url))
        let result: Result<Void, Error> = try waitForResult { stack.load(completion: $0) }
        XCTAssertThrowsError(try result.get())
        XCTAssertEqual(try Data(contentsOf: url), original)
        XCTAssertFalse(stack.isLoaded)
    }

    func testBackgroundContextUsesPrivateQueue() throws {
        let stack = try openedMemoryStack()
        let context = try stack.makeBackgroundContext()
        XCTAssertEqual(context.concurrencyType, .privateQueueConcurrencyType)
    }
}
