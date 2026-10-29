/// Public timing of the automatic presentation.
public enum OvationReview {

    // MARK: - Type Properties

    /// How long a decided sheet may take to appear before it is released without spending the
    /// session or the counts (another modal over the window can keep SwiftUI from presenting it).
    /// Apps that hold their own flow while the sheet is coming can wait a little longer than this.
    public static let appearanceTimeout: Duration = .seconds(1)
}
