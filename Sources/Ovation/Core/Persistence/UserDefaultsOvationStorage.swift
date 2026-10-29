import Foundation

/// Stores Ovation's state in `UserDefaults` under `<namespace>.Ovation.*`. The keys are part of
/// the public contract: renaming one resets every user's state.
@MainActor
final class UserDefaultsOvationStorage: OvationStorage {

    // MARK: - Private Properties

    private let defaults: UserDefaults
    private let hasReviewedKey: String
    private let triggerCountKey: String
    private let presentationCountKey: String
    private let lastPresentationDateKey: String

    // MARK: - OvationStorage

    var hasReviewed: Bool {
        get {
            defaults.bool(forKey: hasReviewedKey)
        }

        set {
            defaults.set(newValue, forKey: hasReviewedKey)
        }
    }

    var triggerCount: Int {
        get {
            defaults.integer(forKey: triggerCountKey)
        }

        set {
            defaults.set(newValue, forKey: triggerCountKey)
        }
    }

    var presentationCount: Int {
        get {
            defaults.integer(forKey: presentationCountKey)
        }

        set {
            defaults.set(newValue, forKey: presentationCountKey)
        }
    }

    var lastPresentationDate: Date? {
        get {
            defaults.object(forKey: lastPresentationDateKey) as? Date
        }

        set {
            defaults.set(newValue, forKey: lastPresentationDateKey)
        }
    }

    // MARK: - Initializer

    init(defaults: UserDefaults = .standard, namespace: String) {
        let prefix = "\(namespace).Ovation"

        self.defaults = defaults
        hasReviewedKey = "\(prefix).hasReviewed"
        triggerCountKey = "\(prefix).triggerCount"
        presentationCountKey = "\(prefix).presentationCount"
        lastPresentationDateKey = "\(prefix).lastPresentationDate"
    }
}
