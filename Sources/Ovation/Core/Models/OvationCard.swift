/// A card in the sheet's scrolling row: a real review, a true highlight of your app, or a line
/// said by one of your app's own characters.
///
/// Only show reviews your users actually wrote, with their `rating` or `source`. Without
/// reviews, leave `rating`, `author` and `source` out for a highlight (just the title and the
/// text), or set only `author` to a character's name for that character's line: the footer then
/// shows the name without the person symbol, so it never reads as a user review.
public struct OvationCard: Identifiable, Equatable, Sendable {

    // MARK: - Public Properties

    /// A stable identifier, unique among the cards.
    public let id: String

    public let title: String
    public let text: String

    /// The review's stars, from 1 to 5, or `nil` to hide the stars. Always `nil` for TestFlight
    /// feedback, which has no rating.
    public let rating: Int?

    /// Who wrote the review, or which of your app's characters says the line; `nil` hides it.
    public let author: String?

    /// Where the review was written, or `nil` to hide it. A `.testFlight` card never shows stars.
    public let source: OvationCardSource?

    /// The author is shown with a person symbol only on a review (a card with a `rating` or a
    /// `source`); a character's line (only an `author`) shows just the name.
    public var showsAuthorSymbol: Bool {
        author != nil && (rating != nil || source != nil)
    }

    // MARK: - Internal Properties

    var showsRating: Bool {
        rating != nil
    }

    var showsFooter: Bool {
        author != nil || source != nil
    }

    // MARK: - Initializer

    /// Out-of-range ratings are clamped to 1...5, a TestFlight card drops its rating and a blank
    /// author counts as no author.
    public init(
        id: String,
        title: String,
        text: String,
        rating: Int? = nil,
        author: String? = nil,
        source: OvationCardSource? = nil
    ) {
        self.id = id
        self.title = title
        self.text = text
        self.rating = source == .testFlight ? nil : rating.map { min(max($0, 1), 5) }
        self.author = author?.ovationNonBlank
        self.source = source
    }
}
