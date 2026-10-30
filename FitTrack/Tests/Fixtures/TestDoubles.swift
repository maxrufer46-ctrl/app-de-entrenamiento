import Foundation
@testable import FitTrack

enum TestFailure: Error {
    case opening
    case reading
    case saving
}

final class StubPersistenceService: PersistenceService {
    var isLoaded = false
    var hasUnsavedChanges = false
    var storageDirectoryURL: URL?
    var loadResult: Result<Void, Error> = .success(())
    var saveResult: Result<Void, Error> = .success(())
    private(set) var loadCount = 0
    private(set) var saveCount = 0

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        loadCount += 1
        let result = loadResult
        DispatchQueue.main.async {
            if case .success = result { self.isLoaded = true }
            completion(result)
        }
    }

    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        saveCount += 1
        DispatchQueue.main.async { completion(self.saveResult) }
    }
}

final class StubProfileRepository: ProfileRepository {
    var profile: LocalProfile?
    var loadError: Error?
    var saveError: Error?
    var holdSaves = false
    private(set) var saveCount = 0
    private var pending: [(String, (Result<LocalProfile, Error>) -> Void)] = []

    func loadProfile(completion: @escaping (Result<LocalProfile?, Error>) -> Void) {
        DispatchQueue.main.async {
            if let error = self.loadError {
                completion(.failure(error))
            } else {
                completion(.success(self.profile))
            }
        }
    }

    func saveDisplayName(_ name: String, completion: @escaping (Result<LocalProfile, Error>) -> Void) {
        saveCount += 1
        if holdSaves {
            pending.append((name, completion))
        } else {
            complete(name: name, completion: completion)
        }
    }

    @discardableResult
    func finishNextSave() -> Bool {
        guard !pending.isEmpty else { return false }
        let next = pending.removeFirst()
        complete(name: next.0, completion: next.1)
        return true
    }

    private func complete(name: String, completion: @escaping (Result<LocalProfile, Error>) -> Void) {
        DispatchQueue.main.async {
            if let error = self.saveError {
                completion(.failure(error))
                return
            }
            let date = Date(timeIntervalSince1970: 1_600_000_000)
            let profile = LocalProfile(
                id: self.profile?.id ?? UUID(),
                displayName: name.trimmingCharacters(in: .whitespacesAndNewlines),
                createdAt: self.profile?.createdAt ?? date,
                updatedAt: date
            )
            self.profile = profile
            completion(.success(profile))
        }
    }
}
