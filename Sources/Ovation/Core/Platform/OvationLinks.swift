import Foundation

/// The App Store and Mail links the sheet opens.
enum OvationLinks {

    // MARK: - Private Properties

    /// Query characters that stay readable in a `mailto:` subject. `&`, `=`, `+`, `?` and `#`
    /// are encoded so an app name can never break the query.
    private static let subjectAllowedCharacters: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed

        allowed.remove(charactersIn: "&=+?#")

        return allowed
    }()

    // MARK: - Public Methods

    /// The trimmed App Store ID when it has only ASCII digits.
    static func normalizedAppStoreID(_ appStoreID: String) -> String? {
        let trimmed = appStoreID.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty, trimmed.allSatisfy({ $0.isASCII && $0.isNumber }) else {
            return nil
        }

        return trimmed
    }

    /// The trimmed support email when it looks like an address.
    static func normalizedEmail(_ email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard trimmed.contains("@") else {
            return nil
        }

        return trimmed
    }

    /// `https://apps.apple.com/app/id<ID>?action=write-review`, Apple's persistent link to
    /// write a review.
    static func writeReviewURL(appStoreID: String) -> URL? {
        guard let appStoreID = normalizedAppStoreID(appStoreID) else {
            return nil
        }

        var components = URLComponents()

        components.scheme = "https"
        components.host = "apps.apple.com"
        components.path = "/app/id\(appStoreID)"
        components.queryItems = [URLQueryItem(name: "action", value: "write-review")]

        return components.url
    }

    /// A `mailto:` link to `email` with the encoded `subject`.
    static func feedbackURL(email: String, subject: String) -> URL? {
        guard let email = normalizedEmail(email) else {
            return nil
        }

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: subjectAllowedCharacters) ?? ""

        var components = URLComponents()

        components.scheme = "mailto"
        components.path = email
        components.percentEncodedQuery = "subject=\(encodedSubject)"

        return components.url
    }
}
