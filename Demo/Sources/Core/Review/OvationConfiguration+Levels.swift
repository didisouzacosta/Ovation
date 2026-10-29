// README:configuration:begin

import Ovation
import SwiftUI

extension OvationConfiguration {

    // MARK: - Levels

    /// The review sheet of a puzzle game, shown from the third level won, at most once every
    /// 14 days.
    static let levels = OvationConfiguration(
        appStoreID: "1234567890", // Your app's Apple ID, from App Store Connect.
        supportEmail: "support@example.com",
        cards: [
            // Example reviews: show only real reviews your users wrote.
            OvationCard(
                id: "review-marina",
                title: "Relaxing in the right way",
                text: "Perfect to switch off at the end of the day. Every chapter brings a new idea.",
                rating: 5,
                author: "Marina C.",
                source: .appStore
            ),
            // TestFlight feedback has no rating: the card never shows stars.
            OvationCard(
                id: "beta-lucas",
                title: "The best color sorter",
                text: "The pours are beautiful and the map makes you want to keep going.",
                author: "@lucasplay",
                source: .testFlight
            ),
            // A highlight: no author, no stars and no source.
            OvationCard(
                id: "highlight-levels",
                title: "300 levels",
                text: "Seven chapters, each with a new mechanic to master."
            ),
        ],
        texts: OvationTexts(title: "Enjoying the game?"),
        theme: OvationTheme(
            headerTint: .yellow,
            cardStarTint: .yellow,
            fontStyle: .rounded
        ),
        rule: .fromTrigger(3).waitingDays(14)
    )
}

// README:configuration:end
