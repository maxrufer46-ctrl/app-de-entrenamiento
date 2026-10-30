import CoreData
import Foundation

/// Owns one container and never destroys or silently replaces a store after an error.
final class CoreDataStack: PersistenceService {
    enum StoreLocation {
        case applicationSupport
        case sqlite(URL)
        case inMemory
    }

    private let location: StoreLocation
    private let modelProvider: () throws -> NSManagedObjectModel
    private var container: NSPersistentContainer?
    private var isLoading = false
    private var loadCompletions: [(Result<Void, Error>) -> Void] = []

    private(set) var isLoaded = false
    private(set) var storageDirectoryURL: URL?

    /// Read on the main queue, like the rest of the application lifecycle state.
    var hasUnsavedChanges: Bool {
        return container?.viewContext.hasChanges ?? false
    }

    init(
        location: StoreLocation = .applicationSupport,
        modelProvider: @escaping () throws -> NSManagedObjectModel = { try CoreDataStack.loadModel() }
    ) {
        self.location = location
        self.modelProvider = modelProvider
    }

    // MARK: - Model

    /// Uses the compiled, versioned model in the app bundle; no empty-model fallback.
    static func loadModel(in bundle: Bundle = .main) throws -> NSManagedObjectModel {
        guard let url = bundle.url(forResource: "FitTrack", withExtension: "momd"),
            let model = NSManagedObjectModel(contentsOf: url) else {
            throw PersistenceError.missingModel
        }
        return model
    }

    // MARK: - Opening

    func load(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            if self.isLoaded {
                completion(.success(()))
                return
            }

            self.loadCompletions.append(completion)
            guard !self.isLoading else { return }
            self.isLoading = true

            do {
                let model = try self.modelProvider()
                let description = try self.makeStoreDescription()
                let candidate = NSPersistentContainer(name: "FitTrack", managedObjectModel: model)
                candidate.persistentStoreDescriptions = [description]
                candidate.loadPersistentStores { _, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            self.finishOpening(.failure(error))
                            return
                        }

                        candidate.viewContext.name = "FitTrack.viewContext"
                        candidate.viewContext.undoManager = nil
                        candidate.viewContext.mergePolicy = NSErrorMergePolicy
                        candidate.viewContext.automaticallyMergesChangesFromParent = true
                        self.container = candidate
                        self.isLoaded = true
                        self.finishOpening(.success(()))
                    }
                }
            } catch {
                self.finishOpening(.failure(error))
            }
        }
    }

    private func makeStoreDescription() throws -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription()
        switch location {
        case .inMemory:
            description.type = NSInMemoryStoreType
            description.url = nil
        case .applicationSupport:
            guard let support = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first else {
                throw PersistenceError.missingApplicationSupport
            }
            let directory = support.appendingPathComponent("FitTrack", isDirectory: true)
            try configureSQLite(description, url: directory.appendingPathComponent("FitTrack.sqlite"))
        case .sqlite(let url):
            guard url.isFileURL else { throw PersistenceError.invalidStoreURL }
            try configureSQLite(description, url: url)
        }

        description.shouldAddStoreAsynchronously = true
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        return description
    }

    private func configureSQLite(_ description: NSPersistentStoreDescription, url: URL) throws {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        storageDirectoryURL = directory
        description.type = NSSQLiteStoreType
        description.url = url
    }

    private func finishOpening(_ result: Result<Void, Error>) {
        isLoading = false
        let completions = loadCompletions
        loadCompletions.removeAll()
        completions.forEach { $0(result) }
    }

    // MARK: - Contexts and saving

    /// Repositories request contexts on the main queue and use them only through `perform`.
    func makeBackgroundContext() throws -> NSManagedObjectContext {
        guard isLoaded, let container = container else { throw PersistenceError.notLoaded }
        let context = container.newBackgroundContext()
        context.name = "FitTrack.repositoryContext"
        context.undoManager = nil
        context.mergePolicy = NSErrorMergePolicy
        return context
    }

    func save(completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.main.async {
            guard self.isLoaded, let context = self.container?.viewContext else {
                completion(.failure(PersistenceError.notLoaded))
                return
            }

            context.perform {
                do {
                    if context.hasChanges { try context.save() }
                    completion(.success(()))
                } catch {
                    // Retain pending changes so the user can retry saving.
                    completion(.failure(error))
                }
            }
        }
    }
}
