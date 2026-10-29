import Foundation
@testable import Ovation

@MainActor
final class InMemoryOvationStorage: OvationStorage {

    // MARK: - OvationStorage

    var hasReviewed = false

    var triggerCount = 0

    var presentationCount = 0

    var lastPresentationDate: Date?
}
