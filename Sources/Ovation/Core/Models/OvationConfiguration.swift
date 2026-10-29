import Foundation

/// Everything the sheet needs from the integrating app.
public struct OvationConfiguration: Sendable {

    // MARK: - Public Properties

    /// The app's Apple ID from App Store Connect, digits only. With an invalid ID the sheet is
    /// never presented automatically.
    public var appStoreID: String

    /// Where "Have a suggestion? Get in touch" sends email. Without an `@`, the link is hidden.
    public var supportEmail: String

    /// The app name in the default texts. `nil` uses the bundle's display name.
    public var appName: String?

    /// The scrolling cards. Empty hides the row.
    public var cards: [OvationCard]

    /// Texts that replace the localized defaults.
    public var texts: OvationTexts

    public var theme: OvationTheme

    /// When the sheet may appear, after Ovation's own checks.
    public var rule: OvationRule

    /// The prefix of the `UserDefaults` keys. `nil` uses the bundle identifier, or "Ovation".
    public var storageNamespace: String?

    // MARK: - Internal Properties

    var isValid: Bool {
        OvationLinks.normalizedAppStoreID(appStoreID) != nil
    }

    var resolvedNamespace: String {
        resolvedNamespace(bundleIdentifier: Bundle.main.bundleIdentifier)
    }

    var resolvedAppName: String {
        resolvedAppName(defaultName: OvationAppInfo.displayName(bundle: .main))
    }

    // MARK: - Initializer

    public init(
        appStoreID: String,
        supportEmail: String,
        appName: String? = nil,
        cards: [OvationCard] = [],
        texts: OvationTexts = OvationTexts(),
        theme: OvationTheme = OvationTheme(),
        rule: OvationRule = .always,
        storageNamespace: String? = nil
    ) {
        self.appStoreID = appStoreID
        self.supportEmail = supportEmail
        self.appName = appName
        self.cards = cards
        self.texts = texts
        self.theme = theme
        self.rule = rule
        self.storageNamespace = storageNamespace
    }

    // MARK: - Internal Methods

    func resolvedNamespace(bundleIdentifier: String?) -> String {
        storageNamespace?.ovationNonBlank ?? bundleIdentifier?.ovationNonBlank ?? "Ovation"
    }

    func resolvedAppName(defaultName: String) -> String {
        appName?.ovationNonBlank ?? defaultName
    }
}
