import SwiftUI

/// The warm glow behind the bottom of the sheet. Decorative.
struct OvationGlow: View {

    // MARK: - Public Properties

    let inner: Color
    let outer: Color

    // MARK: - Body

    var body: some View {
        EllipticalGradient(
            stops: [
                .init(color: inner, location: 0),
                .init(color: outer, location: 0.55),
                .init(color: outer.opacity(0), location: 1),
            ]
        )
        .frame(width: OvationSheetLayout.glowWidth, height: OvationSheetLayout.glowHeight)
        .offset(y: OvationSheetLayout.glowOffset)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

#if DEBUG
    #Preview("Brilho") {
        let theme = OvationTheme()

        OvationGlow(inner: theme.glowInner, outer: theme.glowOuter)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .background(theme.background)
    }
#endif
