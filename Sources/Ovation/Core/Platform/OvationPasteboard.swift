import UIKit

/// The system pasteboard, used by the "Copy address" button.
enum OvationPasteboard {

    // MARK: - Public Methods

    @MainActor
    static func copy(_ string: String) {
        UIPasteboard.general.string = string
    }
}
