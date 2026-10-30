import Foundation

/// Coordinates storage lifecycle without exposing Core Data to ViewModels.
protocol PersistenceService: AnyObject {
    var isLoaded: Bool { get }
    var hasUnsavedChanges: Bool { get }
    var storageDirectoryURL: URL? { get }

    /// Safe to call repeatedly; concurrent loads share one opening attempt.
    func load(completion: @escaping (Result<Void, Error>) -> Void)
    func save(completion: @escaping (Result<Void, Error>) -> Void)
}
