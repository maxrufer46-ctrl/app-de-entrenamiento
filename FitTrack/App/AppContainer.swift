import Foundation

/// The app delegate retains this composition root for the entire process lifetime.
final class AppContainer {
    let persistence: CoreDataStack
    let bootstrapViewModel: BootstrapViewModel

    init(configuration: LaunchConfiguration) {
        var shouldSimulateFailure = configuration.simulateFirstOpeningFailure
        let persistence = CoreDataStack(location: configuration.storeLocation) {
            if shouldSimulateFailure {
                shouldSimulateFailure = false
                throw PersistenceError.simulatedOpeningFailure
            }
            return try CoreDataStack.loadModel()
        }
        self.persistence = persistence
        let repository = CoreDataProfileRepository(stack: persistence)
        self.bootstrapViewModel = BootstrapViewModel(persistence: persistence, profiles: repository)
    }

    var hasPendingChanges: Bool {
        return bootstrapViewModel.hasUnsavedChanges || bootstrapViewModel.isSaving || persistence.hasUnsavedChanges
    }

    func prepareToClose(completion: @escaping (Result<Void, Error>) -> Void) {
        bootstrapViewModel.saveIfNeeded { result in
            switch result {
            case .failure:
                completion(result)
            case .success:
                guard self.persistence.isLoaded else {
                    completion(.success(()))
                    return
                }
                self.persistence.save(completion: completion)
            }
        }
    }
}
