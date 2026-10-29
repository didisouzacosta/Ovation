import Foundation
import Testing
@testable import Ovation

@MainActor
@Suite("Presentation view model")
struct OvationPresentationViewModelTests {

    // MARK: - Private Properties

    private let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

    // MARK: - Tests

    @Test("triggers are counted even when the rule does not present")
    func countsTriggersWithoutPresenting() {
        let storage = InMemoryOvationStorage()
        let viewModel = makeViewModel(storage: storage)
        let configuration = makeConfiguration(rule: .fromTrigger(3))

        viewModel.handleTrigger(configuration)
        viewModel.handleTrigger(configuration)

        #expect(storage.triggerCount == 2)
        #expect(viewModel.activePresentation == nil)
    }

    @Test("fromTrigger(3) decides on the third trigger and records it once the sheet appears")
    func presentsOnTheThirdTrigger() {
        let storage = InMemoryOvationStorage()
        let viewModel = makeViewModel(storage: storage)
        let configuration = makeConfiguration(rule: .fromTrigger(3))

        viewModel.handleTrigger(configuration)
        viewModel.handleTrigger(configuration)
        viewModel.handleTrigger(configuration)

        #expect(viewModel.activePresentation?.configuration.appStoreID == "6819261640")
        #expect(storage.presentationCount == 0)
        #expect(viewModel.sheetAppeared() == .presented)
        #expect(storage.triggerCount == 3)
        #expect(storage.presentationCount == 1)
        #expect(storage.lastPresentationDate == now)
    }

    @Test("a decided sheet that never appears records nothing and is released")
    func decidedButNotShownIsReleased() {
        let storage = InMemoryOvationStorage()
        let session = OvationSession()
        let viewModel = makeViewModel(storage: storage, session: session)

        viewModel.handleTrigger(makeConfiguration())

        #expect(viewModel.isAwaitingAppearance)

        viewModel.presentationDidNotAppear()

        #expect(viewModel.activePresentation == nil)
        #expect(viewModel.isAwaitingAppearance == false)
        #expect(storage.presentationCount == 0)
        #expect(storage.lastPresentationDate == nil)
        #expect(session.isTaken == false)

        // The session is still free: the next trigger can present.
        viewModel.handleTrigger(makeConfiguration())

        #expect(viewModel.sheetAppeared() == .presented)
    }

    @Test("an appearance sends presented once")
    func appearanceSendsPresentedOnce() {
        let viewModel = makeViewModel(storage: InMemoryOvationStorage())

        #expect(viewModel.sheetAppeared() == nil)

        viewModel.handleTrigger(makeConfiguration())

        #expect(viewModel.sheetAppeared() == .presented)
        #expect(viewModel.sheetAppeared() == nil)
        #expect(viewModel.isAwaitingAppearance == false)
    }

    @Test("the release after an appearance changes nothing")
    func releaseAfterAppearanceIsIgnored() {
        let viewModel = makeViewModel(storage: InMemoryOvationStorage())

        viewModel.handleTrigger(makeConfiguration())
        _ = viewModel.sheetAppeared()
        viewModel.presentationDidNotAppear()

        #expect(viewModel.activePresentation != nil)
    }

    @Test("a sheet closed before it appeared sends no terminal event")
    func finishBeforeAppearance() {
        let storage = InMemoryOvationStorage()
        let viewModel = makeViewModel(storage: storage)

        viewModel.handleTrigger(makeConfiguration())

        #expect(viewModel.finish(.dismissed) == nil)
        #expect(viewModel.activePresentation == nil)
        #expect(storage.presentationCount == 0)
    }

