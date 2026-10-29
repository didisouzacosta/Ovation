import Foundation

/// Whether the sheet appeared, or is about to appear, in this app session.
///
/// A session is the life of the process: the state lives only in memory, is shared by every
/// `ovationReview` modifier through `shared` and is never persisted. This global state is a
/// deliberate exception, because the "once per session" rule belongs to the whole process.
/// A decided sheet reserves the session until it appears (confirmed) or is released, so two
/// modifiers can't both present in the window between the decision and the appearance.
/// Tests inject their own instance.
@MainActor
final class OvationSession {

    // MARK: - Type Properties

    static let shared = OvationSession()

    // MARK: - Public Properties

    /// A sheet appeared in this session.
    private(set) var hasPresented = false

    /// The session is spent or reserved: no other sheet may be decided.
    var isTaken: Bool {
        hasPresented || reservation != nil
    }

    // MARK: - Private Properties

    private var reservation: UUID?

    // MARK: - Public Methods

    /// Reserves the session for a decided sheet; false when it is already reserved or spent.
    func reservePresentation(_ id: UUID) -> Bool {
        guard !isTaken else {
            return false
        }

        reservation = id
        return true
    }

    /// The reserved sheet is on screen: the session is spent. False for any other sheet.
    func confirmPresentation(_ id: UUID) -> Bool {
        guard reservation == id else {
            return false
        }

        reservation = nil
        hasPresented = true
        return true
    }

    /// The reserved sheet did not appear: the session is free again. Other sheets change nothing.
    func releaseReservation(_ id: UUID) {
        guard reservation == id else {
            return
        }

        reservation = nil
    }
}
