import CoreData
import Foundation

/// The phase-1 vertical slice: validates, saves and reloads a single local profile.
final class CoreDataProfileRepository: ProfileRepository {
    private let stack: CoreDataStack
    private let now: () -> Date

    init(stack: CoreDataStack, now: @escaping () -> Date = Date.init) {
        self.stack = stack
        self.now = now
    }

    func loadProfile(completion: @escaping (Result<LocalProfile?, Error>) -> Void) {
        withContext(completion: completion) { context in
            guard let object = try self.fetchProfile(in: context) else { return nil }
            return try self.snapshot(of: object)
        }
    }

    func saveDisplayName(_ name: String, completion: @escaping (Result<LocalProfile, Error>) -> Void) {
        withContext(completion: completion) { context in
            let validatedName = try LocalProfile.validatedDisplayName(name)
            let timestamp = self.now()
            let object: NSManagedObject
            if let existing = try self.fetchProfile(in: context) {
                object = existing
            } else {
                object = NSEntityDescription.insertNewObject(forEntityName: "ProfileEntity", into: context)
                object.setValue(UUID(), forKey: "id")
                object.setValue(timestamp, forKey: "createdAt")
                object.setValue("local", forKey: "scopeKey")
            }

            object.setValue(validatedName, forKey: "displayName")
            object.setValue(timestamp, forKey: "updatedAt")
            let profile = try self.snapshot(of: object)
            try context.save()
            return profile
        }
    }

    // MARK: - Mapping and confinement

    private func fetchProfile(in context: NSManagedObjectContext) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "ProfileEntity")
        request.predicate = NSPredicate(format: "scopeKey == %@", "local")
        request.fetchLimit = 2
        let objects = try context.fetch(request)
        guard objects.count <= 1 else { throw PersistenceError.multipleProfiles }
        return objects.first
    }

    private func snapshot(of object: NSManagedObject) throws -> LocalProfile {
        guard let id = object.value(forKey: "id") as? UUID,
            let name = object.value(forKey: "displayName") as? String,
            let createdAt = object.value(forKey: "createdAt") as? Date,
            let updatedAt = object.value(forKey: "updatedAt") as? Date else {
            throw PersistenceError.invalidProfile
        }
        let validatedName = try LocalProfile.validatedDisplayName(name)
        return LocalProfile(id: id, displayName: validatedName, createdAt: createdAt, updatedAt: updatedAt)
    }

    private func withContext<Value>(
        completion: @escaping (Result<Value, Error>) -> Void,
        operation: @escaping (NSManagedObjectContext) throws -> Value
    ) {
        DispatchQueue.main.async {
            do {
                let context = try self.stack.makeBackgroundContext()
                context.perform {
                    let result: Result<Value, Error>
                    do {
                        result = .success(try operation(context))
                    } catch {
                        context.rollback()
                        result = .failure(error)
                    }
                    DispatchQueue.main.async { completion(result) }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
