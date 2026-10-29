<h1 align="center">
  <img alt="Ovation icon" src="Docs/Images/app-icon.png" width="160"><br>
  Ovation
</h1>

<p align="center">
  <strong>A SwiftUI sheet that asks happy users for an App Store review.</strong>
</p>

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6.2-F05138?style=flat-square">
  <img alt="iOS" src="https://img.shields.io/badge/iOS-26%2B-000000?style=flat-square">
  <img alt="SPM" src="https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen?style=flat-square">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-blue?style=flat-square">
</p>

Attach a view modifier, pass a trigger, and Ovation decides when to show a review sheet: laurels and five stars, a short message, a paged carousel of cards and one clear call to action, **Write a review**, which opens your app's App Store page ready to write a review. Anyone with a suggestion gets a direct line to your support email.

> **Status:** 1.0.0 is the first release. Depend on an exact version.

## How it works

1. **Write a review** opens your app's App Store page ready to write a review (`https://apps.apple.com/app/id<ID>?action=write-review`), marks the user as reviewed and closes the sheet.
2. **Have a suggestion? Get in touch** opens Mail addressed to your support email and closes the sheet. Without a mail app, an alert shows the address with a **Copy address** button, and the sheet stays open.
3. The close button in the toolbar, or a swipe down, closes the sheet.

