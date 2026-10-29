import SwiftUI

/// One card of the carousel: stars, title, text and footer for a review, just title and text for
/// a highlight, or title, text and the character's name (no person symbol) for a character's
/// line. Every card has the same fixed height, with its content stacked from the top; when it
/// does not fit, the text truncates first.
struct OvationCardView: View {

    // MARK: - Private Properties

    @Environment(\.colorSchemeContrast) private var contrast

    @ScaledMetric(relativeTo: .body) private var height = OvationSheetLayout.cardHeight
    @ScaledMetric(relativeTo: .subheadline) private var padding = OvationSheetLayout.cardPadding
    @ScaledMetric(relativeTo: .subheadline) private var spacing = OvationSheetLayout.cardContentSpacing
    @ScaledMetric(relativeTo: .subheadline) private var starSize = OvationSheetLayout.cardStarSize
    @ScaledMetric(relativeTo: .subheadline) private var starSpacing = OvationSheetLayout.cardStarSpacing
    @ScaledMetric(relativeTo: .subheadline) private var titleSize = OvationSheetLayout.cardTitleSize
    @ScaledMetric(relativeTo: .subheadline) private var textSize = OvationSheetLayout.cardTextSize
    @ScaledMetric(relativeTo: .subheadline) private var textLineSpacing = OvationSheetLayout.cardTextLineSpacing
    @ScaledMetric(relativeTo: .footnote) private var footerSize = OvationSheetLayout.cardFooterSize
    @ScaledMetric(relativeTo: .footnote) private var personSize = OvationSheetLayout.cardPersonSize
    @ScaledMetric(relativeTo: .footnote) private var authorSpacing = OvationSheetLayout.cardAuthorSpacing

    // MARK: - Public Properties

    let card: OvationCard
    let starTint: Color
    let width: CGFloat

    // MARK: - Private Properties

    private var secondaryOpacity: Double {
        OvationSheetLayout.opacity(OvationSheetLayout.secondaryOpacity, contrast: contrast)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            if let rating = card.rating {
                stars(rating)
                    .layoutPriority(1)
            }

            Text(card.title)
                .font(.system(size: titleSize, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(OvationSheetLayout.cardTitleLineLimit)
                .truncationMode(.tail)
                .layoutPriority(1)

            Text(card.text)
                .font(.system(size: textSize))
                .lineSpacing(textLineSpacing)
                .foregroundStyle(.white.opacity(secondaryOpacity))
                .lineLimit(OvationSheetLayout.cardTextLineLimit)
                .truncationMode(.tail)

            if card.showsFooter {
                footer
                    .layoutPriority(1)
            }
        }
        .padding(padding)
        .frame(width: width, height: height, alignment: .topLeading)
        .background(
            .white.opacity(OvationSheetLayout.cardFillOpacity),
            in: .rect(cornerRadius: OvationSheetLayout.cardCornerRadius)
        )
        .overlay {
            RoundedRectangle(cornerRadius: OvationSheetLayout.cardCornerRadius)
                .strokeBorder(.white.opacity(OvationSheetLayout.cardBorderOpacity), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Subviews

    private var footer: some View {
        HStack(alignment: .center, spacing: spacing) {
            if let author = card.author {
                HStack(alignment: .center, spacing: authorSpacing) {
                    if card.showsAuthorSymbol {
                        Image(systemName: "person.fill")
                            .font(.system(size: personSize))
                            .accessibilityHidden(true)
                    }

                    Text(author)
                        .font(.system(size: footerSize, weight: .semibold))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .foregroundStyle(.white)
            }

            Spacer(minLength: 0)

            if let source = card.source {
                Text(source.displayName)
                    .font(.system(size: footerSize))
                    .foregroundStyle(.white.opacity(secondaryOpacity))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(1)
            }
        }
    }

    // MARK: - Private Methods

    private func stars(_ rating: Int) -> some View {
        HStack(spacing: starSpacing) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: starSize, height: starSize)
                    .opacity(star <= rating ? 1 : 0.25)
            }
        }
        .foregroundStyle(starTint)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(OvationLocalized.cardRating(rating))
    }
}

#if DEBUG
    #Preview("Card completo") {
        OvationCardView(card: OvationPreviewFixtures.appStoreCard, starTint: .orange, width: 272)
            .padding()
            .background(.black)
    }

    #Preview("TestFlight") {
        OvationCardView(card: OvationPreviewFixtures.testFlightCard, starTint: .orange, width: 272)
            .padding()
            .background(.black)
    }

    #Preview("Só origem") {
        OvationCardView(card: OvationPreviewFixtures.sourceOnlyCard, starTint: .orange, width: 272)
            .padding()
            .background(.black)
    }

    #Preview("Fala de personagem") {
        OvationCardView(card: OvationPreviewFixtures.characterLineCard, starTint: .orange, width: 272)
            .padding()
            .background(.black)
    }

    #Preview("Destaque curto no topo") {
        OvationCardView(card: OvationPreviewFixtures.highlightCards[0], starTint: .orange, width: 272)
            .padding()
            .background(.black)
    }

    #Preview("Texto longo") {
        OvationCardView(card: OvationPreviewFixtures.longCard, starTint: .orange, width: 272)
            .padding()
            .background(.black)
    }

    #Preview("Dynamic Type grande truncando o texto") {
        OvationCardView(card: OvationPreviewFixtures.appStoreCard, starTint: .orange, width: 320)
            .padding()
            .background(.black)
            .dynamicTypeSize(.accessibility2)
    }
#endif
