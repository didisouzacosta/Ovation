import CoreGraphics
import Testing
@testable import Ovation

@Suite("Carousel paging")
struct OvationCarouselPagingTests {

    // MARK: - Tests

    @Test("the next page follows the current one")
    func nextPage() {
        #expect(OvationCarouselPaging.next(after: 0, count: 3) == 1)
        #expect(OvationCarouselPaging.next(after: 1, count: 3) == 2)
    }

    @Test("after the last page the carousel goes back to the first")
    func wrapsToTheFirstPage() {
        #expect(OvationCarouselPaging.next(after: 2, count: 3) == 0)
    }

    @Test("zero or one card never advances", arguments: [0, 1])
    func fewCardsNeverAdvance(count: Int) {
        #expect(OvationCarouselPaging.next(after: 0, count: count) == nil)
    }

    @Test("the next card ID wraps and treats an unknown position as the first card")
    func nextCardID() {
        let ids = ["a", "b", "c"]

        #expect(OvationCarouselPaging.nextCardID(after: nil, in: ids) == "b")
        #expect(OvationCarouselPaging.nextCardID(after: "b", in: ids) == "c")
        #expect(OvationCarouselPaging.nextCardID(after: "c", in: ids) == "a")
        #expect(OvationCarouselPaging.nextCardID(after: "z", in: ids) == "b")
        #expect(OvationCarouselPaging.nextCardID(after: "a", in: ["a"]) == nil)
        #expect(OvationCarouselPaging.nextCardID(after: nil, in: []) == nil)
    }

    @Test("the carousel advances by itself only with two or more cards and no motion or VoiceOver needs")
    func autoAdvance() {
        #expect(OvationCarouselPaging.autoAdvances(cardCount: 2, reduceMotion: false, voiceOverEnabled: false))
        #expect(OvationCarouselPaging.autoAdvances(cardCount: 1, reduceMotion: false, voiceOverEnabled: false) == false)
        #expect(OvationCarouselPaging.autoAdvances(cardCount: 0, reduceMotion: false, voiceOverEnabled: false) == false)
        #expect(OvationCarouselPaging.autoAdvances(cardCount: 5, reduceMotion: true, voiceOverEnabled: false) == false)
        #expect(OvationCarouselPaging.autoAdvances(cardCount: 5, reduceMotion: false, voiceOverEnabled: true) == false)
    }

    @Test("pages advance every four seconds")
    func interval() {
        #expect(OvationCarouselPaging.interval == .seconds(4))
    }

    @Test("the content margin centers one card")
    func contentMarginCentersTheCard() {
        #expect(OvationCarouselPaging.contentMargin(containerWidth: 402, cardWidth: 272) == 65)
        #expect(OvationCarouselPaging.contentMargin(containerWidth: 0, cardWidth: 272) == 0)
    }

    @Test("a card never gets wider than the container minus the side margins")
    func cardWidthFitsTheContainer() {
        #expect(OvationCarouselPaging.cardWidth(preferred: 272, containerWidth: 402) == 272)
        #expect(OvationCarouselPaging.cardWidth(preferred: 420, containerWidth: 402) == 354)
        #expect(OvationCarouselPaging.cardWidth(preferred: 272, containerWidth: 0) == 272)
    }
}
