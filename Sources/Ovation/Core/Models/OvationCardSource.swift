/// Where a review card's review was written.
public enum OvationCardSource: String, Equatable, Hashable, Sendable, CaseIterable {

    // MARK: - Sources

    case appStore
    case testFlight

    // MARK: - Public Properties

    /// The brand name shown on the card. Brand names are not translated.
    public var displayName: String {
        switch self {
        case .appStore:
            "App Store"
        case .testFlight:
            "TestFlight"
        }
    }
}
