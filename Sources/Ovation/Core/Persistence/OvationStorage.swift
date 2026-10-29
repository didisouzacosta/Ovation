import Foundation

/// What Ovation remembers across sessions.
@MainActor
protocol OvationStorage: AnyObject {
    /// The user opened "Write a review". Final: the sheet never appears again.
    var hasReviewed: Bool { get set }

    /// Every trigger counted so far.
    var triggerCount: Int { get set }

    /// Every automatic presentation so far.
    var presentationCount: Int { get set }

    var lastPresentationDate: Date? { get set }
}
