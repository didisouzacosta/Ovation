import SwiftUI

/// The sheet's colors and font design. The defaults match the approved layout: a warm glow on
/// a near-black background.
public struct OvationTheme: Sendable {

    // MARK: - Public Properties

    /// The sheet background. Default: #0B0908.
    public var background: Color

    /// The center of the bottom glow. Default: #D9822B at 85%.
    public var glowInner: Color

    /// The edge of the bottom glow. Default: #8A4313 at 45%.
    public var glowOuter: Color

    /// The laurels and the stars above the title. Default: white.
    public var headerTint: Color

    /// The stars on review cards. Default: #FF9F0A.
    public var cardStarTint: Color

    /// The main button's background. Default: #FFF8EE.
    public var buttonBackground: Color

    /// The main button's title. Default: #1A1A1A.
    public var buttonForeground: Color

    /// The font design of the title and the button. Default: `.standard`.
    public var fontStyle: OvationFontStyle

    // MARK: - Initializer

    public init(
        background: Color = Color(.sRGB, red: 0x0B / 255, green: 0x09 / 255, blue: 0x08 / 255),
        glowInner: Color = Color(.sRGB, red: 0xD9 / 255, green: 0x82 / 255, blue: 0x2B / 255, opacity: 0.85),
        glowOuter: Color = Color(.sRGB, red: 0x8A / 255, green: 0x43 / 255, blue: 0x13 / 255, opacity: 0.45),
        headerTint: Color = .white,
        cardStarTint: Color = Color(.sRGB, red: 0xFF / 255, green: 0x9F / 255, blue: 0x0A / 255),
        buttonBackground: Color = Color(.sRGB, red: 0xFF / 255, green: 0xF8 / 255, blue: 0xEE / 255),
        buttonForeground: Color = Color(.sRGB, red: 0x1A / 255, green: 0x1A / 255, blue: 0x1A / 255),
        fontStyle: OvationFontStyle = .standard
    ) {
        self.background = background
        self.glowInner = glowInner
        self.glowOuter = glowOuter
        self.headerTint = headerTint
        self.cardStarTint = cardStarTint
        self.buttonBackground = buttonBackground
        self.buttonForeground = buttonForeground
        self.fontStyle = fontStyle
    }
}
