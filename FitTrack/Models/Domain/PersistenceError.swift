import Foundation

enum PersistenceError: LocalizedError {
    case missingModel
    case missingApplicationSupport
    case invalidStoreURL
    case notLoaded
    case invalidProfile
    case multipleProfiles
    case simulatedOpeningFailure

    var errorDescription: String? {
        switch self {
        case .missingModel:
            return NSLocalizedString("error.store.model", comment: "Storage error")
        case .missingApplicationSupport, .invalidStoreURL:
            return NSLocalizedString("error.store.location", comment: "Storage error")
        case .notLoaded:
            return NSLocalizedString("error.store.notReady", comment: "Storage error")
        case .invalidProfile, .multipleProfiles:
            return NSLocalizedString("error.store.profile", comment: "Storage error")
        case .simulatedOpeningFailure:
            return NSLocalizedString("error.store.testFailure", comment: "Debug-only test failure")
        }
    }
}
