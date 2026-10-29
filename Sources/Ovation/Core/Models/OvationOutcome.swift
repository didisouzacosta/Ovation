/// How an automatic presentation ended.
enum OvationOutcome: Equatable, Sendable {

    // MARK: - Outcomes

    case reviewPageOpened
    case feedbackOpened
    case dismissed

    // MARK: - Internal Properties

    var event: OvationEvent {
        switch self {
        case .reviewPageOpened:
            .reviewPageOpened
        case .feedbackOpened:
            .feedbackOpened
        case .dismissed:
            .dismissed
        }
    }
}
