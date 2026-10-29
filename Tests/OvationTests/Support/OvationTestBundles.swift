import Foundation
@testable import Ovation

/// The package's compiled localizations, one language at a time.
enum OvationTestBundles {

    // MARK: - Public Properties

    static let languages = ["en", "pt-BR", "es", "fr", "ja"]

    // MARK: - Public Methods

    static func localized(_ language: String) -> Bundle? {
        Bundle.module
            .path(forResource: language, ofType: "lproj")
            .flatMap(Bundle.init(path:))
    }
}
