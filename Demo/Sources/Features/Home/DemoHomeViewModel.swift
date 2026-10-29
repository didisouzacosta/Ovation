import Foundation
import Observation

/// The demo's debugging tools around the levels screen.
@Observable
final class DemoHomeViewModel {

    // MARK: - Public Properties

    var isSheetPreviewPresented = false

    private(set) var didResetSavedState = false

    // MARK: - Private Properties

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private let domainName: String?

    // MARK: - Initializer

    init(defaults: UserDefaults = .standard, domainName: String? = Bundle.main.bundleIdentifier) {
        self.defaults = defaults
        self.domainName = domainName
    }

    // MARK: - Public Methods

    /// Shows the sheet without rules, storage or events.
    func previewSheet() {
        isSheetPreviewPresented = true
    }

    /// Forgets the review state, so the sheet can appear again after a relaunch.
    func resetSavedState() {
        guard let domainName else {
            return
        }

        defaults.removePersistentDomain(forName: domainName)
        didResetSavedState = true
    }
}
