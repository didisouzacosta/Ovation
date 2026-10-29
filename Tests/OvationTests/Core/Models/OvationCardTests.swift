import Testing
@testable import Ovation

@Suite("Ovation cards")
struct OvationCardTests {

    // MARK: - Tests

    @Test("ratings are clamped to one to five stars", arguments: [(7, 5), (5, 5), (3, 3), (1, 1), (0, 1), (-2, 1)])
    func ratingsAreClamped(rating: Int, expected: Int) {
        let card = OvationCard(id: "card", title: "Title", text: "Text", rating: rating)

        #expect(card.rating == expected)
        #expect(card.showsRating)
    }

    @Test("a highlight card has no stars and no footer")
    func highlightCardHasNoStarsOrFooter() {
        let card = OvationCard(id: "highlight", title: "300 levels", text: "Seven chapters.")

        #expect(card.rating == nil)
        #expect(card.author == nil)
        #expect(card.source == nil)
        #expect(card.showsRating == false)
        #expect(card.showsFooter == false)
    }

    @Test("a blank author counts as missing")
    func blankAuthorIsNil() {
        let card = OvationCard(id: "card", title: "Title", text: "Text", author: "  ")

        #expect(card.author == nil)
        #expect(card.showsFooter == false)
    }

    @Test("an author shows the footer")
    func authorShowsFooter() {
        let card = OvationCard(id: "a", title: "T", text: "T", author: " @lucas ")

        #expect(card.author == "@lucas")
        #expect(card.showsFooter)
    }

    @Test("a source shows the footer", arguments: OvationCardSource.allCases)
    func sourceShowsFooter(source: OvationCardSource) {
        let card = OvationCard(id: "b", title: "T", text: "T", source: source)

        #expect(card.source == source)
        #expect(card.showsFooter)
    }

    @Test("TestFlight feedback has no rating, so its card shows no stars")
    func testFlightCardsDropTheRating() {
        let card = OvationCard(id: "beta", title: "T", text: "T", rating: 5, author: "Ana", source: .testFlight)

        #expect(card.rating == nil)
        #expect(card.showsRating == false)
        #expect(card.showsFooter)
    }

    @Test("App Store reviews keep their stars")
    func appStoreCardsKeepTheRating() {
        let card = OvationCard(id: "store", title: "T", text: "T", rating: 5, source: .appStore)

        #expect(card.rating == 5)
        #expect(card.showsRating)
        #expect(card.showsFooter)
    }

    @Test("a review card shows its author as a person", arguments: [
        OvationCard(id: "rated", title: "T", text: "T", rating: 5, author: "Ana"),
        OvationCard(id: "store", title: "T", text: "T", author: "Ana", source: .appStore),
        OvationCard(id: "beta", title: "T", text: "T", author: "Ana", source: .testFlight),
    ])
    func reviewCardsShowTheAuthorSymbol(card: OvationCard) {
        #expect(card.showsFooter)
        #expect(card.showsAuthorSymbol)
    }

    @Test("a character's line shows only the name, never as a user review")
    func characterLineShowsOnlyTheName() {
        let card = OvationCard(id: "pingo", title: "Welcome to the shop!", text: "Thanks!", author: "Master Pingo")

        #expect(card.showsFooter)
        #expect(card.showsRating == false)
        #expect(card.showsAuthorSymbol == false)
    }

    @Test("without an author there is no person symbol", arguments: [
        OvationCard(id: "highlight", title: "T", text: "T"),
        OvationCard(id: "source-only", title: "T", text: "T", rating: 4, source: .appStore),
    ])
    func noAuthorNoSymbol(card: OvationCard) {
        #expect(card.showsAuthorSymbol == false)
    }

    @Test("sources are shown with their brand names")
    func sourceDisplayNames() {
        #expect(OvationCardSource.allCases == [.appStore, .testFlight])
        #expect(OvationCardSource.appStore.displayName == "App Store")
        #expect(OvationCardSource.testFlight.displayName == "TestFlight")
    }
}
