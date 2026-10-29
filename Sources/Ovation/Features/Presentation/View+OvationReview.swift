import SwiftUI

public extension View {

    // MARK: - Presentation

    /// Asks for an App Store review when `trigger` changes and the user may see the sheet.
    ///
    /// Each change of `trigger` is evaluated in order; its initial value does not count:
    /// 1. the configuration has a valid App Store ID;
    /// 2. the user has not opened "Write a review" yet (final: after that, nothing is counted);
    /// 3. the trigger is counted;
    /// 4. the sheet has not appeared in this app session;
    /// 5. `configuration.rule` allows it.
    ///
    /// A change while the sheet is visible is ignored and not counted. `onEvent` receives
    /// `.presented`, then at most one of `.reviewPageOpened`, `.feedbackOpened` or `.dismissed`.
    ///
    /// Change `trigger` only at a quiet moment: SwiftUI may dismiss a modal presented outside
    /// SwiftUI (a UIKit sign-in or consent form) to show the sheet. A sheet that can't appear is
    /// released after `OvationReview.appearanceTimeout`.
    ///
    /// Ovation never calls the native review prompt (`RequestReviewAction`); call it yourself,
    /// when and how you want.
    func ovationReview(
        _ configuration: OvationConfiguration,
        trigger: some Equatable,
        onEvent: @escaping @MainActor (OvationEvent) -> Void = { _ in }
    ) -> some View {
        modifier(
            OvationPresentationModifier(
                configuration: configuration,
                trigger: trigger,
                onEvent: onEvent
            )
        )
    }

    /// Presents the review sheet while `isPresented` is true, for debugging and previews.
    ///
    /// It ignores the rule, the "already reviewed" mark and the session, reads and writes
    /// nothing, and sends no events. Do not use it to ask for reviews in production.
    func ovationReview(isPresented: Binding<Bool>, configuration: OvationConfiguration) -> some View {
        modifier(OvationForcedPresentationModifier(isPresented: isPresented, configuration: configuration))
    }
}
