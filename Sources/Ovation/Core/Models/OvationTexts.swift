/// Texts that replace the package's localized defaults. `nil` keeps the default.
///
/// The overrides are shown as they are: localize them in your app before passing them.
public struct OvationTexts: Equatable, Sendable {

    // MARK: - Public Properties

    /// Default: "Help us grow".
    public var title: String?

    /// Default: "Your review helps more people discover <app name>."
    public var message: String?

    /// Default: "Write a review". Opens the App Store page to write a review.
    public var writeReviewButton: String?

    /// Default: "Have a suggestion? Get in touch". Opens Mail to the support email.
    public var feedbackLink: String?

    /// Default: "Feedback about <app name>". The subject of the feedback email.
    public var feedbackSubject: String?

    // MARK: - Initializer

    public init(
        title: String? = nil,
        message: String? = nil,
        writeReviewButton: String? = nil,
        feedbackLink: String? = nil,
        feedbackSubject: String? = nil
    ) {
        self.title = title
        self.message = message
        self.writeReviewButton = writeReviewButton
        self.feedbackLink = feedbackLink
        self.feedbackSubject = feedbackSubject
    }
}
