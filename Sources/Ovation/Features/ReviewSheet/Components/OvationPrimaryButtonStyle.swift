import SwiftUI

/// The capsule button of the approved layout, colored by the theme.
struct OvationPrimaryButtonStyle: ButtonStyle {

    // MARK: - Private Properties

    @ScaledMetric(relativeTo: .body) private var titleSize = OvationSheetLayout.buttonTitleSize
    @ScaledMetric(relativeTo: .body) private var height = OvationSheetLayout.buttonHeight

    // MARK: - Public Properties

    let theme: OvationTheme

    // MARK: - Public Methods

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: titleSize, weight: theme.fontStyle.buttonWeight, design: theme.fontStyle.design))
            .foregroundStyle(theme.buttonForeground)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, OvationSheetLayout.footerHorizontalPadding)
            .frame(maxWidth: .infinity, minHeight: height)
            .background(theme.buttonBackground, in: .capsule)
            .shadow(
                color: .black.opacity(OvationSheetLayout.buttonShadowOpacity),
                radius: OvationSheetLayout.buttonShadowRadius,
                y: OvationSheetLayout.buttonShadowY
            )
            .contentShape(.capsule)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }
}