    @Test("the rule receives the counts including the current trigger")
    func ruleReceivesContext() {
        let storage = InMemoryOvationStorage()
        let recorder = ContextRecorder()
        let last = now.addingTimeInterval(-86_400)

        storage.triggerCount = 4
        storage.presentationCount = 2
        storage.lastPresentationDate = last

        let viewModel = makeViewModel(storage: storage)

        viewModel.handleTrigger(makeConfiguration(rule: recorder.rule(allowing: false)))

        #expect(
            recorder.last
                == OvationContext(triggerCount: 5, presentationCount: 2, lastPresentation: last, now: now)
        )
    }

    @Test("waitingDays keeps the sheet away for the given days")
    func waitingDays() {
        let rule = OvationRule.always.waitingDays(14)
        let recent = InMemoryOvationStorage()
        let old = InMemoryOvationStorage()

        recent.lastPresentationDate = now.addingTimeInterval(-13 * 86_400)
        old.lastPresentationDate = now.addingTimeInterval(-14 * 86_400)

        let recentViewModel = makeViewModel(storage: recent)
        let oldViewModel = makeViewModel(storage: old)

        recentViewModel.handleTrigger(makeConfiguration(rule: rule))
        oldViewModel.handleTrigger(makeConfiguration(rule: rule))

        #expect(recentViewModel.activePresentation == nil)
        #expect(oldViewModel.activePresentation != nil)
    }

    @Test("a user who reviewed never sees the sheet and nothing more is counted")
    func reviewedUsersAreNeverCounted() {
        let storage = InMemoryOvationStorage()

        storage.hasReviewed = true

        let viewModel = makeViewModel(storage: storage)

        viewModel.handleTrigger(makeConfiguration())

        #expect(storage.triggerCount == 0)
        #expect(viewModel.activePresentation == nil)
    }

    @Test("a trigger while the sheet is coming or visible is ignored and not counted")
    func triggerWhileVisibleIsIgnored() {
        let storage = InMemoryOvationStorage()
        let viewModel = makeViewModel(storage: storage)

        viewModel.handleTrigger(makeConfiguration())
        viewModel.handleTrigger(makeConfiguration())

        #expect(storage.triggerCount == 1)

        _ = viewModel.sheetAppeared()
        viewModel.handleTrigger(makeConfiguration())

        #expect(storage.triggerCount == 1)
        #expect(storage.presentationCount == 1)
    }

    @Test("an invalid App Store ID never presents and counts nothing", arguments: ["", "abc", "12a"])
    func invalidConfigurationNeverPresents(appStoreID: String) {
        let storage = InMemoryOvationStorage()
        let viewModel = makeViewModel(storage: storage)

        viewModel.handleTrigger(makeConfiguration(appStoreID: appStoreID))

        #expect(storage.triggerCount == 0)
        #expect(viewModel.activePresentation == nil)
    }

    @Test("the sheet appears once per session, while triggers are still counted")
    func oncePerSession() {
        let storage = InMemoryOvationStorage()
        let viewModel = makeViewModel(storage: storage)

        present(viewModel)

        #expect(viewModel.finish(.dismissed) == .dismissed)

        viewModel.handleTrigger(makeConfiguration())

        #expect(viewModel.activePresentation == nil)
        #expect(storage.triggerCount == 2)
        #expect(storage.presentationCount == 1)
    }

    @Test("modifiers sharing a session present only once")
    func sharedSession() {
        let session = OvationSession()
        let first = makeViewModel(storage: InMemoryOvationStorage(), session: session)
        let second = makeViewModel(storage: InMemoryOvationStorage(), session: session)

        present(first)
        second.handleTrigger(makeConfiguration())

        #expect(second.activePresentation == nil)
    }

    @Test("a sheet still coming holds the session: another modifier does not decide")
    func pendingSheetHoldsTheSession() {
        let session = OvationSession()
        let first = makeViewModel(storage: InMemoryOvationStorage(), session: session)
        let secondStorage = InMemoryOvationStorage()
        let second = makeViewModel(storage: secondStorage, session: session)

        first.handleTrigger(makeConfiguration())
        second.handleTrigger(makeConfiguration())

        #expect(first.isAwaitingAppearance)
        #expect(second.activePresentation == nil)
        #expect(secondStorage.triggerCount == 1)
    }

    @Test("a released sheet frees the session for another modifier", arguments: [false, true])
    func releasedSheetFreesTheSession(closedBeforeAppearing: Bool) {
        let session = OvationSession()
        let first = makeViewModel(storage: InMemoryOvationStorage(), session: session)
        let second = makeViewModel(storage: InMemoryOvationStorage(), session: session)

        first.handleTrigger(makeConfiguration())

        if closedBeforeAppearing {
            #expect(first.finish(.dismissed) == nil)
        } else {
            first.presentationDidNotAppear()
        }

        present(second)

        #expect(session.hasPresented)
    }

    @Test("concurrent appearances send presented once per session")
    func concurrentAppearancesSendOnePresented() throws {
        let session = OvationSession()
        let firstStorage = InMemoryOvationStorage()
        let first = makeViewModel(storage: firstStorage, session: session)
        let second = makeViewModel(storage: InMemoryOvationStorage(), session: session)

        first.handleTrigger(makeConfiguration())

        // The first sheet lost its reservation (as after the appearance timeout) but appears late.
        try session.releaseReservation(#require(first.activePresentation?.id))
        present(second)

        #expect(first.sheetAppeared() == nil)
        #expect(first.activePresentation == nil)
        #expect(first.isAwaitingAppearance == false)
        #expect(firstStorage.presentationCount == 0)
        #expect(firstStorage.lastPresentationDate == nil)
    }

    @Test("a new session, like a relaunch, can present again")
    func newSessionPresentsAgain() {
        let storage = InMemoryOvationStorage()
        let first = makeViewModel(storage: storage, session: OvationSession())

        present(first)

        #expect(first.finish(.dismissed) == .dismissed)

        let relaunched = makeViewModel(storage: storage, session: OvationSession())

        present(relaunched)

        #expect(storage.presentationCount == 2)
    }

    @Test("opening the review page marks the user as reviewed")
    func reviewPageMarksReviewed() {
        let storage = InMemoryOvationStorage()
        let viewModel = makeViewModel(storage: storage)

        present(viewModel)

        #expect(viewModel.finish(.reviewPageOpened) == .reviewPageOpened)
        #expect(storage.hasReviewed)
        #expect(viewModel.activePresentation == nil)
    }

    @Test("closing or sending feedback does not mark the user as reviewed", arguments: [
        OvationOutcome.dismissed,
        OvationOutcome.feedbackOpened,
    ])
    func otherOutcomesDoNotMarkReviewed(outcome: OvationOutcome) {
        let storage = InMemoryOvationStorage()
        let viewModel = makeViewModel(storage: storage)

        present(viewModel)

        #expect(viewModel.finish(outcome) == outcome.event)
        #expect(storage.hasReviewed == false)
        #expect(viewModel.activePresentation == nil)
    }

    @Test("each presentation ends with exactly one terminal event")
    func oneTerminalEvent() {
        let viewModel = makeViewModel(storage: InMemoryOvationStorage())

        #expect(viewModel.finish(.dismissed) == nil)

        present(viewModel)

        #expect(viewModel.finish(.feedbackOpened) == .feedbackOpened)
        #expect(viewModel.finish(.dismissed) == nil)
    }

    @Test("an undelivered sheet is released after a short wait")
    func appearanceTimeout() {
        #expect(OvationReview.appearanceTimeout == .seconds(1))
    }

    // MARK: - Private Methods

    private func makeViewModel(
        storage: InMemoryOvationStorage,
        session: OvationSession = OvationSession()
    ) -> OvationPresentationViewModel {
        let now = now

        return OvationPresentationViewModel(storage: storage, session: session, now: { now })
    }

    private func makeConfiguration(
        appStoreID: String = "6819261640",
        rule: OvationRule = .always
    ) -> OvationConfiguration {
        OvationConfiguration(appStoreID: appStoreID, supportEmail: "support@example.com", rule: rule)
    }

    /// Decides and shows the sheet, as the modifier does.
    private func present(_ viewModel: OvationPresentationViewModel) {
        viewModel.handleTrigger(makeConfiguration())

        #expect(viewModel.sheetAppeared() == .presented)
    }
}
