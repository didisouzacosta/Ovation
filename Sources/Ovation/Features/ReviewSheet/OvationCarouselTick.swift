/// What restarts the carousel's countdown: the visible card, a scroll in progress, or a change
/// in whether the carousel may advance by itself.
struct OvationCarouselTick: Equatable, Sendable {
    let cardID: String?
    let isScrolling: Bool
    let autoAdvances: Bool
}
