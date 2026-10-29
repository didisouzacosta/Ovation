import Foundation
import Testing
@testable import Ovation

@Suite("Ovation localization catalog")
struct OvationLocalizationCatalogTests {

    // MARK: - Private Properties

    private static let keys = [
        "ovation.title",
        "ovation.message",
        "ovation.writeReviewButton",
        "ovation.feedbackLink",
        "ovation.feedbackSubject",
        "ovation.mailUnavailableTitle",
        "ovation.mailUnavailableMessage",
        "ovation.mailUnavailableCopy",
        "ovation.mailUnavailableDismiss",
        "ovation.cardRating",
    ]

    // MARK: - Tests

    @Test("the catalog has exactly the ten package keys, each with a comment")
    func catalogHasThePackageKeys() throws {
        let strings = try catalogStrings()

        #expect(Self.keys.count == 10)
        #expect(Set(strings.keys) == Set(Self.keys))

        for key in Self.keys {
            let comment = strings[key]?["comment"] as? String

            #expect(comment?.isEmpty == false, "\(key) has no comment")
        }
    }

    @Test("every key is translated in the five languages with the same placeholders")
    func everyKeyIsTranslated() throws {
        let strings = try catalogStrings()

        for key in Self.keys {
            let english = try #require(value(of: key, in: "en", strings: strings))

            for language in OvationTestBundles.languages {
                let translation = try #require(value(of: key, in: language, strings: strings), "\(key) \(language)")

                #expect(state(of: key, in: language, strings: strings) == "translated", "\(key) \(language)")
                #expect(placeholders(in: translation) == placeholders(in: english), "\(key) \(language)")
            }
        }
    }

    @Test("Brazilian Portuguese uses the approved copy")
    func brazilianPortugueseCopy() throws {
        let strings = try catalogStrings()

        #expect(value(of: "ovation.title", in: "pt-BR", strings: strings) == "Nos ajude a crescer")
        #expect(
            value(of: "ovation.message", in: "pt-BR", strings: strings)
                == "Sua avaliação ajuda mais pessoas a descobrirem o %@."
        )
        #expect(value(of: "ovation.writeReviewButton", in: "pt-BR", strings: strings) == "Escrever uma avaliação")
        #expect(
            value(of: "ovation.feedbackLink", in: "pt-BR", strings: strings)
                == "Tem alguma sugestão? Fale com a gente"
        )
    }

    @Test("English uses the approved copy")
    func englishCopy() throws {
        let strings = try catalogStrings()

        #expect(value(of: "ovation.title", in: "en", strings: strings) == "Help us grow")
        #expect(value(of: "ovation.message", in: "en", strings: strings) ==
            "Your review helps more people discover %@.")
        #expect(value(of: "ovation.feedbackLink", in: "en", strings: strings) == "Have a suggestion? Get in touch")
    }

    @Test("the defaults never ask for a specific rating")
    func defaultsNeverAskForARating() throws {
        let strings = try catalogStrings()

        for language in OvationTestBundles.languages {
            let message = try #require(value(of: "ovation.message", in: language, strings: strings))

            #expect(message.contains("5") == false, "\(language)")
        }
    }

    @Test("French puts a non-breaking space before the question mark")
    func frenchQuestionMark() throws {
        let strings = try catalogStrings()

        #expect(value(of: "ovation.feedbackLink", in: "fr", strings: strings) == "Une suggestion\u{00A0}? Écrivez-nous")
    }

    @Test("the compiled bundle carries every language")
    func compiledBundleCarriesEveryLanguage() throws {
        for language in OvationTestBundles.languages {
            let bundle = try #require(OvationTestBundles.localized(language), "\(language).lproj is missing")
            let title = bundle.localizedString(forKey: "ovation.title", value: "missing", table: nil)

            #expect(title != "missing", "\(language)")
        }

        let portuguese = try #require(OvationTestBundles.localized("pt-BR"))

        #expect(portuguese.localizedString(forKey: "ovation.title", value: nil, table: nil) == "Nos ajude a crescer")
    }

    // MARK: - Private Methods

    private func catalogStrings() throws -> [String: [String: Any]] {
        let url = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Sources/Ovation/Resources/Localizable.xcstrings")
        let data = try Data(contentsOf: url)
        let catalog = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(catalog["sourceLanguage"] as? String == "en")

        return try #require(catalog["strings"] as? [String: [String: Any]])
    }

    private func stringUnit(of key: String, in language: String, strings: [String: [String: Any]]) -> [String: Any]? {
        let localizations = strings[key]?["localizations"] as? [String: Any]
        let localization = localizations?[language] as? [String: Any]

        return localization?["stringUnit"] as? [String: Any]
    }

    private func value(of key: String, in language: String, strings: [String: [String: Any]]) -> String? {
        stringUnit(of: key, in: language, strings: strings)?["value"] as? String
    }

    private func state(of key: String, in language: String, strings: [String: [String: Any]]) -> String? {
        stringUnit(of: key, in: language, strings: strings)?["state"] as? String
    }

    private func placeholders(in value: String) -> [String] {
        value.matches(of: /%(lld|@)/).map { String($0.output.0) }
    }
}
