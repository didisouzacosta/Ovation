import Foundation

extension String {

    // MARK: - Internal Properties

    /// The trimmed string, or `nil` when it is empty or only whitespace.
    var ovationNonBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)

        return trimmed.isEmpty ? nil : trimmed
    }
}
