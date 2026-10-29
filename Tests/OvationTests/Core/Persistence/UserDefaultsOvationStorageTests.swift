import Foundation
import Testing
@testable import Ovation

@MainActor
@Suite("UserDefaults storage")
struct UserDefaultsOvationStorageTests {

    // MARK: - Tests

    @Test("a new storage starts with the defaults")
    func startsWithDefaults() throws {
        try withDefaults { defaults in
            let storage = UserDefaultsOvationStorage(defaults: defaults, namespace: "com.example.app")

            #expect(storage.hasReviewed == false)
            #expect(storage.triggerCount == 0)
            #expect(storage.presentationCount == 0)
            #expect(storage.lastPresentationDate == nil)
        }
    }

    @Test("values are written under the namespaced keys")
    func writesNamespacedKeys() throws {
        try withDefaults { defaults in
            let storage = UserDefaultsOvationStorage(defaults: defaults, namespace: "com.example.app")
            let date = Date(timeIntervalSinceReferenceDate: 800_000_000)

            storage.hasReviewed = true
            storage.triggerCount = 3
            storage.presentationCount = 2
            storage.lastPresentationDate = date

            #expect(defaults.bool(forKey: "com.example.app.Ovation.hasReviewed"))
            #expect(defaults.integer(forKey: "com.example.app.Ovation.triggerCount") == 3)
            #expect(defaults.integer(forKey: "com.example.app.Ovation.presentationCount") == 2)
            #expect(defaults.object(forKey: "com.example.app.Ovation.lastPresentationDate") as? Date == date)
        }
    }

    @Test("values survive a new storage instance")
    func valuesRoundTrip() throws {
        try withDefaults { defaults in
            let date = Date(timeIntervalSinceReferenceDate: 800_000_000)
            let writer = UserDefaultsOvationStorage(defaults: defaults, namespace: "app")

            writer.hasReviewed = true
            writer.triggerCount = 7
            writer.presentationCount = 1
            writer.lastPresentationDate = date

            let reader = UserDefaultsOvationStorage(defaults: defaults, namespace: "app")

            #expect(reader.hasReviewed)
            #expect(reader.triggerCount == 7)
            #expect(reader.presentationCount == 1)
            #expect(reader.lastPresentationDate == date)
        }
    }

    @Test("namespaces are isolated")
    func namespacesAreIsolated() throws {
        try withDefaults { defaults in
            let first = UserDefaultsOvationStorage(defaults: defaults, namespace: "first")
            let second = UserDefaultsOvationStorage(defaults: defaults, namespace: "second")

            first.hasReviewed = true
            first.triggerCount = 4

            #expect(second.hasReviewed == false)
            #expect(second.triggerCount == 0)
        }
    }

    @Test("clearing the last presentation date removes the key")
    func clearingTheDateRemovesTheKey() throws {
        try withDefaults { defaults in
            let storage = UserDefaultsOvationStorage(defaults: defaults, namespace: "app")

            storage.lastPresentationDate = Date()
            storage.lastPresentationDate = nil

            #expect(defaults.object(forKey: "app.Ovation.lastPresentationDate") == nil)
        }
    }

    // MARK: - Private Methods

    private func withDefaults(_ body: (UserDefaults) throws -> Void) throws {
        let suiteName = "OvationTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))

        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        try body(defaults)
    }
}
