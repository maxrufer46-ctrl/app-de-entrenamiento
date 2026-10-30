import Foundation
import XCTest
@testable import FitTrack

final class BootstrapViewModelTests: XCTestCase {
    func testFirstLaunchIsReadyWithoutInventingAProfile() {
        let persistence = StubPersistenceService()
        let profiles = StubProfileRepository()
        let model = BootstrapViewModel(persistence: persistence, profiles: profiles)
        startAndWait(model)
        XCTAssertEqual(model.state, .ready)
        XCTAssertEqual(model.displayName, "")
        XCTAssertFalse(model.hasUnsavedChanges)
        XCTAssertFalse(model.canSave)
        XCTAssertEqual(profiles.saveCount, 0)
    }

    func testOpeningCanBeRetriedAfterFailure() {
        let persistence = StubPersistenceService()
        persistence.loadResult = .failure(TestFailure.opening)
        let model = BootstrapViewModel(persistence: persistence, profiles: StubProfileRepository())
        startAndWait(model)
        guard case .failed = model.state else { return XCTFail("Expected recoverable opening error") }
        persistence.loadResult = .success(())
        startAndWait(model)
        XCTAssertEqual(model.state, .ready)
        XCTAssertEqual(persistence.loadCount, 2)
    }

    func testReadFailureDoesNotOverwriteStoredProfile() {
        let persistence = StubPersistenceService()
        let profiles = StubProfileRepository()
        profiles.loadError = TestFailure.reading
        let model = BootstrapViewModel(persistence: persistence, profiles: profiles)
        startAndWait(model)
        guard case .failed = model.state else { return XCTFail("Expected reading error") }
        XCTAssertEqual(profiles.saveCount, 0)
        XCTAssertFalse(model.canSave)
    }

    func testInvalidDraftCannotBeSaved() throws {
        let profiles = StubProfileRepository()
        let model = BootstrapViewModel(persistence: StubPersistenceService(), profiles: profiles)
        startAndWait(model)
        model.displayName = "  "
        XCTAssertFalse(model.canSave)
        XCTAssertNotNil(model.validationMessage)
        let result: Result<Void, Error> = try waitForResult { model.save(completion: $0) }
        XCTAssertThrowsError(try result.get())
        XCTAssertEqual(profiles.saveCount, 0)
    }

    func testSaveNormalizesNameOnlyAfterSuccess() throws {
        let profiles = StubProfileRepository()
        let model = BootstrapViewModel(persistence: StubPersistenceService(), profiles: profiles)
        startAndWait(model)
        model.displayName = "  Lucía  "
        XCTAssertTrue(model.canSave)
        try waitForResult { model.save(completion: $0) }.get()
        XCTAssertEqual(model.displayName, "Lucía")
        XCTAssertEqual(profiles.profile?.displayName, "Lucía")
        XCTAssertFalse(model.hasUnsavedChanges)
        XCTAssertFalse(model.isSaving)
        XCTAssertNotNil(model.statusMessage)
    }

    func testFailedSaveKeepsDraftAndAllowsRetry() throws {
        let profiles = StubProfileRepository()
        profiles.saveError = TestFailure.saving
        let model = BootstrapViewModel(persistence: StubPersistenceService(), profiles: profiles)
        startAndWait(model)
        model.displayName = "Nora"
        let result: Result<Void, Error> = try waitForResult { model.save(completion: $0) }
        XCTAssertThrowsError(try result.get())
        XCTAssertEqual(model.displayName, "Nora")
        XCTAssertTrue(model.hasUnsavedChanges)
        XCTAssertNotNil(model.saveErrorMessage)
        XCTAssertNil(profiles.profile)
        profiles.saveError = nil
        try waitForResult { model.save(completion: $0) }.get()
        XCTAssertFalse(model.hasUnsavedChanges)
        XCTAssertNil(model.saveErrorMessage)
    }

    func testConcurrentSaveRequestsShareOneWrite() {
        let profiles = StubProfileRepository()
        profiles.holdSaves = true
        let model = BootstrapViewModel(persistence: StubPersistenceService(), profiles: profiles)
        startAndWait(model)
        model.displayName = "Leo"
        let first = expectation(description: "First save caller")
        let second = expectation(description: "Second save caller")
        model.save { result in
            XCTAssertNoThrow(try result.get())
            first.fulfill()
        }
        model.save { result in
            XCTAssertNoThrow(try result.get())
            second.fulfill()
        }
        XCTAssertTrue(model.isSaving)
        XCTAssertEqual(profiles.saveCount, 1)
        XCTAssertTrue(profiles.finishNextSave())
        wait(for: [first, second], timeout: 5)
        XCTAssertFalse(model.hasUnsavedChanges)
    }

    func testDraftEditedDuringSaveIsNotLost() {
        let profiles = StubProfileRepository()
        profiles.holdSaves = true
        let model = BootstrapViewModel(persistence: StubPersistenceService(), profiles: profiles)
        startAndWait(model)
        model.displayName = "First"
        let finished = expectation(description: "Save original draft")
        model.save { _ in finished.fulfill() }
        model.displayName = "Newer"
        XCTAssertTrue(profiles.finishNextSave())
        wait(for: [finished], timeout: 5)
        XCTAssertEqual(model.displayName, "Newer")
        XCTAssertTrue(model.hasUnsavedChanges)
        XCTAssertNil(model.statusMessage)
    }

    func testClosingSavesPendingDraft() throws {
        let profiles = StubProfileRepository()
        let model = BootstrapViewModel(persistence: StubPersistenceService(), profiles: profiles)
        startAndWait(model)
        model.displayName = "Noa"
        try waitForResult { model.saveIfNeeded(completion: $0) }.get()
        XCTAssertEqual(profiles.profile?.displayName, "Noa")
        XCTAssertFalse(model.hasUnsavedChanges)
    }

    func testClosingUntouchedProfileDoesNotWrite() throws {
        let profiles = StubProfileRepository()
        let model = BootstrapViewModel(persistence: StubPersistenceService(), profiles: profiles)
        startAndWait(model)
        try waitForResult { model.saveIfNeeded(completion: $0) }.get()
        XCTAssertEqual(profiles.saveCount, 0)
    }

    func testClosingWaitsForSaveAndIncludesNewerDraft() {
        let profiles = StubProfileRepository()
        profiles.holdSaves = true
        let model = BootstrapViewModel(persistence: StubPersistenceService(), profiles: profiles)
        startAndWait(model)
        model.displayName = "First"
        model.save()
        model.displayName = "Latest"
        let finished = expectation(description: "Quit waits for the latest draft")
        model.saveIfNeeded { result in
            XCTAssertNoThrow(try result.get())
            finished.fulfill()
        }
        profiles.holdSaves = false
        XCTAssertTrue(profiles.finishNextSave())
        wait(for: [finished], timeout: 5)
        XCTAssertEqual(profiles.profile?.displayName, "Latest")
        XCTAssertEqual(profiles.saveCount, 2)
        XCTAssertFalse(model.hasUnsavedChanges)
    }
}
