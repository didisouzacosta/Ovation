import Foundation
import Synchronization
import Testing
@testable import Ovation

@Suite("Ovation presentation policy")
struct OvationPolicyTests {

    // MARK: - Private Properties

    private let context = OvationContext(
        triggerCount: 1,
        presentationCount: 0,
        lastPresentation: nil,
        now: Date(timeIntervalSinceReferenceDate: 0)
    )

    // MARK: - Tests

    @Test("presents when the user has not reviewed, the session is free and the rule allows")
    func presentsWhenEverythingAllows() {
        #expect(
            OvationPolicy.shouldPresent(
                hasReviewed: false,
                presentedThisSession: false,
                rule: .always,
                context: context
            )
        )
    }

    @Test("never presents after the user reviewed, without asking the rule")
    func neverPresentsAfterReview() {
        let calls = RuleCallCounter()

        let presents = OvationPolicy.shouldPresent(
            hasReviewed: true,
            presentedThisSession: false,
            rule: calls.rule(allowing: true),
            context: context
        )

        #expect(presents == false)
        #expect(calls.count == 0)
    }

    @Test("never presents twice in a session, without asking the rule")
    func neverPresentsTwiceInSession() {
        let calls = RuleCallCounter()

        let presents = OvationPolicy.shouldPresent(
            hasReviewed: false,
            presentedThisSession: true,
            rule: calls.rule(allowing: true),
            context: context
        )

        #expect(presents == false)
        #expect(calls.count == 0)
    }

    @Test("follows the app rule last")
    func followsTheRuleLast() {
        let calls = RuleCallCounter()

        let presents = OvationPolicy.shouldPresent(
            hasReviewed: false,
            presentedThisSession: false,
            rule: calls.rule(allowing: false),
            context: context
        )

        #expect(presents == false)
        #expect(calls.count == 1)
    }
}

// MARK: - Support

private final class RuleCallCounter: Sendable {

    // MARK: - Private Properties

    private let calls = Mutex(0)

    // MARK: - Public Properties

    var count: Int {
        calls.withLock { $0 }
    }

    // MARK: - Public Methods

    func rule(allowing allows: Bool) -> OvationRule {
        .custom { [self] _ in
            calls.withLock { $0 += 1 }
            return allows
        }
    }
}
