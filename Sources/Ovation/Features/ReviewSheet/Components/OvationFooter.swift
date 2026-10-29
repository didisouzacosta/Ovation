import SwiftUI

/// The feedback link and the main button, above the bottom safe area.
struct OvationFooter: View {

    // MARK: - Private Properties

    @ScaledMetric(relativeTo: .subheadline) private var linkSize = OvationSheetLayout.feedbackLinkSize

    // MARK: - Public Properties

    /// The feedback link's title, or `nil` to hide the link.
    let feedbackLink: String?
    let primaryTitle: String
    let theme: OvationTheme
    let onFeedback: () -> Void
    let onPrimary: () -> Void

    // MARK: - Body

    var body: some View {
        VStack(spacing: OvationSheetLayout.footerSpacing) {
            if let feedbackLink {
                Button(action: onFeedback) {
                    Text(feedbackLink)
                        .font(.system(size: linkSize, weight: .semibold))
                        .foregroundStyle(.white.opacity(OvationSheetLayout.feedbackLinkOpacity))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }

            Button(action: onPrimary) {
                Text(primaryTitle)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .contentTransition(.opacity)
            }
            .buttonStyle(OvationPrimaryButtonStyle(theme: theme))
            .animation(.snappy, value: primaryTitle)
        }
        .padding(.horizontal, OvationSheetLayout.footerHorizontalPadding)
        .padding(.top, OvationSheetLayout.footerTopPadding)
        .padding(.bottom, OvationSheetLayout.footerBottomPadding)
    }
}

#if DEBUG
    #Preview("Escrever uma avaliação") {
        OvationFooter(
            feedbackLink: "Have a suggestion? Get in touch",
            primaryTitle: "Write a review",
            theme: OvationTheme(),
            onFeedback: {},
            onPrimary: {}
        )
        .background(.black)
    }

    #Preview("Sem e-mail") {
        OvationFooter(
            feedbackLink: nil,
            primaryTitle: "Write a review",
            theme: OvationTheme(),
            onFeedback: {},
            onPrimary: {}
        )
        .background(.black)
    }
#endif
