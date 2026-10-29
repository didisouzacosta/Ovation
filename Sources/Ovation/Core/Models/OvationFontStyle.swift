import SwiftUI

/// The font design of the title and the button. Card texts and the message always use SF Pro.
public enum OvationFontStyle: Equatable, Sendable {

    // MARK: - Styles

    /// SF Pro: bold title, semibold button.
    case standard

    /// SF Pro Rounded: heavy title, bold button.
    case rounded

    // MARK: - Internal Properties

    var design: Font.Design {
        switch self {
        case .standard:
            .default
        case .rounded:
            .rounded
        }
    }

    var titleWeight: Font.Weight {
        switch self {
        case .standard:
            .bold
        case .rounded:
            .heavy
        }
    }

    var buttonWeight: Font.Weight {
        switch self {
        case .standard:
            .semibold
        case .rounded:
            .bold
        }
    }
}
