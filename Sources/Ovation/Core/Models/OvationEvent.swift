/// What happened to an automatic presentation, for the integrating app's analytics.
public enum OvationEvent: Equatable, Sendable {

    // MARK: - Events

    /// The sheet is on screen. A sheet that could not appear (another modal was up) sends
    /// nothing and spends neither the session nor the counts.
    case presented

    /// The user opened the App Store page to write a review. The sheet closes.
    case reviewPageOpened

    /// The user opened Mail to send feedback. The sheet closes.
    case feedbackOpened

    /// The sheet closed with the close button or the swipe gesture.
    case dismissed
}
