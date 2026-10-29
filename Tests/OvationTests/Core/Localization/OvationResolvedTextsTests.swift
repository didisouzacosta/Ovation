import Foundation
import Testing
@testable import Ovation

@Suite("Ovation resolved texts")
struct OvationResolvedTextsTests {

    // MARK: - Tests

    @Test("the English defaults include the app name")
    func englishDefaults() throws {
        let bundle = try #require(OvationTestBundles.localized("en"))
        let texts = OvationResolvedTexts(texts: OvationTexts(), appName: "PotionPals", bundle: bundle)

        #expect(texts.title == "Help us grow")
        #expect(texts.message == "Your review helps more people discover PotionPals.")
        #expect(texts.writeReviewButton == "Write a review")
        #expect(texts.feedbackLink == "Have a suggestion? Get in touch")
        #expect(texts.feedbackSubject == "Feedback about PotionPals")
    }

    @Test("the Brazilian Portuguese defaults include the app name")
    func brazilianPortugueseDefaults() throws {
        let bundle = try #require(OvationTestBundles.localized("pt-BR"))
        let texts = OvationResolvedTexts(texts: OvationTexts(), appName: "PotionPals", bundle: bundle)

        #expect(texts.title == "Nos ajude a crescer")
        #expect(texts.message == "Sua avaliação ajuda mais pessoas a descobrirem o PotionPals.")
        #expect(texts.writeReviewButton == "Escrever uma avaliação")
        #expect(texts.feedbackLink == "Tem alguma sugestão? Fale com a gente")
        #expect(texts.feedbackSubject == "Feedback sobre o PotionPals")
    }

    @Test("overrides win over the defaults")
    func overridesWin() throws {
        let bundle = try #require(OvationTestBundles.localized("en"))
        let overrides = OvationTexts(
            title: "Enjoying it?",
            message: "Tell the world.",
            writeReviewButton: "Review",
            feedbackLink: "Talk to us",
            feedbackSubject: "Hello"
        )
        let texts = OvationResolvedTexts(texts: overrides, appName: "PotionPals", bundle: bundle)

        #expect(texts.title == "Enjoying it?")
        #expect(texts.message == "Tell the world.")
        #expect(texts.writeReviewButton == "Review")
        #expect(texts.feedbackLink == "Talk to us")
        #expect(texts.feedbackSubject == "Hello")
    }

    @Test("blank overrides keep the defaults")
    func blankOverridesKeepDefaults() throws {
        let bundle = try #require(OvationTestBundles.localized("en"))
        let texts = OvationResolvedTexts(texts: OvationTexts(title: "  "), appName: "PotionPals", bundle: bundle)

        #expect(texts.title == "Help us grow")
    }

    @Test("the fixed strings are localized")
    func fixedStrings() throws {
        let bundle = try #require(OvationTestBundles.localized("pt-BR"))

        #expect(OvationLocalized.mailUnavailableTitle(bundle: bundle) == "Não foi possível abrir o e-mail")
        #expect(OvationLocalized.mailUnavailableMessage(email: "a@b.com", bundle: bundle) == "Escreva para a@b.com.")
        #expect(OvationLocalized.mailUnavailableCopy(bundle: bundle) == "Copiar endereço")
        #expect(OvationLocalized.mailUnavailableDismiss(bundle: bundle) == "OK")
        #expect(OvationLocalized.cardRating(4, bundle: bundle) == "4 de 5 estrelas")
    }
}
