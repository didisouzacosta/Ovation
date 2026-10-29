import Foundation
import Testing
@testable import Ovation

@Suite("Ovation rules")
struct OvationRuleTests {

    // MARK: - Private Properties

    private let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

    // MARK: - Tests

    @Test("always allows every trigger")
    func alwaysAllowsEveryTrigger() {
        #expect(OvationRule.always.allows(context(triggerCount: 1)))
        #expect(OvationRule.always.allows(context(triggerCount: 42)))
    }

    @Test("fromTrigger allows the given trigger and every one after it")
    func fromTriggerAllowsFromTheGivenTrigger() {
        let rule = OvationRule.fromTrigger(3)

        #expect(rule.allows(context(triggerCount: 2)) == false)
        #expect(rule.allows(context(triggerCount: 3)))
        #expect(rule.allows(context(triggerCount: 4)))
    }

    @Test("fromTrigger treats zero and negative numbers as the first trigger")
    func fromTriggerClampsToOne() {
        #expect(OvationRule.fromTrigger(0).allows(context(triggerCount: 1)))
        #expect(OvationRule.fromTrigger(-5).allows(context(triggerCount: 1)))
    }

    @Test("everyTrigger allows multiples of the interval")
    func everyTriggerAllowsMultiples() {
        let rule = OvationRule.everyTrigger(3)

        #expect(rule.allows(context(triggerCount: 1)) == false)
        #expect(rule.allows(context(triggerCount: 3)))
        #expect(rule.allows(context(triggerCount: 5)) == false)
        #expect(rule.allows(context(triggerCount: 6)))
    }

    @Test("everyTrigger treats zero and negative intervals as every trigger")
    func everyTriggerClampsToOne() {
        #expect(OvationRule.everyTrigger(0).allows(context(triggerCount: 1)))
        #expect(OvationRule.everyTrigger(-2).allows(context(triggerCount: 2)))
    }

    @Test("custom rules receive the full context")
    func customRuleReceivesContext() {
        let rule = OvationRule.custom { context in
            context.triggerCount == 2 && context.presentationCount == 1
        }

        #expect(rule.allows(context(triggerCount: 2, presentationCount: 1)))
        #expect(rule.allows(context(triggerCount: 2, presentationCount: 0)) == false)
    }

    @Test("waitingDays allows the first presentation")
    func waitingDaysAllowsFirstPresentation() {
        let rule = OvationRule.always.waitingDays(14)

        #expect(rule.allows(context(triggerCount: 1, lastPresentation: nil)))
    }

    @Test("waitingDays denies 13 days and 23 hours and allows 14 days")
    func waitingDaysUsesWholeDays() {
        let rule = OvationRule.always.waitingDays(14)
        let almost = now.addingTimeInterval(-(13 * 86_400 + 23 * 3_600))
        let exact = now.addingTimeInterval(-(14 * 86_400))

        #expect(rule.allows(context(triggerCount: 1, lastPresentation: almost)) == false)
        #expect(rule.allows(context(triggerCount: 1, lastPresentation: exact)))
    }

    @Test("waitingDays keeps the base rule")
    func waitingDaysKeepsBaseRule() {
        let rule = OvationRule.fromTrigger(3).waitingDays(14)

        #expect(rule.allows(context(triggerCount: 2, lastPresentation: nil)) == false)
        #expect(rule.allows(context(triggerCount: 3, lastPresentation: nil)))
    }

    @Test("waitingDays treats negative days as no wait")
    func waitingDaysClampsToZero() {
        let rule = OvationRule.always.waitingDays(-3)

        #expect(rule.allows(context(triggerCount: 1, lastPresentation: now)))
    }

    // MARK: - Private Methods

    private func context(
        triggerCount: Int,
        presentationCount: Int = 0,
        lastPresentation: Date? = nil
    ) -> OvationContext {
        OvationContext(
            triggerCount: triggerCount,
            presentationCount: presentationCount,
            lastPresentation: lastPresentation,
            now: now
        )
    }
}
