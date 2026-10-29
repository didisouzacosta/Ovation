import Foundation

/// The app name shown in the default texts.
enum OvationAppInfo {

    // MARK: - Private Properties

    private static let displayNameKey = "CFBundleDisplayName"
    private static let bundleNameKey = "CFBundleName"

    // MARK: - Public Methods

    /// The localized display name, then the display name, then the bundle name; the process
    /// name when the bundle has none.
    static func displayName(bundle: Bundle) -> String {
        displayName(info: bundle.infoDictionary, localizedInfo: bundle.localizedInfoDictionary)
            ?? ProcessInfo.processInfo.processName
    }

    static func displayName(info: [String: Any]?, localizedInfo: [String: Any]?) -> String? {
        let candidates = [
            localizedInfo?[displayNameKey],
            info?[displayNameKey],
            localizedInfo?[bundleNameKey],
            info?[bundleNameKey],
        ]

        return candidates
            .compactMap { ($0 as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }
}
