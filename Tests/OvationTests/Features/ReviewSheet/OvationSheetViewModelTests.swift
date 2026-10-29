import Foundation
import Testing
@testable import Ovation

@MainActor
@Suite("Sheet view model")
struct OvationSheetViewModelTests {

    // MARK: - Tests

    @Test("the sheet opens on Write a review and shows the configured parts")
    func initialState() throws {
        let viewModel = try makeViewModel()

        #expect(viewModel.primaryButtonTitle == "Write a review")
        #expect(viewModel.texts.title == "Help us grow")
        #expect(viewModel.texts.message == "Your review helps more people discover Poção.")
        #expect(viewModel.showsCarousel)
        #expect(viewModel.showsFeedbackLink)
        #expect(viewModel.isMailAlertPresented == false)
    }

    @Test("Write a review opens the exact App Store link")
    func writeReviewOpensTheReviewPage() throws {
        let viewModel = try makeViewModel()
        let expected = try #require(URL(string: "https://apps.apple.com/app/id6819261640?action=write-review"))

        #expect(viewModel.primaryAction() == .openReviewPage(expected))
    }

    @Test("Write a review without a valid App Store ID just closes the sheet")
    func writeReviewWithoutIDFinishes() throws {
        let viewModel = try makeViewModel(appStoreID: "abc")

        #expect(viewModel.primaryAction() == .finish)
    }

    @Test("feedback opens an exact mailto link with the localized subject")
    func feedbackURL() throws {
        let viewModel = try makeViewModel()

        #expect(
            viewModel.feedbackURL?.absoluteString
                == "mailto:support@example.com?subject=Feedback%20about%20Po%C3%A7%C3%A3o"
        )
    }

    @Test("an accepted mailto link closes the sheet")
    func mailAcceptedFinishes() throws {
        let viewModel = try makeViewModel()

        #expect(viewModel.mailOpened(true))
        #expect(viewModel.isMailAlertPresented == false)
    }

    @Test("a refused mailto link keeps the sheet open with the address alert")
    func mailRefusedShowsAlert() throws {
        let viewModel = try makeViewModel()

        #expect(viewModel.mailOpened(false) == false)
        #expect(viewModel.isMailAlertPresented)
        #expect(viewModel.mailUnavailableMessage == "Write to us at support@example.com.")
    }

    @Test("copying the address puts the support email on the pasteboard")
    func copyEmail() throws {
        var copied: [String] = []

        let viewModel = try makeViewModel { copied.append($0) }

        viewModel.copyEmail()

        #expect(copied == ["support@example.com"])
    }

    @Test("without cards the carousel is hidden")
    func noCardsHidesCarousel() throws {
        let viewModel = try makeViewModel(cards: [])

        #expect(viewModel.showsCarousel == false)
    }

    @Test("without a valid email the feedback link is hidden", arguments: ["", "support"])
    func invalidEmailHidesFeedback(email: String) throws {
        let viewModel = try makeViewModel(supportEmail: email)

        #expect(viewModel.showsFeedbackLink == false)
        #expect(viewModel.feedbackURL == nil)
    }

    @Test("text overrides reach the sheet")
    func overrides() throws {
        let viewModel = try makeViewModel(texts: OvationTexts(writeReviewButton: "Review"))

        #expect(viewModel.primaryButtonTitle == "Review")
    }

    // MARK: - Private Methods

    private func makeViewModel(
        appStoreID: String = "6819261640",
        supportEmail: String = "support@example.com",
        cards: [OvationCard] = [OvationCard(id: "a", title: "A", text: "A")],
        texts: OvationTexts = OvationTexts(),
        copyToPasteboard: @escaping @MainActor (String) -> Void = { _ in }
    ) throws -> OvationSheetViewModel {
        let configuration = OvationConfiguration(
            appStoreID: appStoreID,
            supportEmail: supportEmail,
            appName: "Poção",
            cards: cards,
            texts: texts
        )

        return try OvationSheetViewModel(
            configuration: configuration,
            bundle: #require(OvationTestBundles.localized("en")),
            copyToPasteboard: copyToPasteboard
        )
    }
}
