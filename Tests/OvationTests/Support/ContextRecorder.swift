import Synchronization
@testable import Ovation

/// Records the contexts a rule receives.
final class ContextRecorder: Sendable {

    // MARK: - Private Properties

    private let contexts = Mutex<[OvationContext]>([])

    // MARK: - Public Properties

    var last: OvationContext? {
        contexts.withLock { $0.last }
    }

    // MARK: - Public Methods

    func rule(allowing allows: Bool) -> OvationRule {
        .custom { [self] context in
            contexts.withLock { $0.append(context) }
            return allows
        }
    }
}
