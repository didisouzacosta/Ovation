import Foundation
import Observation
import os

/// Decides each automatic presentation, reserves the session for it, records it once the sheet
/// is really on screen and records how it ended.
@MainActor
@Observable
final class OvationPresentationViewModel {

    // MARK: - Type Properties

    private static let logger = Logger(subsystem: "Ovation", category: "Presentation")

    // MARK: - Public Properties

    /// The decided presentation, shown by `.sheet(item:)`.
    private(set) var activePresentation: OvationPresentation?

    /// The decided sheet has not appeared yet.
    private(set) var isAwaitingAppearance = false

    /// The presentation waiting to appear, to restart the appearance timeout.
    var awaitingPresentationID: UUID? {
        isAwaitingAppearance ? activePresentation?.id : nil
    }

    // MARK: - Private Properties

    @ObservationIgnored private let storage: OvationStorage
    @ObservationIgnored private let session: OvationSession
    @ObservationIgnored private let now: @MainActor () -> Date

    // MARK: - Initializer

    init(
        storage: OvationStorage,
        session: OvationSession = .shared,
        now: @escaping @MainActor () -> Date = Date.init
    ) {
        self.storage = storage
        self.session = session
        self.now = now
    }

    // MARK: - Public Methods

    /// Evaluates one trigger change, in order: no sheet coming or visible, a valid
    /// configuration, a user who has not reviewed, the trigger count, the session and the app's
    /// rule. A positive decision reserves the session (another modifier can't decide meanwhile)
    /// and sets `activePresentation`; nothing is recorded until the sheet appears.
    func handleTrigger(_ configuration: OvationConfiguration) {
        guard activePresentation == nil else {
            return
        }

        guard configuration.isValid else {
            Self.logger.error("Ovation: the App Store ID must have digits only; the sheet is not presented.")
            return
        }

        guard !storage.hasReviewed else {
            return
        }

        storage.triggerCount += 1

        let context = OvationContext(
            triggerCount: storage.triggerCount,
            presentationCount: storage.presentationCount,
            lastPresentation: storage.lastPresentationDate,
            now: now()
        )

        guard
            OvationPolicy.shouldPresent(
                hasReviewed: storage.hasReviewed,
                presentedThisSession: session.isTaken,
                rule: configuration.rule,
                context: context
            )
        else {
            return
        }

        let presentation = OvationPresentation(configuration: configuration)

        guard session.reservePresentation(presentation.id) else {
            return
        }

        activePresentation = presentation
        isAwaitingAppearance = true
    }

    /// The sheet is on screen: the reservation is confirmed, the counts are spent and
    /// `.presented` is returned, once per presentation. A sheet whose reservation was lost (the
    /// session already presented) returns nil and is released.
    func sheetAppeared() -> OvationEvent? {
        guard let presentation = activePresentation, isAwaitingAppearance else {
            return nil
        }

        isAwaitingAppearance = false

        guard session.confirmPresentation(presentation.id) else {
            Self.logger.notice("Ovation: the session already presented; this sheet is released.")
            activePresentation = nil
            return nil
        }

        storage.presentationCount += 1
        storage.lastPresentationDate = now()

        return .presented
    }

    /// The decided sheet did not appear in time (or its view left): it is released, with its
    /// reservation, without spending the session or the counts.
    func presentationDidNotAppear() {
        guard let presentation = activePresentation, isAwaitingAppearance else {
            return
        }

        Self.logger.notice("Ovation: the sheet did not appear in time (another modal may be up); it is released.")
        session.releaseReservation(presentation.id)
        isAwaitingAppearance = false
        activePresentation = nil
    }

    /// Ends the active presentation and returns its terminal event, once, only for a sheet that
    /// appeared. Only opening the review page marks the user as reviewed.
    func finish(_ outcome: OvationOutcome) -> OvationEvent? {
        guard let presentation = activePresentation else {
            return nil
        }

        let appeared = !isAwaitingAppearance

        activePresentation = nil
        isAwaitingAppearance = false

        guard appeared else {
            session.releaseReservation(presentation.id)
            return nil
        }

        if outcome == .reviewPageOpened {
            storage.hasReviewed = true
        }

        return outcome.event
    }
}
