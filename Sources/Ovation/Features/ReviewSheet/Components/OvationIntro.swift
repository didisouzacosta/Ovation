import SwiftUI

/// The header, the title and the message.
struct OvationIntro: View {

    // MARK: - Private Properties

    @Environment(\.colorSchemeContrast) private var contrast

    @ScaledMetric(relativeTo: .largeTitle) private var headerToTitle = OvationSheetLayout.headerToTitle
    @ScaledMetric(relativeTo: .largeTitle) private var titleSize = OvationSheetLayout.titleSize
    @ScaledMetric(relativeTo: .body) private var titleToMessage = OvationSheetLayout.titleToMessage
    @ScaledMetric(relativeTo: .body) private var messageSize = OvationSheetLayout.messageSize
    @ScaledMetric(relativeTo: .body) private var messageLineSpacing = OvationSheetLayout.messageLineSpacing

    // MARK: - Public Properties

    let title: String
    let message: String
    let theme: OvationTheme

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            OvationHeader(tint: theme.headerTint)

            Text(title)
                .font(.system(size: titleSize, weight: theme.fontStyle.titleWeight, design: theme.fontStyle.design))
                .tracking(OvationSheetLayout.titleTracking)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .lineLimit(OvationSheetLayout.titleLineLimit)
                .truncationMode(.tail)
                .accessibilityAddTraits(.isHeader)
                .padding(.top, headerToTitle)

            Text(message)
                .font(.system(size: messageSize))
                .lineSpacing(messageLineSpacing)
                .foregroundStyle(.white.opacity(OvationSheetLayout.opacity(
                    OvationSheetLayout.messageOpacity,
                    contrast: contrast
                )))
                .multilineTextAlignment(.center)
                .lineLimit(OvationSheetLayout.messageLineLimit)
                .truncationMode(.tail)
                .padding(.top, titleToMessage)
        }
        .padding(.horizontal, OvationSheetLayout.introHorizontalPadding)
    }
}

#if DEBUG
    #Preview("Destaque") {
        OvationIntro(
            title: "Help us grow",
            message: "Your review helps more people discover Ovation Demo.",
            theme: OvationTheme()
        )
        .background(.black)
    }

    #Preview("Destaque arredondado") {
        OvationIntro(
            title: "Help us grow",
            message: "Your review helps more people discover Ovation Demo.",
            theme: OvationPreviewFixtures.roundedTheme
        )
        .background(OvationPreviewFixtures.roundedTheme.background)
    }

    #Preview("Destaque com textos longos") {
        OvationIntro(
            title: OvationPreviewFixtures.longTexts.title ?? "",
            message: OvationPreviewFixtures.longTexts.message ?? "",
            theme: OvationTheme()
        )
        .background(.black)
    }
#endif