Ovation never calls the native review prompt (`RequestReviewAction`); see [App Store guidelines](#app-store-guidelines).

## Requirements

- iOS 26.0 or later (iPhone and iPad).
- Swift tools 6.2, Swift 6 language mode.
- Xcode 26 or later.
- No third-party dependencies: only Apple frameworks (SwiftUI, Foundation, Observation, os, and UIKit for the pasteboard).

## Installation

Add the package in Xcode (`File > Add Package Dependencies`) or in `Package.swift`:

```swift
.package(url: "https://github.com/didisouzacosta/Ovation.git", exact: "1.0.0")
```

```swift
.product(name: "Ovation", package: "Ovation")
```

## Usage

Describe the sheet once, with your App Store ID, support email, cards, texts, theme and rule:

<!-- README:configuration -->
```swift
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
```

Then attach the modifier to a view and pass a trigger, any `Equatable` value that changes when the user reaches a good moment, such as winning a level:

<!-- README:view -->
```swift
import os
import Ovation
import SwiftUI

struct LevelsView: View {

    // MARK: - Private Properties

    private static let logger = Logger(subsystem: "com.example.levels", category: "Review")

    @State private var wonLevels = 0

    // MARK: - Body

    var body: some View {
        List {
            Section {
                LabeledContent("Levels won", value: wonLevels, format: .number)

                Button("Win a level", action: winLevel)
            } footer: {
                Text("The review sheet can appear from the third win, once per session.")
            }
        }
        .ovationReview(.levels, trigger: wonLevels) { event in
            Self.logger.info("Review prompt: \(String(describing: event))")
        }
    }

    // MARK: - Private Methods

    private func winLevel() {
        wonLevels += 1
    }
}
```

Both snippets are the code of the demo app in `Demo/`, and the test suite checks that they stay identical, so they always compile against the current API.

## Configuration

`OvationConfiguration` takes:

| Property | Description |
| --- | --- |
| `appStoreID` | Your app's Apple ID from App Store Connect, digits only. With an invalid ID the sheet is never presented automatically (a log explains why). |
| `supportEmail` | Where the feedback link sends email. Without an `@`, the link is hidden. |
| `appName` | The app name in the default texts. `nil` uses `CFBundleDisplayName` (localized when available), then `CFBundleName`. |
| `cards` | The cards of the carousel. Empty hides the carousel. |
| `texts` | Texts that replace the localized defaults. |
| `theme` | Colors and font design. |
| `rule` | When the sheet may appear, after Ovation's own checks. Default: `.always`. |
| `storageNamespace` | The prefix of the `UserDefaults` keys. `nil` uses the bundle identifier, or `"Ovation"`. |

### Cards

Each `OvationCard` has an `id`, a `title` and a `text`, plus three optional parts:

- `rating`: 1 to 5 stars. Out-of-range values are clamped.
- `author`: who wrote it, or which of your app's characters says it. A blank author counts as none.
- `source`: `.appStore` or `.testFlight`, shown with its brand name. **TestFlight feedback has no rating**: a `.testFlight` card drops its `rating` and never shows stars.

Without any of them, the card is a highlight: just the title and the text, without stars or footer. With only an `author`, the card is a line said by one of your app's own characters: the footer shows the name alone. The footer appears when there is an author or a source; the person symbol next to the author appears only on reviews (a card with a `rating` or a `source`).

> **Show only real reviews.** Quote reviews your users actually wrote. If you have none yet, use true highlights of your app, or lines your app's own characters say, signed with their names and without a rating or source. Never present invented testimonials, or a character's line, as a user's review.

The carousel shows one card per page, centered, with its neighbors at the edges. It advances every 4 seconds and goes back to the first card after the last; users can always swipe. It stays manual with Reduce Motion or VoiceOver, or with a single card. Every card has the same fixed height (192 pt at the default text size, scaled with Dynamic Type), with its content stacked from the top, so changing pages never moves the rest of the sheet. When a card's content does not fit, its text truncates first.

### Texts

Every text can be replaced through `OvationTexts`; `nil` keeps the localized default. Overrides are shown as they are, so localize them in your app.

| Property | Default (English) | Default (Brazilian Portuguese) |
| --- | --- | --- |
| `title` | Help us grow | Nos ajude a crescer |
| `message` | Your review helps more people discover &lt;app name&gt;. | Sua avaliação ajuda mais pessoas a descobrirem o &lt;app name&gt;. |
| `writeReviewButton` | Write a review | Escrever uma avaliação |
| `feedbackLink` | Have a suggestion? Get in touch | Tem alguma sugestão? Fale com a gente |
| `feedbackSubject` | Feedback about &lt;app name&gt; | Feedback sobre o &lt;app name&gt; |

**Texts truncate; keep them short.** Texts never grow the layout: when one does not fit, it ends with an ellipsis, and VoiceOver still reads it in full. The limits are 2 lines for the title, 3 for the message, 1 for the feedback link and the button, and, on cards, 1 for the title, 4 for the text and 1 each for the author and the source.

### Theme

`OvationTheme` defaults to the warm layout: a glow on a near-black background.

| Property | Default |
| --- | --- |
| `background` | `#0B0908` |
| `glowInner` / `glowOuter` | `#D9822B` at 85% / `#8A4313` at 45% |
| `headerTint` | White (laurels and stars above the title) |
| `cardStarTint` | `#FF9F0A` |
| `buttonBackground` / `buttonForeground` | `#FFF8EE` / `#1A1A1A` |
| `fontStyle` | `.standard`: SF Pro, bold title and semibold button. `.rounded`: SF Pro Rounded, heavy title and bold button. The message and the cards always use SF Pro. |

The sheet always uses the dark color scheme.

### Rules

| Rule | Allows |
| --- | --- |
| `.always` | Every trigger. |
| `.fromTrigger(n)` | The `n`-th trigger and every one after it. |
| `.everyTrigger(n)` | Every `n`-th trigger. |
| `.custom { context in … }` | Whatever your closure returns for an `OvationContext`. |
| `rule.waitingDays(d)` | The rule, and at least `d` full days since the last presentation. |

`OvationContext` carries `triggerCount` (including the current trigger), `presentationCount` (previous presentations), `lastPresentation` and `now`. Test your own rules with `rule.allows(context)`.

## Presentation rules

Each change of the trigger is evaluated in this order; the initial value does not count:

1. **Valid configuration.** The App Store ID has digits only.
2. **Not reviewed yet.** Opening *Write a review* marks the user as reviewed, for good: the sheet never appears again and nothing more is counted. Closing the sheet or sending feedback does not.
3. **The trigger is counted**, even when the sheet does not appear.
4. **Once per session.** The sheet appears at most once per app process, across every `ovationReview` modifier. A decided sheet reserves the session until it appears or is released, so two modifiers never both present. This rule is built in and cannot be configured.
5. **Your rule** allows it.

A trigger that changes while the sheet is visible is ignored and not counted.

Change the trigger only at a quiet moment of your app: no alert, sign-in or consent form on screen, and nothing about to start. SwiftUI may dismiss a modal presented outside SwiftUI (for example a UIKit sign-in or consent form) to present the sheet.

## Events

`onEvent` receives `OvationEvent` values for your analytics:

| Event | When |
| --- | --- |
| `.presented` | The sheet is on screen. |
| `.reviewPageOpened` | The user opened *Write a review*. The sheet closes. |
| `.feedbackOpened` | Mail opened the feedback email. The sheet closes. |
| `.dismissed` | The sheet closed with the close button or a swipe. |

Every presentation sends `.presented` once, when the sheet is really on screen, and at most one of `.reviewPageOpened`, `.feedbackOpened` or `.dismissed`. A sheet that cannot appear (for example, while another modal is up) is released after `OvationReview.appearanceTimeout` (one second): it sends nothing and spends neither the session nor the counts. If your app holds its own flow while the sheet is coming, wait a little longer than that timeout.

## Persistence

Ovation stores its state in `UserDefaults.standard`:

| Key | Value |
| --- | --- |
| `<namespace>.Ovation.hasReviewed` | The user opened *Write a review*. |
| `<namespace>.Ovation.triggerCount` | Triggers counted so far. |
| `<namespace>.Ovation.presentationCount` | Automatic presentations so far. |
| `<namespace>.Ovation.lastPresentationDate` | The last automatic presentation. |

The keys are part of the public API: a release that changes them will say so here. The state stays on the device: it is not part of your app's own backups and is lost when the app is deleted. The session lives only in memory. The package's privacy manifest declares `UserDefaults` with reason `CA92.1`, no tracking and no collected data.

## Localization

The default texts ship in English, Brazilian Portuguese, Spanish, French and Japanese, and follow the device language. Brand names (App Store, TestFlight) are never translated.

## Accessibility

- Dynamic Type, up to the `accessibility2` size; the body scrolls on short screens.
- VoiceOver: the decorative laurels are hidden, the title is a header, each card is one element and review stars read "4 of 5 stars".
- Increase Contrast raises the secondary texts.
- Reduce Motion and VoiceOver stop the carousel's automatic paging.

## Debug and previews

Show the sheet on demand, ignoring every rule:

```swift
.ovationReview(isPresented: $isPreviewPresented, configuration: .levels)
```

It ignores the rule, the "reviewed" mark and the session, reads and writes nothing, and sends no events. Use it for debugging and SwiftUI previews only.

## App Store guidelines

- *Write a review* uses the link Apple documents for reviews the user starts: `https://apps.apple.com/app/id<ID>?action=write-review`, the same one behind the "Rate this app" rows in many apps' settings. Apple's [Requesting App Store reviews](https://developer.apple.com/documentation/storekit/requesting-app-store-reviews) recommends this link for actions in your interface and asks you not to call `RequestReviewAction` in response to a tap, so Ovation never calls the native prompt.
- Your app can still ask for the native prompt on its own, at another moment you choose, for example:

```swift
@Environment(\.requestReview) private var requestReview

// At a natural pause, never in response to a button tap:
requestReview()
```

- The sheet is presented by your app, not opened by the user, so keep it rare. Ovation already shows it at most once per session and never again after the user opens *Write a review*; add a rule such as `.waitingDays(_:)` on top.
- The sheet never collects a rating: the stars are decorative, not tappable, and nothing rewards a review.
- The defaults never ask for a specific rating, and the feedback link is offered to everyone: it does not filter who can review.
- Show only real reviews, true highlights, or lines your app's own characters say (signed with their names, without a rating or source) in the cards.
- The sheet can always be closed and never blocks your app.

## Demo

Open `Demo/OvationDemo.xcodeproj` and run the `OvationDemo` scheme. **Win a level** drives the real modifier (from the third win, once per session, every 14 days), **Preview the sheet** shows it on demand and **Reset saved state** clears the stored state; relaunch the app for a new session.

## Development

```sh
xcodebuild test -scheme Ovation -destination 'platform=iOS Simulator,name=iPhone 17'
xcodebuild -project Demo/OvationDemo.xcodeproj -scheme OvationDemo -destination 'generic/platform=iOS Simulator' build
scripts/lint-swift.sh
```

## License

MIT. See [LICENSE](LICENSE).
