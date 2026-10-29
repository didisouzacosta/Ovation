import Foundation

/// The texts the sheet shows: the integrator's overrides, or the localized defaults.
struct OvationResolvedTexts: Equatable, Sendable {

    // MARK: - Public Properties

    let title: String
    let message: String
    let writeReviewButton: String
    let feedbackLink: String
    let feedbackSubject: String

    // MARK: - Initializer

    init(texts: OvationTexts, appName: String, bundle: Bundle = .module) {
        title = texts.title?.ovationNonBlank ?? OvationLocalized.title(bundle: bundle)
        message = texts.message?.ovationNonBlank ?? OvationLocalized.message(appName: appName, bundle: bundle)
        writeReviewButton = texts.writeReviewButton?.ovationNonBlank
            ?? OvationLocalized.writeReviewButton(bundle: bundle)
        feedbackLink = texts.feedbackLink?.ovationNonBlank ?? OvationLocalized.feedbackLink(bundle: bundle)
        feedbackSubject = texts.feedbackSubject?.ovationNonBlank
            ?? OvationLocalized.feedbackSubject(appName: appName, bundle: bundle)
    }
}
