import Foundation

/// What a rule knows when a trigger changes.
public struct OvationContext: Equatable, Sendable {

    // MARK: - Public Properties

    /// How many triggers were counted, including the current one.
    public let triggerCount: Int

    /// How many times the sheet was presented before.
    public let presentationCount: Int

    /// When the sheet was last presented, or `nil` if it never was.
    public let lastPresentation: Date?

    /// The current date.
    public let now: Date

    // MARK: - Initializer

    public init(
        triggerCount: Int,
        presentationCount: Int,
        lastPresentation: Date?,
        now: Date
    ) {
        self.triggerCount = triggerCount
        self.presentationCount = presentationCount
        self.lastPresentation = lastPresentation
        self.now = now
    }
}
