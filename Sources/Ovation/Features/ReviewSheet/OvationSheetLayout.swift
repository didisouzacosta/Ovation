import SwiftUI

/// Sizes from the approved layout (Figma, screens 01 and 02). Views scale them with
/// `@ScaledMetric`.
enum OvationSheetLayout {

    // MARK: - Content

    static let contentSpacing: CGFloat = 32
    static let introHorizontalPadding: CGFloat = 32

    // MARK: - Header

    static let headerSpacing: CGFloat = 14
    static let laurelWidth: CGFloat = 44
    static let laurelHeight: CGFloat = 70
    static let headerStarSize: CGFloat = 30
    static let headerStarSpacing: CGFloat = 6

    // MARK: - Title and Message

    static let headerToTitle: CGFloat = 18
    static let titleSize: CGFloat = 30
    static let titleTracking: CGFloat = -0.4
    static let titleLineLimit = 2
    static let titleToMessage: CGFloat = 10
    static let messageSize: CGFloat = 16
    /// SF Pro 16 has a natural line height of about 19 pt; the layout uses 22 pt.
    static let messageLineSpacing: CGFloat = 3
    static let messageLineLimit = 3

    // MARK: - Card

    static let cardWidth: CGFloat = 272
    /// The fixed height of every card: a full card (padding, stars, a 1-line title, 4 lines of
    /// text, the footer and the spacing) at the default text size.
    static let cardHeight: CGFloat = 192
    static let cardSpacing: CGFloat = 12
    static let cardPadding: CGFloat = 18
    static let cardContentSpacing: CGFloat = 10
    static let cardCornerRadius: CGFloat = 24
    static let cardStarSize: CGFloat = 15
    static let cardStarSpacing: CGFloat = 3
    static let cardTitleSize: CGFloat = 15
    static let cardTitleLineLimit = 1
    static let cardTextSize: CGFloat = 14
    /// SF Pro 14 has a natural line height of about 17 pt; the layout uses 19 pt.
    static let cardTextLineSpacing: CGFloat = 2
    static let cardTextLineLimit = 4
    static let cardFooterSize: CGFloat = 13
    static let cardPersonSize: CGFloat = 12
    static let cardAuthorSpacing: CGFloat = 5
    static let cardFillOpacity = 0.08
    static let cardBorderOpacity = 0.12

    // MARK: - Footer

    static let footerSpacing: CGFloat = 12
    static let footerHorizontalPadding: CGFloat = 24
    static let footerTopPadding: CGFloat = 8
    static let footerBottomPadding: CGFloat = 12
    static let feedbackLinkSize: CGFloat = 14
    static let feedbackLinkOpacity = 0.85
    static let buttonHeight: CGFloat = 56
    static let buttonTitleSize: CGFloat = 17
    static let buttonShadowOpacity = 0.25
    /// The layout's 9 pt shadow blur; SwiftUI's radius is about half of a Figma blur.
    static let buttonShadowRadius: CGFloat = 4.5
    static let buttonShadowY: CGFloat = 6

    // MARK: - Glow

    static let glowWidth: CGFloat = 560
    static let glowHeight: CGFloat = 420
    /// How far the glow extends below the sheet's bottom edge.
    static let glowOffset: CGFloat = 120

    // MARK: - Secondary Text

    static let messageOpacity = 0.6
    static let secondaryOpacity = 0.58
    static let increasedContrastOpacity = 0.85

    // MARK: - Methods

    /// Secondary texts rise to 85% with Increase Contrast.
    static func opacity(_ base: Double, contrast: ColorSchemeContrast) -> Double {
        contrast == .increased ? max(base, increasedContrastOpacity) : base
    }

    /// The scroll view's height, used to center the content when it fits. The scroll view is
    /// already laid out between the navigation bar and the footer, so its safe area insets are
    /// not subtracted again.
    static func visibleHeight(_ proxy: GeometryProxy) -> CGFloat {
        max(0, proxy.size.height)
    }
}
