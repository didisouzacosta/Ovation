import CoreGraphics

/// The carousel's paging rules: one centered card per page, advancing by itself every few
/// seconds and wrapping from the last card to the first.
enum OvationCarouselPaging {

    // MARK: - Public Properties

    static let interval: Duration = .seconds(4)

    /// The space kept on each side when a card is as wide as it can be.
    static let minimumSideMargin: CGFloat = 24

    // MARK: - Public Methods

    /// The page after `index`, wrapping to the first; `nil` with fewer than two cards.
    static func next(after index: Int, count: Int) -> Int? {
        guard count > 1 else {
            return nil
        }

        let current = (0..<count).contains(index) ? index : 0

        return (current + 1) % count
    }

    /// The card after `id`, wrapping to the first. An unknown or `nil` position counts as the
    /// first card, which is where the carousel starts.
    static func nextCardID(after id: String?, in ids: [String]) -> String? {
        let current = id.flatMap { ids.firstIndex(of: $0) } ?? 0

        return next(after: current, count: ids.count).map { ids[$0] }
    }

    /// The carousel only moves by itself with two or more cards, and never with Reduce Motion
    /// or VoiceOver.
    static func autoAdvances(cardCount: Int, reduceMotion: Bool, voiceOverEnabled: Bool) -> Bool {
        cardCount > 1 && !reduceMotion && !voiceOverEnabled
    }

    /// The horizontal content margin that centers one card, with its neighbors at the edges.
    static func contentMargin(containerWidth: CGFloat, cardWidth: CGFloat) -> CGFloat {
        max(0, (containerWidth - cardWidth) / 2)
    }

    /// The preferred card width, narrowed so a card always fits with the side margins.
    static func cardWidth(preferred: CGFloat, containerWidth: CGFloat) -> CGFloat {
        guard containerWidth > 0 else {
            return preferred
        }

        return min(preferred, max(0, containerWidth - minimumSideMargin * 2))
    }
}
