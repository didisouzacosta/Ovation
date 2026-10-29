#if DEBUG
    import SwiftUI

    /// Preview data. The review cards are fictional examples for previews only: never ship
    /// invented reviews as real ones.
    enum OvationPreviewFixtures {

        // MARK: - Cards

        static let appStoreCard = OvationCard(
            id: "example-app-store",
            title: "Calm and clever",
            text: "Example review: a perfect way to unwind at the end of the day. Every chapter brings a new idea.",
            rating: 5,
            author: "Example player",
            source: .appStore
        )

        static let testFlightCard = OvationCard(
            id: "example-testflight",
            title: "Cute in every level",
            text: "Example feedback from a beta tester. TestFlight feedback has no rating, so the card shows no stars.",
            author: "Example tester",
            source: .testFlight
        )

        static let sourceOnlyCard = OvationCard(
            id: "example-source-only",
            title: "Four stars, no name",
            text: "Example review without an author: only the source shows in the footer.",
            rating: 4,
            source: .appStore
        )

        static let longCard = OvationCard(
            id: "example-long",
            title: "A very long title that never fits on one line of the card",
            text: String(
                repeating: "A very long example review that keeps going so the card has to truncate it. ",
                count: 6
            ),
            rating: 5,
            author: "An example author with a name far too long for the footer",
            source: .testFlight
        )

        /// A line said by one of the app's characters, signed with their name: no stars, no
        /// source and no person symbol.
        static let characterLineCard = OvationCard(
            id: "example-character",
            title: "Welcome to the shop!",
            text: "Example line from one of your app's characters, signed with their name.",
            author: "Example character"
        )

        static let reviewCards = [appStoreCard, testFlightCard, sourceOnlyCard]

        static let highlightCards = [
            OvationCard(id: "example-levels", title: "300 levels", text: "Seven chapters, each with a new idea."),
            OvationCard(
                id: "example-modes",
                title: "Four ways to play",
                text: "Story, Casual, Endurance and Challenger."
            ),
            OvationCard(
                id: "example-friends",
                title: "Friends to rescue",
                text: "Twelve friends wait for you on the map."
            ),
        ]

        // MARK: - Texts

        static let longTexts = OvationTexts(
            title: "A remarkably long title that would push the whole layout down if it could wrap freely",
            message: String(repeating: "A message far longer than the sheet allows, which has to truncate. ", count: 6),
            writeReviewButton: "A button title that is much too long to fit inside the capsule",
            feedbackLink: "A feedback link that is far too long to fit on a single line of the sheet"
        )

        // MARK: - Themes

        /// An alternative theme: navy background, violet glow, gold stars and rounded fonts.
        static let roundedTheme = OvationTheme(
            background: Color(.sRGB, red: 0.07, green: 0.06, blue: 0.24),
            glowInner: Color(.sRGB, red: 0.55, green: 0.40, blue: 1.0, opacity: 0.9),
            glowOuter: Color(.sRGB, red: 0.30, green: 0.18, blue: 0.70, opacity: 0.5),
            headerTint: Color(.sRGB, red: 1.0, green: 0.80, blue: 0.24),
            cardStarTint: Color(.sRGB, red: 1.0, green: 0.80, blue: 0.24),
            buttonBackground: Color(.sRGB, red: 1.0, green: 0.97, blue: 0.90),
            buttonForeground: Color(.sRGB, red: 0.10, green: 0.08, blue: 0.30),
            fontStyle: .rounded
        )

        // MARK: - Methods

        static func configuration(
            supportEmail: String = "support@example.com",
            cards: [OvationCard] = reviewCards,
            texts: OvationTexts = OvationTexts(),
            theme: OvationTheme = OvationTheme()
        ) -> OvationConfiguration {
            OvationConfiguration(
                appStoreID: "1234567890",
                supportEmail: supportEmail,
                appName: "Ovation Demo",
                cards: cards,
                texts: texts,
                theme: theme
            )
        }
    }
#endif
