# Ovation

<p align="center">
  <strong>A SwiftUI sheet that asks happy users for an App Store review.</strong>
</p>

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6.2-F05138?style=flat-square">
  <img alt="SPM" src="https://img.shields.io/badge/Swift_Package_Manager-compatible-brightgreen?style=flat-square">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-blue?style=flat-square">
</p>

Attach a view modifier, pass a trigger, and `Ovation` decides when to show a review sheet: laurels and five stars, a short pitch, a scrolling row of cards, and one clear call to action. Users who are not happy get a direct line to your support email instead.

> **Status:** in development. The API is not public yet; this README describes the intended behavior of the first release.

## How it works

1. **Continue** asks for the native App Store rating prompt.
2. The button then becomes **Write a review**, which opens your app's App Store page ready to write a review, and closes the sheet.
3. **Not happy? Send feedback** opens Mail addressed to your support email.
4. The close button (✕) in the toolbar dismisses the sheet.

## Presentation rules

- **Your rule, your trigger.** You decide when the sheet may appear (for example, every few completed levels). The modifier evaluates the rule each time the trigger changes.
- **Only for users who haven't reviewed.** Opening the App Store with *Write a review* marks the user as reviewed, and the sheet never appears again. Closing it, dismissing the native prompt or sending feedback does not.
- **Once per session.** The sheet appears at most once per app session, whatever the trigger does.

## Customization

- Every text can be localized or replaced. English, Brazilian Portuguese, Spanish, French and Japanese defaults ship with the package.
- The scrolling cards are yours to provide: real reviews, or highlights of your app when you don't have reviews yet.
- Theme: background, glow, stars, button colors and font design.
- App Store ID and support email.

## Installation

Add the package in Xcode (`File > Add Package Dependencies`) or in `Package.swift`:

```swift
.package(url: "https://github.com/didisouzacosta/Ovation.git", branch: "main")
```

```swift
.product(name: "Ovation", package: "Ovation")
```

## License

MIT. See [LICENSE](LICENSE).
