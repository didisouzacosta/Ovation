import Foundation

/// The integrating app's rule for when the sheet may appear.
///
/// Ovation always checks first that the user has not reviewed yet and that the sheet has not
/// appeared in the current session; the rule only decides among the remaining triggers.
public struct OvationRule: Sendable {

    // MARK: - Public Properties

    /// Allows every trigger.
    public static let always = OvationRule { _ in true }

    // MARK: - Private Properties

    private static let secondsPerDay: TimeInterval = 86_400

    private let predicate: @Sendable (OvationContext) -> Bool

    // MARK: - Initializer

    private init(_ predicate: @escaping @Sendable (OvationContext) -> Bool) {
        self.predicate = predicate
    }

    // MARK: - Public Methods

    /// Allows the given trigger and every one after it. Numbers below 1 mean the first trigger.
    public static func fromTrigger(_ number: Int) -> OvationRule {
        let threshold = max(1, number)

        return OvationRule { context in
            context.triggerCount >= threshold
        }
    }

    /// Allows every `interval`-th trigger. Intervals below 1 mean every trigger.
    public static func everyTrigger(_ interval: Int) -> OvationRule {
        let interval = max(1, interval)

        return OvationRule { context in
            context.triggerCount > 0 && context.triggerCount.isMultiple(of: interval)
        }
    }

    /// Lets the app decide with its own closure.
    public static func custom(_ allows: @escaping @Sendable (OvationContext) -> Bool) -> OvationRule {
        OvationRule(allows)
    }

    /// Also requires `days` full days since the last presentation. Negative days mean no wait.
    public func waitingDays(_ days: Int) -> OvationRule {
        let interval = TimeInterval(max(0, days)) * Self.secondsPerDay
        let base = predicate

        return OvationRule { context in
            guard base(context) else {
                return false
            }

            guard let lastPresentation = context.lastPresentation else {
                return true
            }

            return context.now.timeIntervalSince(lastPresentation) >= interval
        }
    }

    /// Whether the rule allows a presentation in `context`. Use it to test your own rules.
    public func allows(_ context: OvationContext) -> Bool {
        predicate(context)
    }
}
