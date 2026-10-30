import Foundation

/// A value snapshot of the local profile. Managed objects stay inside repositories.
struct LocalProfile: Equatable {
    let id: UUID
    let displayName: String
    let createdAt: Date
    let updatedAt: Date

    static let maximumNameLength = 80

    /// Validates user input independently of the presentation layer.
    static func validatedDisplayName(_ input: String) throws -> String {
        let name = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw ProfileValidationError.emptyName }
        guard name.count <= maximumNameLength else { throw ProfileValidationError.nameTooLong }
        guard name.rangeOfCharacter(from: .controlCharacters) == nil else {
            throw ProfileValidationError.controlCharacters
        }
        return name
    }
}

enum ProfileValidationError: LocalizedError {
    case emptyName
    case nameTooLong
    case controlCharacters

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return NSLocalizedString("error.name.empty", comment: "Name validation")
        case .nameTooLong:
            return NSLocalizedString("error.name.tooLong", comment: "Name validation")
        case .controlCharacters:
            return NSLocalizedString("error.name.controlCharacters", comment: "Name validation")
        }
    }
}
