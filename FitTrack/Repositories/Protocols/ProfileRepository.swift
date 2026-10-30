import Foundation

/// Completions are delivered on the main queue. Implementations must save before succeeding.
protocol ProfileRepository: AnyObject {
    func loadProfile(completion: @escaping (Result<LocalProfile?, Error>) -> Void)
    func saveDisplayName(_ name: String, completion: @escaping (Result<LocalProfile, Error>) -> Void)
}
