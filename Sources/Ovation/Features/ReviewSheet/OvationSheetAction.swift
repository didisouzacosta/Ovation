import Foundation

/// What the sheet does after a tap on the main button.
enum OvationSheetAction: Equatable, Sendable {
    /// Open the App Store page to write a review, then finish.
    case openReviewPage(URL)

    /// Close the sheet: there is no valid page to open.
    case finish
}
