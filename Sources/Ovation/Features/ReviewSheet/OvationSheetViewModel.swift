import Foundation
import Observation

/// The sheet's actions: Write a review and the feedback email.
@MainActor
@Observable
final class OvationSheetViewModel {

    // MARK: - Public Properties

    let texts: OvationResolvedTexts
    let cards: [OvationCard]

    @ObservationIgnored let feedbackURL: URL?

    var isMailAlertPresented = false

    var primaryButtonTitle: String {
        texts.writeReviewButton
    }

    var showsCarousel: Bool {
        !cards.isEmpty
    }

    var showsFeedbackLink: Bool {
        feedbackURL != nil
    }

    var mailUnavailableTitle: String {
        OvationLocalized.mailUnavailableTitle(bundle: bundle)
    }

    var mailUnavailableMessage: String {
        OvationLocalized.mailUnavailableMessage(email: supportEmail ?? "", bundle: bundle)
    }

    var mailUnavailableCopyTitle: String {
        OvationLocalized.mailUnavailableCopy(bundle: bundle)
    }

    var mailUnavailableDismissTitle: String {
        OvationLocalized.mailUnavailableDismiss(bundle: bundle)
    }

    // MARK: - Private Properties

    @ObservationIgnored private let reviewURL: URL?
    @ObservationIgnored private let supportEmail: String?
    @ObservationIgnored private let bundle: Bundle
    @ObservationIgnored private let copyToPasteboard: @MainActor (String) -> Void

    // MARK: - Initializer

    init(
        configuration: OvationConfiguration,
        bundle: Bundle = .module,
        copyToPasteboard: @escaping @MainActor (String) -> Void = OvationPasteboard.copy
    ) {
        let texts = OvationResolvedTexts(
            texts: configuration.texts,
            appName: configuration.resolvedAppName,
            bundle: bundle
        )

        self.texts = texts
        cards = configuration.cards
        feedbackURL = OvationLinks.feedbackURL(email: configuration.supportEmail, subject: texts.feedbackSubject)
        reviewURL = OvationLinks.writeReviewURL(appStoreID: configuration.appStoreID)
        supportEmail = OvationLinks.normalizedEmail(configuration.supportEmail)
        self.bundle = bundle
        self.copyToPasteboard = copyToPasteboard
    }

    // MARK: - Public Methods

    /// Write a review opens the App Store page; without a valid App Store ID it just closes the
    /// sheet.
    func primaryAction() -> OvationSheetAction {
        guard let reviewURL else {
            return .finish
        }

        return .openReviewPage(reviewURL)
    }

    /// Whether the sheet should close after the system answered the `mailto:` link. Without a
    /// mail app, the sheet stays open with the address.
    func mailOpened(_ accepted: Bool) -> Bool {
        guard accepted else {
            isMailAlertPresented = true
            return false
        }

        return true
    }

    func copyEmail() {
        guard let supportEmail else {
            return
        }

        copyToPasteboard(supportEmail)
    }
}
