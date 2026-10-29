import SwiftUI

/// A paged carousel: one centered card per page with its neighbors at the edges. It advances
/// every few seconds, wraps from the last card to the first and always accepts swipes. Every
/// card has the same fixed height, so changing pages never moves the sheet.
struct OvationCarousel: View {

    // MARK: - Private Properties

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    @ScaledMetric(relativeTo: .subheadline) private var preferredCardWidth = OvationSheetLayout.cardWidth

    @State private var position: String?
    @State private var containerWidth: CGFloat = 0
    @State private var isScrolling = false

    // MARK: - Public Properties

    let cards: [OvationCard]
    let starTint: Color

    /// `false` keeps the carousel manual even without Reduce Motion or VoiceOver.
    var allowsAutoAdvance = true

    // MARK: - Private Properties

    private var cardWidth: CGFloat {
        OvationCarouselPaging.cardWidth(preferred: preferredCardWidth, containerWidth: containerWidth)
    }

    private var contentMargin: CGFloat {
        OvationCarouselPaging.contentMargin(containerWidth: containerWidth, cardWidth: cardWidth)
    }

    private var tick: OvationCarouselTick {
        OvationCarouselTick(
            cardID: position,
            isScrolling: isScrolling,
            autoAdvances: allowsAutoAdvance && OvationCarouselPaging.autoAdvances(
                cardCount: cards.count,
                reduceMotion: reduceMotion,
                voiceOverEnabled: voiceOverEnabled
            )
        )
    }

    // MARK: - Body

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: OvationSheetLayout.cardSpacing) {
                ForEach(cards) { card in
                    OvationCardView(card: card, starTint: starTint, width: cardWidth)
                }
            }
            .scrollTargetLayout()
        }
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $position)
        .contentMargins(.horizontal, contentMargin, for: .scrollContent)
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { width in
            containerWidth = width
        }
        .onScrollPhaseChange { _, phase in
            isScrolling = phase.isScrolling
        }
        .task(id: tick) {
            await advanceAfterInterval()
        }
    }

    // MARK: - Private Methods

    /// Waits one interval from the visible card, then shows the next one. Any swipe, page change
    /// or accessibility change restarts the wait through `.task(id:)`.
    private func advanceAfterInterval() async {
        guard tick.autoAdvances, !tick.isScrolling else {
            return
        }

        do {
            try await Task.sleep(for: OvationCarouselPaging.interval)
        } catch {
            return
        }

        let next = OvationCarouselPaging.nextCardID(after: position, in: cards.map(\.id))

        withAnimation(.smooth(duration: 0.6)) {
            position = next
        }
    }
}

#if DEBUG
    #Preview("Avançando") {
        OvationCarousel(cards: OvationPreviewFixtures.reviewCards, starTint: .orange)
            .frame(maxHeight: .infinity)
            .background(.black)
    }

    #Preview("Manual") {
        OvationCarousel(cards: OvationPreviewFixtures.reviewCards, starTint: .orange, allowsAutoAdvance: false)
            .frame(maxHeight: .infinity)
            .background(.black)
    }

    #Preview("Conteúdos diferentes, altura fixa") {
        OvationCarousel(
            cards: [
                OvationPreviewFixtures.appStoreCard,
                OvationPreviewFixtures.testFlightCard,
                OvationPreviewFixtures.highlightCards[0],
            ],
            starTint: .orange,
            allowsAutoAdvance: false
        )
        .frame(maxHeight: .infinity)
        .background(.black)
    }

    #Preview("Um card") {
        OvationCarousel(cards: [OvationPreviewFixtures.appStoreCard], starTint: .orange)
            .frame(maxHeight: .infinity)
            .background(.black)
    }

    #Preview("Sem cards") {
        OvationCarousel(cards: [], starTint: .orange)
            .frame(maxHeight: .infinity)
            .background(.black)
    }
#endif
