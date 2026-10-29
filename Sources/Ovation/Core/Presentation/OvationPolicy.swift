/// The presentation decision, in a fixed order: the user has not reviewed, the sheet has not
/// appeared in this session, and the app's rule allows it.
enum OvationPolicy {

    // MARK: - Public Methods

    static func shouldPresent(
        hasReviewed: Bool,
        presentedThisSession: Bool,
        rule: OvationRule,
        context: OvationContext
    ) -> Bool {
        guard !hasReviewed else {
            return false
        }

        guard !presentedThisSession else {
            return false
        }

        return rule.allows(context)
    }
}
