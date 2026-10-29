import SwiftUI
import Testing
@testable import Ovation

@Suite("Ovation theme")
struct OvationThemeTests {

    // MARK: - Tests

    @Test("the default theme uses the colors of the approved layout")
    func defaultColors() {
        let theme = OvationTheme()

        #expect(hex(theme.background) == "0B0908FF")
        #expect(hex(theme.glowInner) == "D9822BD9")
        #expect(hex(theme.glowOuter) == "8A431373")
        #expect(hex(theme.headerTint) == "FFFFFFFF")
        #expect(hex(theme.cardStarTint) == "FF9F0AFF")
        #expect(hex(theme.buttonBackground) == "FFF8EEFF")
        #expect(hex(theme.buttonForeground) == "1A1A1AFF")
        #expect(theme.fontStyle == .standard)
    }

    @Test("the standard font style uses SF Pro bold titles and semibold buttons")
    func standardFontStyle() {
        let style = OvationFontStyle.standard

        #expect(style.design == .default)
        #expect(style.titleWeight == .bold)
        #expect(style.buttonWeight == .semibold)
    }

    @Test("the rounded font style uses SF Pro Rounded heavy titles and bold buttons")
    func roundedFontStyle() {
        let style = OvationFontStyle.rounded

        #expect(style.design == .rounded)
        #expect(style.titleWeight == .heavy)
        #expect(style.buttonWeight == .bold)
    }

    // MARK: - Private Methods

    private func hex(_ color: Color) -> String {
        let resolved = color.resolve(in: EnvironmentValues())
        let components = [resolved.red, resolved.green, resolved.blue, resolved.opacity]

        return components
            .map { String(format: "%02X", Int(($0 * 255).rounded())) }
            .joined()
    }
}
