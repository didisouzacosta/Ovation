import Foundation
import Testing
@testable import Ovation

@MainActor
@Suite("Ovation session")
struct OvationSessionTests {

    // MARK: - Tests

    @Test("a new session is free")
    func newSessionIsFree() {
        let session = OvationSession()

        #expect(session.hasPresented == false)
        #expect(session.isTaken == false)
    }

    @Test("a reservation takes the session until it is confirmed or released")
    func reservationTakesTheSession() {
        let session = OvationSession()
        let first = UUID()

        #expect(session.reservePresentation(first))
        #expect(session.isTaken)
        #expect(session.hasPresented == false)
        #expect(session.reservePresentation(UUID()) == false)
    }

    @Test("confirming the reservation spends the session")
    func confirmingSpendsTheSession() {
        let session = OvationSession()
        let id = UUID()

        _ = session.reservePresentation(id)

        #expect(session.confirmPresentation(id))
        #expect(session.hasPresented)
        #expect(session.isTaken)
        #expect(session.reservePresentation(UUID()) == false)
    }

    @Test("only the reserved presentation can confirm")
    func onlyTheReservationConfirms() {
        let session = OvationSession()

        #expect(session.confirmPresentation(UUID()) == false)

        _ = session.reservePresentation(UUID())

        #expect(session.confirmPresentation(UUID()) == false)
        #expect(session.hasPresented == false)
    }

    @Test("releasing the reservation frees the session; another release changes nothing")
    func releasingFreesTheSession() {
        let session = OvationSession()
        let id = UUID()

        _ = session.reservePresentation(id)
        session.releaseReservation(UUID())

        #expect(session.isTaken)

        session.releaseReservation(id)

        #expect(session.isTaken == false)
        #expect(session.reservePresentation(UUID()))
    }

    @Test("sessions are independent, like separate app processes")
    func sessionsAreIndependent() {
        let first = OvationSession()
        let second = OvationSession()
        let id = UUID()

        _ = first.reservePresentation(id)
        _ = first.confirmPresentation(id)

        #expect(second.isTaken == false)
    }
}
