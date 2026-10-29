import Foundation

/// The package's localized strings, from `Localizable.xcstrings` in the package bundle.
enum OvationLocalized {

    // MARK: - Public Methods

    static func title(bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.title",
            defaultValue: "Help us grow",
            bundle: bundle,
            comment: "Title of the review sheet."
        )
    }

    static func message(appName: String, bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.message",
            defaultValue: "Your review helps more people discover \(appName).",
            bundle: bundle,
            comment: "Message under the title. The placeholder is the app name. Never ask for a specific rating."
        )
    }

    static func writeReviewButton(bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.writeReviewButton",
            defaultValue: "Write a review",
            bundle: bundle,
            comment: "Main button. Opens the App Store page to write a review."
        )
    }

    static func feedbackLink(bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.feedbackLink",
            defaultValue: "Have a suggestion? Get in touch",
            bundle: bundle,
            comment: "Link above the main button. Opens Mail to the support email. Neutral, for any user."
        )
    }

    static func feedbackSubject(appName: String, bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.feedbackSubject",
            defaultValue: "Feedback about \(appName)",
            bundle: bundle,
            comment: "Subject of the feedback email. The placeholder is the app name."
        )
    }

    static func mailUnavailableTitle(bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.mailUnavailableTitle",
            defaultValue: "Can’t open Mail",
            bundle: bundle,
            comment: "Alert title when no email app can open the feedback email."
        )
    }

    static func mailUnavailableMessage(email: String, bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.mailUnavailableMessage",
            defaultValue: "Write to us at \(email).",
            bundle: bundle,
            comment: "Alert message when no email app opens the feedback email. The placeholder is the support email."
        )
    }

    static func mailUnavailableCopy(bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.mailUnavailableCopy",
            defaultValue: "Copy address",
            bundle: bundle,
            comment: "Alert button that copies the support email address."
        )
    }

    static func mailUnavailableDismiss(bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.mailUnavailableDismiss",
            defaultValue: "OK",
            bundle: bundle,
            comment: "Alert button that closes the alert."
        )
    }

    static func cardRating(_ rating: Int, bundle: Bundle = .module) -> String {
        String(
            localized: "ovation.cardRating",
            defaultValue: "\(rating) of 5 stars",
            bundle: bundle,
            comment: "VoiceOver label of a review card's stars. The placeholder is the number of stars, from 1 to 5."
        )
    }
}
