import Combine
import Foundation

/// Owns the initial screen's state; storage and managed objects never enter a View.
final class BootstrapViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case ready
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var isSaving = false
    @Published private(set) var saveErrorMessage: String?
    @Published private(set) var statusMessage: String?
    @Published var displayName = "" {
        didSet {
            statusMessage = nil
            saveErrorMessage = nil
        }
    }

    private let persistence: PersistenceService
    private let profiles: ProfileRepository
    private var savedProfile: LocalProfile?
    private var saveCompletions: [(Result<Void, Error>) -> Void] = []

    init(persistence: PersistenceService, profiles: ProfileRepository) {
        self.persistence = persistence
        self.profiles = profiles
    }

    var hasUnsavedChanges: Bool {
        return state == .ready && displayName != (savedProfile?.displayName ?? "")
    }

    var canRevealStorageDirectory: Bool {
        return persistence.storageDirectoryURL != nil
    }

    var validationMessage: String? {
        guard !displayName.isEmpty || savedProfile != nil else { return nil }
        do {
            _ = try LocalProfile.validatedDisplayName(displayName)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    var canSave: Bool {
        return state == .ready && !isSaving && hasUnsavedChanges && validationMessage == nil
            && !displayName.isEmpty
    }

    // MARK: - Opening and retry

    func start() {
        switch state {
        case .loading, .ready:
            return
        case .idle, .failed:
            break
        }
        state = .loading
        persistence.load { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.state = .failed(error.localizedDescription)
                case .success:
                    self.loadProfile()
                }
            }
        }
    }

    private func loadProfile() {
        profiles.loadProfile { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.state = .failed(error.localizedDescription)
                case .success(let profile):
                    self.savedProfile = profile
                    self.displayName = profile?.displayName ?? ""
                    self.state = .ready
                }
            }
        }
    }

    // MARK: - Saving

    func save(completion: ((Result<Void, Error>) -> Void)? = nil) {
        guard state == .ready else {
            completion?(.failure(PersistenceError.notLoaded))
            return
        }
        if let completion = completion { saveCompletions.append(completion) }
        guard !isSaving else { return }

        do {
            _ = try LocalProfile.validatedDisplayName(displayName)
        } catch {
            saveErrorMessage = error.localizedDescription
            finishSaving(.failure(error))
            return
        }

        guard hasUnsavedChanges else {
            finishSaving(.success(()))
            return
        }
        let submittedName = displayName
        isSaving = true
        saveErrorMessage = nil
        statusMessage = nil

        profiles.saveDisplayName(submittedName) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .failure(let error):
                    self.saveErrorMessage = error.localizedDescription
                    self.finishSaving(.failure(error))
                case .success(let profile):
                    self.savedProfile = profile
                    if self.displayName == submittedName { self.displayName = profile.displayName }
                    if !self.hasUnsavedChanges {
                        self.statusMessage = NSLocalizedString("profile.saved", comment: "Save confirmation")
                    }
                    self.finishSaving(.success(()))
                }
            }
        }
    }

    /// Waits for an in-flight save and includes any newer draft before allowing quit.
    func saveIfNeeded(completion: @escaping (Result<Void, Error>) -> Void) {
        guard isSaving || hasUnsavedChanges else {
            completion(.success(()))
            return
        }
        save { result in
            switch result {
            case .failure:
                completion(result)
            case .success:
                if self.hasUnsavedChanges {
                    self.saveIfNeeded(completion: completion)
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    private func finishSaving(_ result: Result<Void, Error>) {
        isSaving = false
        let completions = saveCompletions
        saveCompletions.removeAll()
        completions.forEach { $0(result) }
    }
}
